FROM ghcr.io/actions/actions-runner:2.323.0

USER root

RUN apt-get update && apt-get install -y \
   curl \
   openssh-client \
   rsync \
   python-is-python3 \
   python3-pip \
   && rm -rf /var/lib/apt/lists/

USER runner

#Install node
RUN curl -sS https://webi.sh/node@lts | sh
RUN rm -rf /home/runner/Downloads/webi

ENV PATH "$PATH:/home/runner/.local/opt/node/bin"
ENV PATH "$PATH:/home/runner/.local/bin"

# Install python dependencies
RUN python3 -m pip install --upgrade pip

RUN pip install --user hpc-rocket==0.6.1 mlflow==2.14.1 sysrsync==1.1.1 python-dotenv 1.1.0 --no-cache-dir

