model_name=$JOB_FINETUNE_OUTPUT_MODEL_NAME

export WANDB_PROJECT="instruction-tuning"
export WANDB_NAME="${model_name}_${SLURM_JOBID}"
export WANDB_MODE=offline
export WANDB_INIT_TIMEOUT=600
export PATH_RESULTS=${GPFS_FINETUNE_MODELS_REGISTRY_PATH}/${model_name}
export WANDB_DIR=$PATH_RESULTS
export WANDB_CONFIG_DIR=$WANDB_DIR/config
mkdir -p $WANDB_DIR

export WORLD_SIZE=$SLURM_NTASKS
export MASTER_PORT=29403
head_node=$( scontrol show hostname ${SLURM_NODELIST} | head -n 1)
head_node_ip=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address)
export MASTER_ADDR=$head_node_ip


export SLURM_CPU_BIND=none # Required for mp.

cat << EOF
xxxxxxxxxxxxxxxxxxxxxxxxxxxx
master addr: ${MASTER_ADDR}
master port: ${MASTER_PORT}
word size: ${WORLD_SIZE}
num nodes: ${SLURM_NNODES}
xxxxxxxxxxxxxxxxxxxxxxxxxxxx
EOF

#train <=> python -m fastchat.train.train
srun singularity exec --nv /gpfs/projects/bsc88/singularity-images/fastchat-pytorch.sif bash <<EOF
export LOCAL_RANK=\$SLURM_LOCALID
export RANK=\$SLURM_PROCID
python -m fastchat.train.train \
    %FINETUNE_PARAMS%
    --output_dir $PATH_RESULTS \
    --report_to wandb
EOF