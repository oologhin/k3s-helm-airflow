# Makefile for setting up K3s and Kubernetes Dashboard using Ansible

# Variables
ANSIBLE_PLAYBOOK=ansible-playbook
INVENTORY_FILE=./inventory/hosts.ini
PLAYBOOK_FILE=./playbooks/k3s_pb.yml
PACKAGE_MANAGER=$(shell command -v dnf || command -v apt-get)
HELM_VERSION=v3.7.1

# Default target
all: setup

setup: install_ansible install_helm install_collections run_playbook

install_ansible:
	# Detect package manager and install Ansible
ifeq ($(PACKAGE_MANAGER),/usr/bin/dnf)
	sudo dnf install -y epel-release
	sudo dnf install -y ansible
else ifeq ($(PACKAGE_MANAGER),/usr/bin/apt-get)
	sudo apt-get update
	sudo apt-get install -y ansible
else
	$(error "Unsupported package manager. Supported: dnf, apt-get")
endif

install_helm:
	# Manually install Helm
	# Detect package manager and install curl if not installed
ifeq ($(PACKAGE_MANAGER),/usr/bin/dnf)
	sudo dnf install -y curl
else ifeq ($(PACKAGE_MANAGER),/usr/bin/apt-get)
	sudo apt-get update
	sudo apt-get install -y curl
else
	$(error "Unsupported package manager. Supported: dnf, apt-get")
endif
	curl -sSL https://get.helm.sh/helm-$(HELM_VERSION)-linux-amd64.tar.gz -o /tmp/helm.tar.gz
	tar -zxvf /tmp/helm.tar.gz -C /tmp
	sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm
	rm -rf /tmp/linux-amd64 /tmp/helm.tar.gz

install_collections:
	# Install required Ansible collections
	ansible-galaxy collection install community.kubernetes
	ansible-galaxy collection install kubernetes.core

run_playbook:
	# Run the Ansible playbook to setup K3s and Kubernetes Dashboard
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY_FILE) $(PLAYBOOK_FILE) --tags "install"

.PHONY: all setup install_ansible install_helm install_collections run_playbook
