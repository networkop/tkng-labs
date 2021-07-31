# Targets to manage a kind cluster

KIND_CLUSTER_NAME ?= k8s-guide
KIND_NETWORK:=kind
export KUBECONFIG=kubeconfig

ifeq (,$(wildcard ./kind.yaml))
KIND_CONF:=  
else
KIND_CONF:=--config ./kind.yaml
endif

kind-install: 
	GO111MODULE="on" go get -u sigs.k8s.io/kind@v0.9.0


kind-stop: 
	@kind delete cluster --name $(KIND_CLUSTER_NAME) || \
		echo "kind cluster is not running"

kind-test:
	@which kind 1>/dev/null 2>&1

kind-ensure: 
	@make -s kind-test || make -s kind-install


kind-start: 
	@kind get clusters | grep $(KIND_CLUSTER_NAME) || \
		kind create cluster --name $(KIND_CLUSTER_NAME) --kubeconfig kubeconfig $(KIND_CONF)


kind-load: kind-ensure 
	kind load docker-image --name $(KIND_CLUSTER_NAME) ${IMG}

