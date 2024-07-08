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

# Load environment variables and modules
source "$JOB_PATH/remote_job.env"
module load singularity

# Define paths and variables
IMAGES_PATH="$REMOTE_JOB_PATH"
IMAGE="$REMOTE_JOB_IMAGE"
OLD_IMAGE="$REMOTE_JOB_OLD_IMAGE"
REQUIREMENTS_PATH="$REMOTE_JOB_REQUIREMENTS_PATH"
TMP_IMAGE="${REMOTE_JOB_IMAGE//\//_}_sandbox"

# Create or move the sandbox image
if [ -f "$IMAGES_PATH/$OLD_IMAGE" ]; then
    echo "Build sandbox from singularity"
    singularity build --sandbox "$TMP_IMAGE" "$IMAGES_PATH/$OLD_IMAGE"
elif [ -d "$IMAGES_PATH/$OLD_IMAGE" ]; then
    echo "Copy sandbox"
    cp -r "$IMAGES_PATH/$OLD_IMAGE" "$TMP_IMAGE"
else
    echo "Not a sandbox or singularity"
    exit 1
fi

# Display variables
cat <<EOF
Variables:
    IMAGES_PATH: $IMAGES_PATH
    IMAGE: $IMAGE
    REQUIREMENTS_PATH: $REQUIREMENTS_PATH
    TMP_IMAGE: $TMP_IMAGE
EOF

# Create requirements directory and install dependencies
singularity exec --contain -w --no-home "$TMP_IMAGE" /bin/sh -c 'mkdir -p /requirements'
singularity exec --contain -w --no-home --bind "$REQUIREMENTS_PATH/requirements:/requirements" "$TMP_IMAGE" /bin/sh -c 'export TMPDIR=/tmp && pip install -r /requirements/toinstall.txt --no-index --force-reinstall --find-links=/requirements/'


# Check for errors in the log file
if grep -q "^ERROR:" "$JOB_LOGS_PATH/error.log"; then
    echo "An error was detected"
    grep "^ERROR:" "$JOB_LOGS_PATH/error.log"
    rm -rf $TMP_IMAGE
    exit 1
fi

# Convert the sandbox to a SIF file if it was built
if [ -f "$IMAGES_PATH/$OLD_IMAGE" ]; then
    echo "Build singularity from sandbox"
    NEW_NAME="${TMP_IMAGE}.sif"
    singularity build --force "$NEW_NAME" "$TMP_IMAGE"
    rm -rf "$TMP_IMAGE"
    TMP_IMAGE="$NEW_NAME"
fi

# Move the new image to the images path
mv "$TMP_IMAGE" "$IMAGES_PATH/$IMAGE"
# rm -rf "$REQUIREMENTS_PATH/requirements"
