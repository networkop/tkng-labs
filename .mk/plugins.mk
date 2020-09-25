delete-kindnet:
	-kubectl -n kube-system delete daemonset kindnet

flannel: delete-kindnet preload-cni-image
	helm upgrade --namespace flux -f flux-values.yml --set git.branch=flannel flux fluxcd/flux


nuke-all-pods:
	kubectl delete --all pods --all-namespaces	


preload-cni-image:
	docker build -t networkop.co.uk/cni-install cni-installer
	kind load docker-image networkop.co.uk/cni-install:latest --name k8s-guide
