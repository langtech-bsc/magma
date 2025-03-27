export TRITON_CACHE_DIR="${JOB_PATH}/.triton"
export NUMBA_CACHE_DIR="${JOB_PATH}/cache_numba"

export HF_DATASETS_OFFLINE="1"
export HF_HOME=$GPFS_HF_HOME
export LD_LIBRARY_PATH=/apps/ACC/CUDA/12.3/targets/x86_64-linux/lib/stubs/:$LD_LIBRARY_PATH

export TORCHDYNAMO_SUPPRESS_ERRORS=True
export NUMEXPR_MAX_THREADS=64
export VLLM_CONFIG_ROOT=$TMPDIR
export VLLM_CACHE_ROOT=$TMPDIR
export OUTPUT_DIR=$JOB_PATH/harness_result
export OUTPUT_PATH=$OUTPUT_DIR/${JOB_HARNESS_EVAL_EXPERIMENT_NAME}_${SLURM_JOBID}.json
export OUTPUT_PATH=$OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# export WANDB_PROJECT="instruction-tuning"
# export WANDB_NAME="${model_name}_${SLURM_JOBID}"
# export WANDB_MODE=offline
# export WANDB_INIT_TIMEOUT=600
# export WANDB_DIR=$JOB_LOGS_PATH/wandb
# export WANDB_CONFIG_DIR=$WANDB_DIR/config
# mkdir -p $WANDB_DIR

export MLFLOW_EXPERIMENT_NAME="${JOB_HARNESS_EVAL_EXPERIMENT_NAME}" #_${SLURM_JOBID}
export MLFLOW_TRACKING_URI="file://$JOB_LOGS_PATH/mlflow"
export MLFLOW_FLATTEN_PARAMS="1"
export MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING="1"
#export MLFLOW_RUN_ID="0"
#export MLFLOW_NESTED_RUN="0"
#export MLFLOW_EXPERIMENT_ID="0"

singularity exec --nv $GPFS_HARNESS_EVAL_SINGULARITY bash <<EOF
accelerate launch -m lm_eval \
    --output_path ${OUTPUT_PATH} \
    --experiment_name ${MLFLOW_EXPERIMENT_NAME} \
    %HARNESS_EVAL_PARAMS%
    
EOF
