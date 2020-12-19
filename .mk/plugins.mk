delete-kindnet:
	-kubectl -n kube-system delete daemonset kindnet

flannel: delete-kindnet preload-cni-image
	helm upgrade --namespace flux -f flux-values.yml --set git.branch=flannel flux fluxcd/flux

weave: delete-kindnet
	helm upgrade --namespace flux -f flux-values.yml --set git.branch=weave flux fluxcd/flux

weave-restart:
	kubectl -n kube-system delete pod -l name=weave-net

calico: delete-kindnet
	helm upgrade --namespace flux -f flux-values.yml --set git.branch=calico flux fluxcd/flux

calico-restart: flush-routes
	kubectl -n calico-system delete pod -l k8s-app=calico-node

cilium: delete-kindnet
	helm upgrade --namespace flux -f flux-values.yml --set git.branch=cilium flux fluxcd/flux

cilium-restart: flush-routes
	kubectl -n cilium delete pod -l k8s-app=cilium

nuke-all-pods: flush-cni-dir
	kubectl delete --all pods --all-namespaces	

preload-cni-image:
	docker build -t networkop.co.uk/cni-install cni-installer
	kind load docker-image networkop.co.uk/cni-install:latest --name k8s-guide

flush-routes:
	docker exec -it k8s-guide-control-plane ip route flush root 10.244.0.0/16 
	docker exec -it k8s-guide-worker ip route flush root 10.244.0.0/16 
	docker exec -it k8s-guide-worker2 ip route flush root 10.244.0.0/16 

flush-nat:
	docker exec -it k8s-guide-control-plane iptables --table nat --flush KIND-MASQ-AGENT
	docker exec -it k8s-guide-control-plane iptables --table nat --flush KUBE-SERVICES
	docker exec -it k8s-guide-worker iptables --table nat --flush KIND-MASQ-AGENT
	docker exec -it k8s-guide-worker iptables --table nat --flush KUBE-SERVICES
	docker exec -it k8s-guide-worker2 iptables --table nat --flush KIND-MASQ-AGENT
	docker exec -it k8s-guide-worker2 iptables --table nat --flush KUBE-SERVICES
	kubectl -n kube-system delete pod -l k8s-app=kube-proxy
	#docker exec -e ID=$(shell docker exec k8s-guide-control-plane bash -c "crictl ps --name kube-proxy -q") k8s-guide-control-plane bash -c 'crictl rm --force $${ID}'
	#docker exec -e ID=$(shell docker exec k8s-guide-worker bash -c "crictl ps --name kube-proxy -q") k8s-guide-worker bash -c 'crictl rm --force $${ID}'
	#docker exec -e ID=$(shell docker exec k8s-guide-worker2 bash -c "crictl ps --name kube-proxy -q") k8s-guide-worker2 bash -c 'crictl rm --force $${ID}'


flush-cni-dir:
	-docker exec -t k8s-guide-control-plane rm /etc/cni/net.d/10-kindnet.conflist
	-docker exec -t k8s-guide-worker rm /etc/cni/net.d/10-kindnet.conflist
	-docker exec -t k8s-guide-worker2 rm /etc/cni/net.d/10-kindnet.conflist


test:
	docker exec -it k8s-guide-control-plane crictl ps `crictl ps --name kube-proxy -q`