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

nohup singularity run --nv \
    --bind $GPFS_MODELS_REGISTRY_PATH:/$dir  \
    $GPFS_VLLM_SINGULARITY  \
    --model /$MODEL_NAME \
    --served-model-name $GPFS_VLLM_MODEL \
    --host 0.0.0.0 \
    --port 8080 \
    --tensor-parallel-size $SLURM_GPUS_ON_NODE $(echo $JOB_VLLM_PARAMS) > $JOB_PATH/logs/vllm.log 2>&1 &
