# Makefile for setting up K3s and Kubernetes Dashboard using Ansible

# Variables
ANSIBLE_PLAYBOOK=ansible-playbook
INVENTORY_FILE=./inventory/hosts.ini
PLAYBOOK_FILE=./playbooks/playbook.yml
PACKAGE_MANAGER=$(shell command -v dnf || command -v apt-get)

# Default target
all: setup

setup: install_ansible install_collections run_playbook

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

install_collections:
	# Install required Ansible collections
	ansible-galaxy collection install community.kubernetes
	ansible-galaxy collection install kubernetes.core

run_playbook:
	# Run the Ansible playbook to setup K3s and Kubernetes Dashboard
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY_FILE) $(PLAYBOOK_FILE)

.PHONY: all setup install_ansible install_collections run_playbook
