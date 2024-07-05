# Variables
ACT_CMD = act
COMMON_FLAGS = --secret-file my.secrets \
               --var-file .env \
               --no-cache-server \
               --container-architecture linux/amd64 \
               --pull=true \
               -P magma-runner-set=projecteaina/actions-runner:latest \
               -P shell=catthehacker/ubuntu:act-22.04


test-workflow-enhanced-launch-job:
	$(ACT_CMD) -j test-workflow-enhanced-launch-job -W .github/workflows/test_workflow_enhanced_launch_job.yml $(COMMON_FLAGS)

test-workflow-enhanced-launch-job-and-docker:
	$(ACT_CMD) -j test-workflow-enhanced-launch-job-and-docker -W .github/workflows/test_workflow_enhanced_launch_job_and_docker.yml $(COMMON_FLAGS)

test-workflow-launch-job:
	$(ACT_CMD) -j test-workflow-launch-job -W .github/workflows/test_workflow_launch_job.yml $(COMMON_FLAGS)

test-workflow-remote-job:
	$(ACT_CMD) -j complete -W .github/workflows/test_workflow_remote_job.yml $(COMMON_FLAGS)

test-action-addons:
	$(ACT_CMD) -j test-action-addons -W .github/workflows/test_action_addons.yml $(COMMON_FLAGS)

test-action-install-python-apt-singularity:
	$(ACT_CMD) -j test-action-install-python-apt-singularity -W .github/workflows/test_action_install-python-apt-singularity.yml $(COMMON_FLAGS)
