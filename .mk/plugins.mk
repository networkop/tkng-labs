delete-kindnet:
	-kubectl -n kube-system delete daemonset kindnet

flannel: delete-kindnet preload-cni-image
	helm upgrade --namespace flux -f flux-values.yml --set git.branch=flannel flux fluxcd/flux

weave: delete-kindnet 
	helm upgrade --namespace flux -f flux-values.yml --set git.branch=weave flux fluxcd/flux

nuke-all-pods: flush-cni-dir
	kubectl delete --all pods --all-namespaces	


preload-cni-image:
	docker build -t networkop.co.uk/cni-install cni-installer
	kind load docker-image networkop.co.uk/cni-install:latest --name k8s-guide


flush-nat:
	docker exec -it k8s-guide-control-plane iptables --table nat --flush
	docker exec -it k8s-guide-worker iptables --table nat --flush
	docker exec -it k8s-guide-worker2 iptables --table nat --flush
	echo 'You may need to restart kube-proxy with "crictl rm --force $(crictl ps --name kube-proxy -q)"'

flush-cni-dir:
	-docker exec -t k8s-guide-control-plane rm /etc/cni/net.d/10-kindnet.conflist
	-docker exec -t k8s-guide-worker rm /etc/cni/net.d/10-kindnet.conflist
	-docker exec -t k8s-guide-worker2 rm /etc/cni/net.d/10-kindnet.conflist
