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
SANDBOX=$REMOTE_JOB_SANDBOX
REQUIREMENTS_PATH=$REMOTE_JOB_REQUIREMENTS_PATH

TMP_NAME=$NAME

module load singularity
mkdir -p $PATH

if [ -z $SANDBOX ]; then
    TMP_NAME=${NAME}_sandbox
    sudo singularity build --sandbox $TMP_NAME $NAME

fi

singularity exec --contain -w --no-home $PATH/$TMP_NAME /bin/bash -c 'mkdir -p /requirements'
singularity exec -w --no-home --bind $REQUIREMENTS_PATH:/requirements $PATH/$TMP_NAME /bin/bash -c  'export TMPDIR=/tmp && pip install --force-reinstall /requirements/*.whl /requirements/*.tar.gz'

if [ -z $SANDBOX ]; then
    sudo singularity build --force $NAME $TMP_NAME
    rm -f $TMP_NAME
fi