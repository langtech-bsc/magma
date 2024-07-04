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
module load singularity

IMAGES_PATH=$REMOTE_JOB_PATH
IMAGE=$REMOTE_JOB_IMAGE
REQUIREMENTS_PATH=$REMOTE_JOB_REQUIREMENTS_PATH
SANDBOX=false

mkdir -p $IMAGES_PATH

TMP_NAME=$IMAGE
if [ -f $IMAGES_PATH/$IMAGE ]; then
    SANDBOX=true
    TMP_NAME=${IMAGE}_sandbox
    sudo singularity build --sandbox $TMP_NAME $IMAGE
fi

echo "IMAGES_PATH: $IMAGES_PATH"
echo "IMAGE: $IMAGE"
echo "REQUIREMENTS_PATH: $REQUIREMENTS_PATH"
echo "SANDBOX: $SANDBOX"
echo "TMP_NAME: $TMP_NAME"

singularity exec --contain -w --no-home $IMAGES_PATH/$TMP_NAME /bin/sh -c 'mkdir -p /requirements'
singularity exec -w --contain --no-home --bind $REQUIREMENTS_PATH/requirements:/requirements $IMAGES_PATH/$TMP_NAME /bin/sh -c  'export TMPDIR=/tmp && pip install --force-reinstall /requirements/*'

if [ -z $SANDBOX ]; then
    sudo singularity build --force $IMAGE $TMP_NAME
    rm -rf $TMP_NAME
fi

rm -r $REQUIREMENTS_PATH/requirements