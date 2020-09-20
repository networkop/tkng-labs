

include .mk/kind.mk
include .mk/help.mk
include .mk/cache.mk
include .mk/kubectl.mk
include .mk/flux.mk
include .mk/helm.mk

.DEFAULT_GOAL := help

## Check prerequisites
check: kind-ensure kubectl-ensure helm-ensure
	@make -s kind-test && \
	make -s kubectl-test && \
	make -s helm-test && \
	echo 'all good' || echo 'check failed. see logs above.'

## Setup the lab environment
setup: kind-start cache-start

## Bring up the cluster
up: kind-start flux-repo
	make -s flux-install

## Connecto to Weave Scope
connect:
	echo 'Navigate to http://localhost:8080' && \
	kubectl port-forward deployment/weave-scope-frontend-weave-scope 8080:4040

## Shutdown
down:
	make -s kind-stop

## Destroy the lab environment
cleanup: kind-stop cache-stop