include Makefile.$(ENVIRONMENT)

.PHONY: all infra

# Ensure binaries in bin are used
BIN_PATH=/usr/local/bin

PATH := $(BIN_PATH):$(PATH)
export PATH

depend: packages $(BIN_PATH)/az $(BIN_PATH)/kubectl $(BIN_PATH)/helm $(BIN_PATH)/azcopy

build_and_push:
	az acr login --name ahgoo
	docker build -t ahgoo.azurecr.io/stacks-node:$(STACKS_NODE_VERSION) .
	docker push ahgoo.azurecr.io/stacks-node:$(STACKS_NODE_VERSION)

deploy_all: depend
	(kubectl create namespace eva-$(ENVIRONMENT) || echo "pre-existing environment namespace")
	helm upgrade -i eva eva/eva/ -f eva/eva/values.$(ENVIRONMENT).yaml --namespace eva-$(ENVIRONMENT)

packages:
	sudo apt-get update && \
	sudo apt-get install make jq -y

$(BIN_PATH)/az:
	curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

$(BIN_PATH)/kubectl:
	curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/kubectl
	chmod +x kubectl
	sudo mv kubectl $(BIN_PATH)/kubectl

$(BIN_PATH)/helm:
	curl -LO https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
	tar -xvf helm-v3.2.4-linux-amd64.tar.gz
	chmod +x linux-amd64/helm
	sudo mv linux-amd64/helm $(BIN_PATH)/helm
	rm -rf linux-amd64/
	rm helm-v3.2.4-linux-amd64.tar.gz
	helm repo add stable https://kubernetes-charts.storage.googleapis.com
	helm repo update

$(BIN_PATH)/azcopy:
	curl -LO https://aka.ms/downloadazcopy-v10-linux
	tar -xvf downloadazcopy-v10-linux
	chmod +x azcopy_linux_amd64_10.6.0/azcopy
	sudo mv azcopy_linux_amd64_10.6.0/azcopy $(BIN_PATH)/azcopy
	rm downloadazcopy-v10-linux
	rm -rf azcopy_linux_amd64_10
