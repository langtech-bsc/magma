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
OLD_IMAGE=$REMOTE_JOB_OLD_IMAGE
REQUIREMENTS_PATH=$REMOTE_JOB_REQUIREMENTS_PATH
TMP_IMAGE=$(echo $REMOTE_JOB_IMAGE | sed 's/\//_/g')
TMP_IMAGE=${TMP_IMAGE}_sandbox

echo "IMAGES_PATH: $IMAGES_PATH"
echo "IMAGE: $IMAGE"
echo "OLD_IMAGE: $OLD_IMAGE"
echo "REQUIREMENTS_PATH: $REQUIREMENTS_PATH"

# mkdir -p $IMAGES_PATH


if [ -f $IMAGES_PATH/$OLD_IMAGE ]; then
    echo "Build sandbox from singularity"
    SANDBOX="true"
    singularity build --sandbox $TMP_IMAGE $IMAGES_PATH/$OLD_IMAGE
elif [ -d $IMAGES_PATH/$OLD_IMAGE ]; then
    echo "Move sandbox"
    cp -r $IMAGES_PATH/$OLD_IMAGE $TMP_IMAGE
else
    echo "Not a sandbox or singularity"
    exit 1
fi

echo "Variables
echo "\tIMAGES_PATH: $IMAGES_PATH"
echo "\tIMAGE: $IMAGE"
echo "\tREQUIREMENTS_PATH: $REQUIREMENTS_PATH"
echo "\tSANDBOX: $SANDBOX"
echo "\tTMP_IMAGE: $TMP_IMAGE"

echo ""
echo "Create requirementes dir"
singularity exec --contain -w --no-home $TMP_IMAGE /bin/sh -c 'mkdir -p /requirements'

echo "Install dependecies"
singularity exec -w --contain --no-home --bind $REQUIREMENTS_PATH/requirements:/requirements $TMP_IMAGE /bin/sh -c  'export TMPDIR=/tmp && pip install --force-reinstall /requirements/*'

if [ "$SANDBOX" = "true" ]; then
    echo "Build singularity from sandbox"

    NEW_NAME=${TMP_IMAGE}.sif
    singularity build --force $NEW_NAME $TMP_IMAGE
    rm -rf $TMP_IMAGE
    TMP_IMAGE=$NEW_NAME
fi

touch $JOB_LOGS_PATH/error.log
if grep -q "^ERROR:" "$JOB_LOGS_PATH/error.log"; then
    echo "An error was detected"
    grep "^ERROR:" "$JOB_LOGS_PATH/error.log"
    exit 1
fi

echo "Move singularity with new image name"
mv $TMP_IMAGE $IMAGES_PATH/$IMAGE
rm -r $REQUIREMENTS_PATH/requirements