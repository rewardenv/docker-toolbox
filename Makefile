.DEFAULT_GOAL 	= help

SHELL         	= bash
PROJECT       	= docker-toolbox
GIT_AUTHOR    	= janosmiko
MAKEFLAGS      += --always-make
EXPORT_COMMAND    = docker run --rm -v $(PWD)/images/default/rootfs/usr/local/bin:/usr/local/bin -v $(PWD)/tests/output/export:/data -v $(PWD)/tests/export/$(PROJECT_TYPE):/app rewardenv/$(PROJECT):alpine-latest
IMPORT_COMMAND    = docker run --rm -v $(PWD)/images/default/rootfs/usr/local/bin:/usr/local/bin -v $(PWD)/tests/import:/data -v $(PWD)/tests/output/import/$(PROJECT_TYPE):/app rewardenv/$(PROJECT):alpine-latest

help: ## Outputs this help screen
	@grep -E '(^[\/a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

.PHONY: build-alpine build-debian build-ubuntu

build build-alpine: ## Build the default alpine image
	docker build -t rewardenv/$(PROJECT):alpine-latest -f images/default/alpine/Dockerfile images/default

build-debian: ## Build the default debian image
	docker build -t rewardenv/$(PROJECT):debian-bookworm-slim -f images/default/debian/Dockerfile images/default

build-ubuntu: ## Build the default ubuntu image
	docker build -t rewardenv/$(PROJECT):ubuntu-jammy -f images/default/ubuntu/Dockerfile images/default

build-all: build-alpine build-debian build-ubuntu ## Build all default images

test-magento-export: ## Test the magento export image
	$(eval PROJECT_TYPE := magento)
	$(EXPORT_COMMAND) "/usr/local/bin/export-media.sh --gzip --project-type $(PROJECT_TYPE) --source-dir /app --target-dir /data --target-filename $(PROJECT_TYPE)-media"

test-shopware-export: ## Test the shopware export image
	$(eval PROJECT_TYPE := shopware)
	$(EXPORT_COMMAND) "/usr/local/bin/export-media.sh --gzip --project-type $(PROJECT_TYPE) --source-dir /app --target-dir /data --target-filename $(PROJECT_TYPE)-media"

test-wordpress-export: ## Test the wordpress export image
	$(eval PROJECT_TYPE := wordpress)
	$(EXPORT_COMMAND) "/usr/local/bin/export-media.sh --gzip --project-type $(PROJECT_TYPE) --source-dir /app --target-dir /data --target-filename $(PROJECT_TYPE)-media"

test-magento-import: ## Test the magento import image
	$(eval PROJECT_TYPE := magento)
	$(IMPORT_COMMAND) "/usr/local/bin/import-media.sh --project-type $(PROJECT_TYPE) --target-dir /app --source-file /data/$(PROJECT_TYPE)-media.tgz"

test-shopware-import: ## Test the magento import image
	$(eval PROJECT_TYPE := shopware)
	$(IMPORT_COMMAND) "/usr/local/bin/import-media.sh --project-type $(PROJECT_TYPE) --target-dir /app --source-file /data/$(PROJECT_TYPE)-media.tgz"

test-wordpress-import: ## Test the magento import image
	$(eval PROJECT_TYPE := wordpress)
	$(IMPORT_COMMAND) "/usr/local/bin/import-media.sh --project-type $(PROJECT_TYPE) --target-dir /app --source-file /data/$(PROJECT_TYPE)-media.tgz"

test-magento-export-stripped: ## Test the magento export image
	$(eval PROJECT_TYPE := magento)
	$(EXPORT_COMMAND) "/usr/local/bin/export-media.sh --gzip --source-dir /app/pub --compress-targets media --target-dir /data --target-filename $(PROJECT_TYPE)-media-stripped"

test-magento-import-stripped: ## Test the magento import image
	$(eval PROJECT_TYPE := magento)
	$(IMPORT_COMMAND) "/usr/local/bin/import-media.sh --project-type $(PROJECT_TYPE) --target-dir /app --source-file /data/$(PROJECT_TYPE)-media-stripped.tgz"

test-shopware-export-stripped: ## Test the magento export image
	$(eval PROJECT_TYPE := shopware)
	$(EXPORT_COMMAND) "/usr/local/bin/export-media.sh --gzip --source-dir /app/public --compress-targets media,thumbnail,sitemap --target-dir /data --target-filename $(PROJECT_TYPE)-media-stripped"

test-shopware-import-stripped: ## Test the magento import image
	$(eval PROJECT_TYPE := shopware)
	$(IMPORT_COMMAND) "/usr/local/bin/import-media.sh --project-type $(PROJECT_TYPE) --target-dir /app --source-file /data/$(PROJECT_TYPE)-media-stripped.tgz"

