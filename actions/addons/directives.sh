umask u=rwx,g=rwx,o=
module load singularity/4.1.5
# module load cuda/12.3 #It may not work, so remove if gives any errors.

set -e
set -a
source %JOB_PATH%/job.env
set +a
