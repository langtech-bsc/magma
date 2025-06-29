echo "Launch VLLM endpoint"
MODEL_NAME="$GPFS_VLLM_MODEL"
rm -rf $JOB_PATH/.cache/vllm

export SINGULARITYENV_LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/.singularity.d/libs:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/2023.2.0/linux/compiler/lib/intel64_lin/                    
export SINGULARITYENV_PATH=/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin/intel64:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin/intel64:/apps/ACC/UCX/1.15.0/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/mpi/2021.10.0/libfabric/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/mpi/2021.10.0/bin:/apps/GPP/SINGULARITY/extras:/apps/GPP/SINGULARITY/3.11.5/bin:/apps/GPP/ANACONDA/2023.07/bin:/apps/GPP/ANACONDA/2023.07/condabin:/home/bsc/bsc088851/.local/bin:/home/bsc/bsc088851/bin:/apps/modules/bsc/bin:/home/bsc/bsc099349/.local/bin:/home/bsc/bsc099349/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
#export SINGULARITYENV_PATH=/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin/intel64:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin/intel64:/apps/ACC/UCX/1.15.0/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/mpi/2021.10.0/libfabric/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/mpi/2021.10.0/bin:/gpfs/projects/bsc88/text/environments/openai_mn5_python3.9_20253101/bin:/apps/GPP/SINGULARITY/extras:/apps/GPP/SINGULARITY/3.11.5/bin:/apps/GPP/ANACONDA/2023.07/bin:/apps/GPP/ANACONDA/2023.07/condabin:/home/bsc/bsc088851/.local/bin:/home/bsc/bsc088851/bin:/apps/modules/bsc/bin:/home/bsc/bsc099349/.local/bin:/home/bsc/bsc099349/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin



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

    nohup singularity run --nv --no-home \
        --bind $JOB_PATH:/home/bsc/$USER \
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

    # export VLLM_LOGGING_LEVEL=DEBUG
    # export VLLM_TRACE_FUNCTION=1
    # export CUDA_LAUNCH_BLOCKING=1
    # export NCCL_DEBUG=TRACE

    head_node=$(scontrol show hostname | head -n 1)
    worker_nodes=$(scontrol show hostname | grep -v "$head_node")
    
    head_node_port=6379
    ip_addr=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address)
    ip_head=$ip_addr:$head_node_port

    singularity exec --nv --no-home --bind $JOB_PATH:/home/bsc/$USER $GPFS_VLLM_SINGULARITY ray stop
    #export VLLM_PORT=$head_node_port
    #export VLLM_HOST_IP=$ip_addr
    
    # Start Ray head node on the first node (head node)
    echo "Starting head on $head_node with IP $ip_addr"

    srun --nodes=1 --ntasks=1 --nodelist=$head_node singularity exec --nv --no-home \
        --bind $JOB_PATH:/home/bsc/$USER \
        --bind $GPFS_MODELS_REGISTRY_PATH:/$dir \
        --env HOST_IP=$ip_addr \
        --env VLLM_HOST_IP=$ip_addr \
        $GPFS_VLLM_SINGULARITY ray start --block --head --port=$head_node_port &

    sleep 10

    # Start Ray worker nodes on all other nodes (excluding the head node)
    for node in $worker_nodes; do
        worker_ip=$(srun --nodes=1 --ntasks=1 -w "$node" hostname --ip-address)
        # Export the VLLM_HOST_IP for this worker node
        echo "Starting worker on $node with IP $worker_ip"
        
        srun --nodes=1 --ntasks=1 --nodelist="$node" singularity exec --nv --no-home \
        --bind $JOB_PATH:/home/bsc/$USER \
        --bind $GPFS_MODELS_REGISTRY_PATH:/$dir \
        --env HOST_IP=$worker_ip \
        --env VLLM_HOST_IP=$worker_ip \
        $GPFS_VLLM_SINGULARITY ray start --block --address $ip_head &
        
        sleep 5
    done

    sleep 20
    echo "======================Ray Status==========================="
    singularity exec --nv --no-home --bind $JOB_PATH:/home/bsc/$USER --bind $GPFS_MODELS_REGISTRY_PATH:/$dir $GPFS_VLLM_SINGULARITY ray status
    echo "==========================================================="

    nohup singularity run --nv --no-home \
        --bind $JOB_PATH:/home/bsc/$USER \
        --bind $GPFS_MODELS_REGISTRY_PATH:/$dir \
        --env HOST_IP=$ip_addr \
        --env VLLM_HOST_IP=$ip_addr \
        $GPFS_VLLM_SINGULARITY  \
        --model /$MODEL_NAME \
        --served-model-name $GPFS_VLLM_MODEL "tgi" \
        --host 0.0.0.0 \
        --port 8080 \
        --tensor-parallel-size $SLURM_GPUS_ON_NODE \
        --pipeline-parallel-size $SLURM_JOB_NUM_NODES $(echo $JOB_VLLM_PARAMS) > $JOB_PATH/logs/vllm.log 2>&1 &

fi
