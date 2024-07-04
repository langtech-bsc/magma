#!/bin/bash
#SBATCH --job-name=%JOB_NAME%
#SBATCH --output=%JOB_LOGS_PATH%/output.log
#SBATCH --error=%JOB_LOGS_PATH%/error.log
#SBATCH --time=00-4:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --qos=gp_bscls
#SBATCH --partition=gpp
#SBATCH --nodes=1


source $JOB_PATH/remote_job.env

IMAGES_PATH=$REMOTE_JOB_PATH
IMAGE=$REMOTE_JOB_IMAGE
DOCKER_TAR_PATH=$REMOTE_JOB_DOCKER_TAR_PATH
SANDBOX=$REMOTE_JOB_SANDBOX
TAR_NAME=$(echo $IMAGE | sed 's/\//_/g')

module load singularity

echo "IMAGES_PATH: $IMAGES_PATH"
echo "IMAGE: $IMAGE"
echo "DOCKER_TAR_PATH: $DOCKER_TAR_PATH"
echo "SANDBOX: $SANDBOX"
echo "TAR_NAME: $TAR_NAME"

mkdir -p $IMAGES_PATH/$IMAGE


if [ $SANDBOX ]; then
    echo "Building sandbox"
    singularity build -F -s $IMAGES_PATH/$IMAGE docker-archive:$DOCKER_TAR_PATH/$TAR_NAME.tar
else
    echo "Building singularity"
    singularity build -F $IMAGES_PATH/$IMAGE docker-archive:$DOCKER_TAR_PATH/$TAR_NAME.tar
fi

rm $DOCKER_TAR_PATH/$TAR_NAME.tar