umask u=rwx,g=rwx,o=
module load singularity
# module load cuda/12.3 #It may not work, so remove if gives any errors.
export SINGULARITYENV_LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/.singularity.d/libs:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/2023.2.0/linux/compiler/lib/intel64_lin/                    
export SINGULARITYENV_PATH=/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin/intel64:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/compiler/latest/linux/bin/intel64:/apps/ACC/UCX/1.15.0/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/mpi/2021.10.0/libfabric/bin:/gpfs/apps/MN5/GPP/ONEAPI/2023.2.0/mpi/2021.10.0/bin:/gpfs/projects/bsc88/text/environments/openai_mn5_python3.9_20253101/bin:/apps/GPP/SINGULARITY/extras:/apps/GPP/SINGULARITY/3.11.5/bin:/apps/GPP/ANACONDA/2023.07/bin:/apps/GPP/ANACONDA/2023.07/condabin:/home/bsc/bsc088851/.local/bin:/home/bsc/bsc088851/bin:/apps/modules/bsc/bin:/home/bsc/bsc099349/.local/bin:/home/bsc/bsc099349/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

set -e
set -a
source %JOB_PATH%/job.env
set +a
