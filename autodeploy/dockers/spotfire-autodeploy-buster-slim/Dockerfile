# TIBCO Spotfire Deployment manager

# https://hub.docker.com/_/debian
# FROM debian:buster-slim

# https://hub.docker.com/_/python
FROM python:3.9.5-slim-buster

ARG DEBIAN_FRONTEND=noninteractive

# Sofware versions as 2021-06-01 (remove if needed)
# https://releases.hashicorp.com/terraform/
ARG TERRAFORM_VERSION="0.15.4"
# https://pypi.org/project/ansible/
# very big package, ~450M
#ARG ANSIBLE_VERSION="4.0.0"
#ARG ANSIBLE_VERSION="3.4.0"
ARG ANSIBLE_VERSION="2.10.7"

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
# note it depends on python3.7
#ARG AZCLI_VERSION="2.24.1-1~buster"

ENV TERRAFORM_VERSION=$TERRAFORM_VERSION
ENV ANSIBLE_VERSION=$ANSIBLE_VERSION
#ENV AZCLI_VERSION=$AZCLI_VERSION

# avoid installing recommended or suggested packages, for minimal docker image
RUN apt-config dump \
    | grep -we Recommends -e Suggests \
    | sed s/1/0/ \
    | tee /etc/apt/apt.conf.d/999norecommend

# Install common tools
RUN apt-get update && apt-get upgrade -y \
  && apt-get install -y gnupg software-properties-common curl openssh-client sshpass \
  && apt-get clean

# Install Azure CLI
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
#RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg \
  && apt-add-repository "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ buster main" \
  && apt-get update \
  && apt-get install -y azure-cli \
  && apt-get clean
#  && apt-get install -y azure-cli=$AZCLI_VERSION \

# Install Terraform
# https://learn.hashicorp.com/tutorials/terraform/install-cli
#  && apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
  && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" \
  && apt-get update \
  && apt-get install -y terraform=$TERRAFORM_VERSION \
  && apt-get clean

# Install dev tools
RUN apt-get install -y git make vim-tiny \
  && apt-get clean

# Run as spotfire
RUN useradd -m -s /bin/bash spotfire
USER spotfire
ENV PATH="/home/spotfire/.local/bin:${PATH}"

# Install ansible and required ansible community modules as <user>
# https://pypi.org/project/ansible/#history
# https://docs.ansible.com/ansible/devel/porting_guides/porting_guides.html
# https://docs.ansible.com/ansible/latest/galaxy/user_guide.html
# https://docs.ansible.com/ansible/latest/reference_appendices/python_3_support.html
RUN python3 -m pip install --upgrade pip setuptools wheel \
  && python3 -m pip install "ansible==${ANSIBLE_VERSION}" \
  && ansible-galaxy collection install community.windows \
  && python3 -m pip cache purge

# Install Azure Collection
# https://github.com/ansible-collections/azure
# https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html
RUN curl https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt > /tmp/requirements-azure.txt \
  && python3 -m pip install -r /tmp/requirements-azure.txt \
  && ansible-galaxy collection install azure.azcollection \
  && python3 -m pip cache purge

# default ansible environment configuration
COPY --chown=spotfire files/ansible.cfg /home/spotfire/.ansible.cfg

# Pass the local SSH keys as environment when running the container.
#     -e SSH_PUB_KEY=\"$(cat ~/.ssh/id_rsa.pub)\" -e SSH_PRIV_KEY=\"$(cat ~/.ssh/id_rsa)\"
# NOTE: The keys are only in the running container, not stored in the built image.
COPY --chown=spotfire files/entrypoint.sh /home/spotfire/entrypoint.sh

WORKDIR /home/spotfire/sandbox/terraform/azure

#CMD ["/bin/bash"]
ENTRYPOINT ["/home/spotfire/entrypoint.sh"]
