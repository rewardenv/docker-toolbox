.DEFAULT_GOAL 	= help

SHELL         	= bash
project       	= docker-toolbox
GIT_AUTHOR    	= janosmiko
MAKEFLAGS      += --always-make

help: ## Outputs this help screen
	@grep -E '(^[\/a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

.PHONY: build-alpine build-debian build-ubuntu

build-alpine: ## Build the default alpine image
	docker build -t rewardenv/$(project):alpine-latest -f images/default/alpine/Dockerfile images/default

build-debian: ## Build the default debian image
	docker build -t rewardenv/$(project):debian-bookworm-slim -f images/default/debian/Dockerfile images/default

build-ubuntu: ## Build the default ubuntu image
	docker build -t rewardenv/$(project):ubuntu-jammy -f images/default/ubuntu/Dockerfile images/default

build-all: build-alpine build-debian build-ubuntu ## Build all default images