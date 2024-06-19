#!/bin/bash
#SBATCH --job-name=%JOB_NAME%
#SBATCH --output=%JOB_PATH%/logs/output.log
#SBATCH --error=%JOB_PATH%/logs/error.log
#SBATCH --time=00-1:00:00
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --qos=acc_bscls
#SBATCH --partition=acc

# --- IMPORTANT: DO NOT DELETE OR MODIFY THE FOLLOWING LINE ---
module load singularity
source %JOB_PATH%/job.env
JOB_LOGS_PATH="$JOB_PATH/logs/"
# Special code section
# --- IMPORTANT: DO NOT DELETE OR MODIFY THE ABOVE LINE ---

# Your existing code here
echo "Launch python script"
singularity exec --nv --no-home --pwd /src --bind $JOB_PATH:/src --bind /gpfs:/gpfs $GPFS_SINGULARITY_IMAGE_REGISTRY_PATH/python-jupyter.sif python code/script.py > $JOB_LOGS_PATH/script.log 2>&1