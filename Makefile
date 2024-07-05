#===========Workflows========================


#===========TEST workflows===================
test-workflow-enhanced-launch-job:
	act -j test-workflow-enhanced-launch-job-and-docker \
	 -W .github/workflows/test_workflow_enhanced_launch_job.yml \
	 --secret-file my.secrets \
	 --var-file .env \
	 --no-cache-server \
	 --container-architecture linux/amd64 \
	 --pull=true -P magma-runner-set=projecteaina/actions-runner:latest -P shell=catthehacker/ubuntu:act-22.04

test-workflow-enhanced-launch-job-and-docker:
	act -j test-workflow-enhanced-launch-job \
	 -W .github/workflows/test_workflow_enhanced_launch_job_and_docker.yml \
	 --secret-file my.secrets \
	 --var-file .env \
	 --no-cache-server \
	 --container-architecture linux/amd64 \
	 --pull=true -P magma-runner-set=projecteaina/actions-runner:latest

test-workflow-launch-job:
	act -j test-workflow-launch-job \
	 -W .github/workflows/test_workflow_launch_job.yml \
	 --secret-file my.secrets \
	 --var-file .env \
	 --no-cache-server \
	 --container-architecture linux/amd64 \
	 --pull=true -P magma-runner-set=projecteaina/actions-runner:latest


test-workflow-remote-job:
	act -j complete \
	 -W .github/workflows/test_workflow_remote_job.yml \
	 --secret-file my.secrets \
	 --var-file .env \
	 --no-cache-server \
	 --container-architecture linux/amd64 \
	 --pull=true -P magma-runner-set=projecteaina/actions-runner:latest -P shell=catthehacker/ubuntu:act-22.04

#===========TEST actions===================
test-action-addons:
	act -j test-action-addons \
	 -W .github/workflows/test_action_addons.yml \
	 --secret-file my.secrets \
	 --var-file .env \
	 --no-cache-server \
	 --container-architecture linux/amd64 \
	 --pull=true -P magma-runner-set=projecteaina/actions-runner:latest
	 
test-action-install-python-apt-singularity:
	act -j test-action-install-python-apt-singularity \
	 -W .github/workflows/test_action_install-python-apt-singularity.yml \
	 --secret-file my.secrets \
	 --var-file .env \
	 --no-cache-server \
	 --container-architecture linux/amd64 \
	 --pull=true -P magma-runner-set=projecteaina/actions-runner:latest