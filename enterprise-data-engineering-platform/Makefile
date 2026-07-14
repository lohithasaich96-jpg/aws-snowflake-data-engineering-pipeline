.PHONY: help install lint test fmt tf-init tf-plan tf-apply tf-destroy airflow-up airflow-down docker-build

ENV ?= dev
TF  := terraform -chdir=terraform

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "\033[36m%-16s\033[0m %s\n",$$1,$$2}'

install: ## Install Python deps
	pip install -r requirements.txt

lint: ## Ruff lint
	ruff check src tests

fmt: ## Format Python + Terraform
	ruff format src tests
	$(TF) fmt -recursive

test: ## Run unit tests (skips spark)
	PYTHONPATH=. pytest -q tests -k "not spark"

test-all: ## Run all tests including spark
	PYTHONPATH=. pytest -q tests

tf-init: ## terraform init for ENV (make tf-init ENV=dev)
	$(TF) init -backend-config=$(ENV)/backend.hcl

tf-plan: ## terraform plan for ENV
	$(TF) plan -var-file=$(ENV)/terraform.tfvars

tf-apply: ## terraform apply for ENV
	$(TF) apply -var-file=$(ENV)/terraform.tfvars

tf-destroy: ## terraform destroy for ENV
	$(TF) destroy -var-file=$(ENV)/terraform.tfvars

airflow-up: ## Start local Airflow
	cd airflow && docker compose up -d

airflow-down: ## Stop local Airflow
	cd airflow && docker compose down

docker-build: ## Build the jobs image
	docker build -f docker/Dockerfile -t edp-jobs:local .
