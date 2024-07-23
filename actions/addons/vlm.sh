echo "Launch vllm endpoint"
nohup singularity run --nv \
    --bind $GPFS_MODELS_REGISTRY_PATH:/data  \
    $GPFS_SINGULARITY_IMAGE_REGISTRY_PATH/vllm-inference.sif  \
    --model /data/Mistral-7B-v0.1 \
    --host 0.0.0.0 \
    --port 8080 $(echo $JOB_TGI_PARAMS) > $JOB_PATH/logs/vllm.log 2>&1