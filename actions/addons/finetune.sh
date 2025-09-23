model_name=$JOB_FINETUNE_OUTPUT_MODEL_NAME
export TRITON_CACHE_DIR="${JOB_PATH}/.triton"
export PATH_RESULTS=${GPFS_FINETUNE_MODELS_REGISTRY_PATH}/${model_name}
# export WANDB_PROJECT="instruction-tuning"
# export WANDB_NAME="${model_name}_${SLURM_JOBID}"
# export WANDB_MODE=offline
# export WANDB_INIT_TIMEOUT=600
# export WANDB_DIR=$PATH_RESULTS
# export WANDB_CONFIG_DIR=$WANDB_DIR/config
# mkdir -p $WANDB_DIR

#export MLFLOW_EXPERIMENT_NAME="${model_name}_${SLURM_JOBID}"
export MLFLOW_TRACKING_URI="file://$JOB_LOGS_PATH/mlflow"
export MLFLOW_FLATTEN_PARAMS="1"
export MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING="1"
#export MLFLOW_RUN_ID="0"
#export MLFLOW_NESTED_RUN="0"
#export MLFLOW_EXPERIMENT_ID="0"

export WORLD_SIZE=$SLURM_NTASKS
export MASTER_PORT=29403
head_node=$( scontrol show hostname ${SLURM_NODELIST} | head -n 1)
head_node_ip=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address)
export MASTER_ADDR=$head_node_ip


export SLURM_CPU_BIND=none # Required for mp.
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

cat << EOF
xxxxxxxxxxxxxxxxxxxxxxxxxxxx
master addr: ${MASTER_ADDR}
master port: ${MASTER_PORT}
word size: ${WORLD_SIZE}
num nodes: ${SLURM_NNODES}
xxxxxxxxxxxxxxxxxxxxxxxxxxxx
EOF
#mkdir -p $JOB_LOGS_PATH/finetune
#echo "You can find all outputs log here: %JOB_LOGS_PATH%/finetune/"

#train <=> python -m fastchat.train.train
#--output=%JOB_LOGS_PATH%/finetune/output_%t.log \
#--error=%JOB_LOGS_PATH%/finetune.err \
srun singularity exec --nv \
--bind /gpfs/projects/bsc88/mlops/FastChat/fastchat:/FastChat/fastchat $GPFS_FINETUNE_SINGULARITY bash <<EOF
export LOCAL_RANK=\$SLURM_LOCALID
export RANK=\$SLURM_PROCID
python -m fastchat.train.train_mem \
    %FINETUNE_PARAMS%
    --output_dir $PATH_RESULTS \
    --run_name $(basename "$PATH_RESULTS") \
    --report_to mlflow
EOF
