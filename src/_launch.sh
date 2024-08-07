
# Use $JOB_LOGS_PATH save logs
echo "Launch python script"
module load singularity
singularity exec --nv --no-home --pwd /src --bind $JOB_PATH:/src --bind /gpfs:/gpfs $GPFS_SINGULARITY_IMAGE_REGISTRY_PATH/python-jupyter.sif python code/script.py
