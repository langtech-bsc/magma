echo "Launching jupyter lab"
if [ -n "$GPFS_JUPYTER_WORKING_DIR" ]; then
    mkdir -p $GPFS_JUPYTER_WORKING_DIR
    BIND_WORKING_DIR="--bind $GPFS_JUPYTER_WORKING_DIR:/home/bsc/$USER/working_dir"
fi
source /gpfs/projects/bsc88/mlops/scripts/ienable.sh
singularity exec --nv --no-home \
    --bind /gpfs:/gpfs \
    --bind $JOB_PATH:/home/bsc/$USER \
    --bind $TMPDIR/.local:/home/bsc/$USER/.local \
    $BIND_WORKING_DIR \
    $GPFS_JUPYTER_SINGULARITY jupyter-lab \
    --notebook-dir=/home/bsc/$USER \
    --NotebookApp.token="" \
    --no-browser --ip=0.0.0.0 --port=8888 > $JOB_LOGS_PATH/jupyter.log 2>&1 &
