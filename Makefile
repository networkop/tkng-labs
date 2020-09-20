

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
lab: kind-start cache-start

## Setup flux
flux: flux-helm
	make -s flux-install

## Destroy the lab environment
nuke: kind-stop cache-stop