# FROM dsescontainerregistry.azurecr.us/mdsota/runner/infrastructure:0.1.2
# USER root
###need to run 'git config --global http.sslBackend gnutls' if "fatal: Unsupported SSL backend 'openssl'. Supported SSL backends: gnutls" prevents from pushing to repo.

ARG VARIANT="6.0-bullseye-slim"
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:0-${VARIANT}

RUN echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

RUN apt-get update && apt-get install -y -q \
	software-properties-common \
	apt-transport-https \
	ca-certificates \
	gnupg \
	curl

# Add Node JS Current
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -

# Azure Function V4
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
RUN sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
RUN sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/debian/$(lsb_release -rs | cut -d'.' -f 1)/prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'

# Kubectl
RUN sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Helm
RUN curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
RUN echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
RUN sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Golang
RUN wget https://golang.org/dl/go1.18.2.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz
RUN rm go1.18.2.linux-amd64.tar.gz

# Install Debian packages
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y -q --no-install-recommends  \
	gettext-base \
	tshark \
	azure-cli \
	azure-functions-core-tools-4 \
	msodbcsql18 \
	mssql-tools18 \
	git \
	python3 \
	python3-pip \
	nodejs \
	kubectl \
	helm \
	terraform \
	bc \
	vim \
	&& rm -rf /var/lib/apt/lists/*

RUN sudo ln -sfn /opt/mssql-tools18/bin/sqlcmd /usr/bin/sqlcmd

# Install global npm packages
RUN npm install -g markdownlint-cli

# Install pip packages
RUN pip install detect-secrets