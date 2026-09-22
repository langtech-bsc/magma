#!/bin/bash
#SBATCH --job-name=%JOB_NAME%
#SBATCH --output=%JOB_LOGS_PATH%/output.log
#SBATCH --error=%JOB_LOGS_PATH%/error.log
#SBATCH --time=00-2:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --qos=gp_bscaii
#SBATCH --nodes=1

set -e
cd  $JOB_PATH
source $JOB_PATH/remote_job.env
export SINGULARITY_CACHEDIR=$JOB_PATH/.singularity

IMAGES_PATH=$REMOTE_JOB_PATH
#IMAGE=$(echo "$REMOTE_JOB_IMAGE" | sed 's/req_.*/req_null/') 
IMAGE=$REMOTE_JOB_IMAGE
DOCKER_TAR_PATH=$REMOTE_JOB_DOCKER_TAR_PATH
SANDBOX=$REMOTE_JOB_SANDBOX
TAR_NAME=$(echo $REMOTE_JOB_IMAGE | sed 's/\//_/g')
LDCONFIG=$REMOTE_JOB_LDCONFIG

# Al construir un SIF sin root, Singularity pone todos los ficheros a nombre de root (-all-root),
# asi que dentro del contenedor cualquier usuario entra como "otros". Esta funcion da a "otros"
# lectura, escritura y entrada en directorios, y lectura/escritura (+ejecucion si ya era ejecutable)
# en ficheros. La escritura solo tiene efecto con --writable-tmpfs: el SIF sigue siendo de solo lectura.
fix_perms() {
    echo "Fixing permissions in $1..."
    find "$1" \
      \( -type d ! -perm -o=rwx -exec chmod o+rwx {} + \) -o \
      \( -type f \( ! -perm -o=rw -o \( -perm -u=x ! -perm -o=x \) \) -exec chmod o+rwX {} + \)
}

module load singularity

echo "IMAGES_PATH: $IMAGES_PATH"
echo "IMAGE: $IMAGE"
echo "DOCKER_TAR_PATH: $DOCKER_TAR_PATH"
echo "SANDBOX: $SANDBOX"
echo "TAR_NAME: $TAR_NAME"

if [ ! -f "$DOCKER_TAR_PATH/$TAR_NAME.tar" ]; then
    echo "Error: Docker tar file '$DOCKER_TAR_PATH/$TAR_NAME.tar' not found."
    exit 1
fi

if [[ "$IMAGE" == */* ]]; then
    # Extract the directory path by removing everything after the last '/'
    result="${IMAGE%/*}"
    # Create the directory if it doesn't already exist
    echo "Create dir: $result"
    mkdir -p "$IMAGES_PATH/$result"
fi

if [ "$LDCONFIG" = "true" ]; then
    echo "LDCONFIG..."
    singularity build -F -s ${TAR_NAME}_sandbox docker-archive:$DOCKER_TAR_PATH/$TAR_NAME.tar
    singularity exec -w ${TAR_NAME}_sandbox /bin/bash -c 'mkdir -p /apps'
    singularity exec --writable -B /apps ${TAR_NAME}_sandbox ldconfig /.singularity.d/libs
    if [ "$SANDBOX" = "true" ]; then
        mv ${TAR_NAME}_sandbox $TAR_NAME
    else
        fix_perms ${TAR_NAME}_sandbox   # nuevo
        singularity build -F $TAR_NAME ${TAR_NAME}_sandbox
        rm -rf ${TAR_NAME}_sandbox
    fi
    
elif  [ "$SANDBOX" = "true" ]; then
    echo "Building sandbox"
    singularity build -F -s $TAR_NAME docker-archive:$DOCKER_TAR_PATH/$TAR_NAME.tar
else
    # --- Version original (sin arreglo de permisos) ---
    # echo "Building singularity"
    # singularity build -F $TAR_NAME docker-archive:$DOCKER_TAR_PATH/$TAR_NAME.tar
    echo "Building singularity (sandbox -> fix_perms -> SIF)"
    singularity build -F -s ${TAR_NAME}_sandbox docker-archive:$DOCKER_TAR_PATH/$TAR_NAME.tar
    fix_perms ${TAR_NAME}_sandbox
    singularity build -F $TAR_NAME ${TAR_NAME}_sandbox
    rm -rf ${TAR_NAME}_sandbox
fi


rm -rf $SINGULARITY_CACHEDIR
mv $TAR_NAME $IMAGES_PATH/$IMAGE
# --- Version original ---
# chmod g+rwx -R $IMAGES_PATH/$IMAGE
# chown :$SLURM_JOB_ACCOUNT "$IMAGES_PATH/$IMAGE" # It works only for MN5.
chmod g+rwx -R $IMAGES_PATH/$IMAGE
chmod o-rwx -R $IMAGES_PATH/$IMAGE                  # nadie fuera del grupo
chown -R :$SLURM_JOB_ACCOUNT "$IMAGES_PATH/$IMAGE"  # It works only for MN5.
rm $DOCKER_TAR_PATH/$TAR_NAME.tar
echo "Image build done"
