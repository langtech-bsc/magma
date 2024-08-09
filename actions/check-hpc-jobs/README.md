# Check hpc jobs

### Inputs

| variable | description|
|----|------------|
| job_id | Id of the job to check |
| job_name | Name of the jobs to check |
| remote_user | Remote user |
| remote_host | Remote host |


### Outputs
| variable | description|
|----|------------|
| exists | Whether the job exists or not |
| jobs | All running jobs id |



## Usage

```
    steps:

    - uses: webfactory/ssh-agent@v0.9.0
      with:
        ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

    - name: check if job exists
      id: job_exists
      uses: langtech-bsc/magma/check-hpc-jobs@main
      with:
        job_name: ${{ steps.job_variables.outputs.job_name}}
        remote_user: ${{ secrets.REMOTE_USER}}
        remote_host: ${{ secrets.REMOTE_HOS`}}
```