#!/bin/bash
#SBATCH --account=bsc88
#SBATCH --job-name=VLLM
#SBATCH --output=logs/output.log
#SBATCH --error=logs/error.log
#SBATCH --qos=acc_bscls
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=80
#SBATCH --gres=gpu:4
#SBATCH --nodes=2
#SBATCH --time=00-00:15:00
#SBATCH --exclusive

SINGULARITY_IMAGE=/path/to/your/singularity/vllm-openai-latest.sif
#To create singularity you can convert any docker file from vllm. E,g. 'FROM vllm/vllm-openai:v0.5.5'

module load singularity
export SRUN_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
export SLURM_CPU_BIND=none

head_node=$(scontrol show hostname | head -n 1)
head_node_port=6379
ip_head=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address):$head_node_port

singularity exec --nv $SINGULARITY_IMAGE ray stop

# Start Ray head node on the first node (head node)
echo "Run --head"
srun --nodes=1 --ntasks-per-node=1 --nodelist=$head_node \
    singularity exec --nv --bind /gpfs/projects/bsc88/hf-models/:/data $SINGULARITY_IMAGE ray start --block --head --port=$head_node_port &


sleep 10
# Start Ray worker nodes on all other nodes (excluding the head node)
srun --nodes=$((SLURM_JOB_NUM_NODES - 1)) --ntasks-per-node=1 --exclude=$head_node \
    singularity exec --nv --bind /gpfs/projects/bsc88/hf-models/:/data $SINGULARITY_IMAGE ray start --block --address $ip_head &


sleep 20
echo "======================Ray Status==========================="
singularity exec --nv $SINGULARITY_IMAGE ray status
echo "==========================================================="

singularity run --nv \
    --bind /gpfs/projects/bsc88/hf-models/:/data  \
    $SINGULARITY_IMAGE  \
    --model /data/Mixtral-8x7B-Instruct-v0.1 \
    --host 0.0.0.0 \
    --port 8080 \
    --tensor-parallel-size $((SLURM_JOB_NUM_NODES * SLURM_GPUS_ON_NODE))
