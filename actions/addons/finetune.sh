bash /gpfs/scratch/bsc88/virtual-environments/activate-fastchat.sh
model_name=$JOB_OUTPUT_MODEL_NAME

export WANDB_PROJECT="instruction-tuning"
export WANDB_NAME="${model_name}_${SLURM_JOBID}"
export WANDB_MODE=offline
export WANDB_INIT_TIMEOUT=600
export PATH_RESULTS=${GPFS_FINETUNE_MODELS_REGISTRY_PATH}/${model_name}
export WANDB_DIR=$PATH_RESULTS
export WANDB_CONFIG_DIR=$WANDB_DIR/config
mkdir -p $WANDB_DIR

export GPUS_PER_NODE=$SLURM_GPUS #4
export NNODES=$SLURM_NNODES
export WORLD_SIZE=$(($GPUS_PER_NODE*$NNODES))
export MASTER_PORT=29403
head_node=$( scontrol show hostname ${SLURM_NODELIST} | head -n 1)
head_node_ip=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address)
export MASTER_ADDR=$head_node_ip



export SLURM_CPU_BIND=none
DIST_ARGS="
 --nproc_per_node=$GPUS_PER_NODE \
 --nnodes=$NNODES \
 --rdzv_id=$SLURM_JOB_ID \
 --rdzv_backend=c10d \
 --rdzv_endpoint=$MASTER_ADDR:$MASTER_PORT \
 "

cat << EOF
xxxxxxxxxxxxxxxxxxxxxxxxxxxx
slurm cpu bind: $SLURM_CPU_BIND
slurm cpu on node: $SLURM_CPUS_ON_NODE
slurm gpu per node: $GPUS_PER_NODE
slurm cpus per gpu: $SLURM_CPUS_PER_GPU
master addr: ${MASTER_ADDR}
master port: ${MASTER_PORT}
num nodes: ${NNODES}
DIST ARGS: $DIST_ARGS
xxxxxxxxxxxxxxxxxxxxxxxxxxxx
EOF

srun torchrun $DIST_ARGS -m fastchat.train.train --output_dir $PATH_RESULTS \
    %FINETUNE_PARAMS%
    --report_to 'wandb'