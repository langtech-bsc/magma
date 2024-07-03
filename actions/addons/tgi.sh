echo "Launch tgi endpoint"
nohup singularity run --nv \
    --bind $GPFS_MODELS_REGISTRY_PATH:/data  \
    $GPFS_TGI_SINGULARITY  \
    --model-id /data/$GPFS_TGI_MODEL \
    --hostname 0.0.0.0 \
    --port 8080 $(echo $JOB_TGI_PARAMS) > $JOB_LOGS_PATH/tgi.log 2>&1 &