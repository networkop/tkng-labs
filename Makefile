NODE?=k8s-guide-control-plane
POD:=$(shell kubectl get pods --field-selector spec.nodeName=$(NODE) -o jsonpath='{.items[0].metadata.name}')
NODES:=$(shell kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

include .mk/kind.mk
include .mk/help.mk
include .mk/cache.mk
include .mk/kubectl.mk
include .mk/flux.mk
include .mk/helm.mk
include .mk/plugins.mk

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
	make -s flux-install &>/dev/null

## Connect to Weave Scope
connect:
	echo 'Navigate to http://localhost:8080' && \
	kubectl -n weave port-forward deployment/weave-scope-frontend-weave-scope 8080:4040

## Connect to the troubleshooting pod
tshoot:
	@kubectl exec -it $(POD) -- bash

## Reset k8s cluster
reset:
	make -s down && make -s up

## Shutdown
down:
	make -s kind-stop

## Destroy the lab environment
cleanup: kind-stop cache-stop