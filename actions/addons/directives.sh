umask u=rwx,g=rwx,o=
module load singularity
# module load cuda/12.3 #It may not work, so remove if gives any errors.
set -x -e
set -a
source %JOB_PATH%/job.env
set +a
