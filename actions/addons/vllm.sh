echo "Launch VLLM endpoint"
MODEL_NAME="$GPFS_VLLM_MODEL"

if [[ "$MODEL_NAME" != *"/"* ]]; then
    dir="data"
    MODEL_NAME="data/$MODEL_NAME"
else
    # Extract the directory part excluding the last segment
    dir=$(dirname "$MODEL_NAME")
    # MODEL_NAME remains unchanged in this case
fi

if [ "$SLURM_JOB_NUM_NODES" -eq 1 ]; then
    echo "Running on singlenode"
    export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
    export SLURM_CPU_BIND=none

    nohup singularity run --nv \
        --bind $GPFS_MODELS_REGISTRY_PATH:/$dir  \
        $GPFS_VLLM_SINGULARITY  \
        --model /$MODEL_NAME \
        --served-model-name $GPFS_VLLM_MODEL "tgi" \
        --host 0.0.0.0 \
        --port 8080 \
        --tensor-parallel-size $SLURM_GPUS_ON_NODE $(echo $JOB_VLLM_PARAMS) > $JOB_PATH/logs/vllm.log 2>&1 &

else

    echo "Running on multinode"
    export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
    export SLURM_CPU_BIND=none

    export VLLM_LOGGING_LEVEL=DEBUG
    export VLLM_TRACE_FUNCTION=1
    export CUDA_LAUNCH_BLOCKING=1
    export NCCL_DEBUG=TRACE

    head_node=$(scontrol show hostname | head -n 1)
    head_node_port=6379
    ip_addr=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address)
    ip_head=$ip_addr:$head_node_port

    singularity exec --nv $GPFS_VLLM_SINGULARITY ray stop
    export VLLM_PORT=$head_node_port
    export VLLM_HOST_IP=$ip_addr
    
    # Start Ray head node on the first node (head node)
    echo "Run --head"
    srun --nodes=1 --ntasks-per-node=1 --nodelist=$head_node \
        nohup singularity exec --nv --bind $GPFS_MODELS_REGISTRY_PATH:/$dir $GPFS_VLLM_SINGULARITY ray start --block --head --port=$head_node_port &


    sleep 10
    # Start Ray worker nodes on all other nodes (excluding the head node)
    srun --nodes=$((SLURM_JOB_NUM_NODES - 1)) --ntasks-per-node=1 --exclude=$head_node \
        nohup singularity exec --nv --bind $GPFS_MODELS_REGISTRY_PATH:/$dir $GPFS_VLLM_SINGULARITY ray start --block --address $ip_head &

    sleep 20
    echo "======================Ray Status==========================="
    singularity exec --nv $GPFS_VLLM_SINGULARITY ray status
    echo "==========================================================="

    nohup singularity run --nv \
        --bind $GPFS_MODELS_REGISTRY_PATH:/$dir  \
        $GPFS_VLLM_SINGULARITY  \
        --model /$MODEL_NAME \
        --served-model-name $GPFS_VLLM_MODEL "tgi" \
        --host 0.0.0.0 \
        --port 8080 \
        --tensor-parallel-size $((SLURM_JOB_NUM_NODES * SLURM_GPUS_ON_NODE)) $(echo $JOB_VLLM_PARAMS) > $JOB_PATH/logs/vllm.log 2>&1 &

fi
