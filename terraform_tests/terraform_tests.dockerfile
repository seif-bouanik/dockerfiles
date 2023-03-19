FROM debian:stable-slim
LABEL maintainer=${MAINTAINER}

ARG TERRAFORM_VERSION=1.3.9
ARG TERRAGRUNT_VERSION=0.43.2
ARG PYTHON_VERSION=python3.9
ARG MAINTAINER="Seif"
#-------------------------------------
# UPDATE
#-------------------------------------
RUN apt-get update -y && \
	apt-get install --no-install-recommends unzip wget curl ${PYTHON_VERSION} python3-pip git-all jq -y && \
	rm -rf /var/lib/apt/lists/*
#-------------------------------------
# INSTALL PACKAGES
#-------------------------------------
# TERRAFORM & TERRAGRUNT
RUN wget --no-check-certificate https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
	https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
	rm  terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
	# Move to local bin
	mv terraform /usr/local/bin/ && \
	mv terragrunt_linux_amd64 /usr/local/bin/terragrunt && \
	# Make it executable
	chmod +x /usr/local/bin/terraform && \
	chmod +x /usr/local/bin/terragrunt

# CHECKOV
RUN pip3 --no-cache-dir install checkov

# TFLINT & TFSEC
RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash && \ 
	curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \ 
	unzip awscliv2.zip && \
	./aws/install

# SPECIFYING THE SHELL
ENTRYPOINT ["/bin/bash", "-l", "-c", "/bin/bash"]