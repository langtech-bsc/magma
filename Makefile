#===========Workflows========================


#===========TEST workflows===================
run-gh-run-test-workflow-job-enhanced-launch-job:
	act -j test-workflow-job-enhanced-launch-job \
	 -W .github/workflows/test_workflow_enhanced_launch_job.yml \
	 --secret-file my.secrets \
	 --var-file .env \
	 --no-cache-server \
	 --container-architecture linux/amd64 \
	 --pull=true -P magma-runner-set=projecteaina/actions-runner:latest

#===========TEST actions===================
run-gh-run-test-action-addons:
	act -j test-action-addons \
	 -W .github/workflows/test_action_addons.yml \
	 --secret-file my.secrets \
	 --var-file .env \
	 --no-cache-server \
	 --container-architecture linux/amd64 \
	 --pull=true -P magma-runner-set=projecteaina/actions-runner:latest