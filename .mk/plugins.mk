delete-kindnet:
	-kubectl -n kube-system delete daemonset kindnet

flannel: delete-kindnet preload-cni-image
	kubectl apply -f flux/lab-configs/flannel.yaml

weave: delete-kindnet
	kubectl apply -f flux/lab-configs/weave.yaml

weave-restart:
	kubectl -n kube-system delete pod -l name=weave-net

calico: delete-kindnet
	kubectl apply -f flux/lab-configs/calico.yaml

calico-restart: flush-routes
	kubectl -n calico-system delete pod -l k8s-app=calico-node

metallb: frr-start
	kubectl apply -f flux/lab-configs/metallb.yaml
	kubectl patch kustomizations -n flux metallb --patch '{"spec": {"postBuild": {"substitute": {"peer_addr": "$(FRR_IP)"}}}}' --type=merge

metallb-delete: frr-cleanup
	kubectl delete -f flux/lab-configs/metallb.yaml
	git checkout HEAD -- frr/frr.conf

cilium: flux-init-wait delete-kindnet
	kubectl apply -f flux/lab-configs/cilium.yaml

cilium-wait:
	kubectl wait --for=condition=ready --timeout=60s -n cilium pod -l k8s-app=cilium

cilium-check:
	kubectl exec -n cilium daemonset/cilium -- cilium status

cilium-restart: flush-routes
	kubectl -n cilium delete pod -l k8s-app=cilium

cilium-unhook: 
	-@hacks/unhook-cilium.sh 2>/dev/null

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

flush-all: flush-routes flush-nat

nuke-kube-proxy:
	-kubectl -n kube-system delete ds kube-proxy
	-kubectl -n kube-system delete cm kube-proxy
	docker exec -it k8s-guide-worker bash -c 'iptables-restore <(iptables-save | grep -v KUBE)'
	docker exec -it k8s-guide-worker2 bash -c 'iptables-restore <(iptables-save | grep -v KUBE)'
	docker exec -it k8s-guide-control-plane bash -c 'iptables-restore <(iptables-save | grep -v KUBE)'

flush-cni-dir:
	-docker exec -t k8s-guide-control-plane rm /etc/cni/net.d/10-kindnet.conflist
	-docker exec -t k8s-guide-worker rm /etc/cni/net.d/10-kindnet.conflist
	-docker exec -t k8s-guide-worker2 rm /etc/cni/net.d/10-kindnet.conflist


test:
	docker exec -it k8s-guide-control-plane crictl ps `crictl ps --name kube-proxy -q`