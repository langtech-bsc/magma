echo "Launch vllm endpoint"
nohup singularity run --nv \
    --bind $GPFS_MODELS_REGISTRY_PATH:/data  \
    $GPFS_VLLM_SINGULARITY  \
    --model /data/$GPFS_VLLM_MODEL \
    --host 0.0.0.0 \
    --port 8080 $(echo $JOB_VLLM_PARAMS) > $JOB_PATH/logs/vllm.log 2>&1 &