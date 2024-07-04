#!/bin/bash
#SBATCH --job-name=%JOB_NAME%
#SBATCH --output=%JOB_LOGS_PATH%/output.log
#SBATCH --error=%JOB_LOGS_PATH%/error.log
#SBATCH --time=00-4:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --qos=gp_bscls
#SBATCH --partition=gpp
#SBATCH --node=1

PATH=$REMOTE_JOB_PATH
NAME=$REMOTE_JOB_NAME
DOCKER_TAR_PATH=$REMOTE_JOB_DOCKER_TAR_PATH

module load singularity

mkdir -p $PATH

if [ $SANDBOX ]; then
    singularity build $PATH/$NAME docker-archive:$DOCKER_TAR_PATH
else
    singularity build -s $PATH/$NAME docker-archive:$DOCKER_TAR_PATH
fi