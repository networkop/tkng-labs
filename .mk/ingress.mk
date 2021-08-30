CONTROL_PLANE_NODE_IP := $(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k8s-guide-control-plane)
KIND_BRIDGE_SUBNET := $(shell docker network inspect kind --format='{{(index .IPAM.Config 0).Subnet}}')

ingress-nginx-add:
	kubectl apply -f flux/lab-configs/ingress-nginx.yaml

ingress-nginx-delete:
	kubectl delete -f flux/lab-configs/ingress-nginx.yaml

ingress-prep-add:
	kubectl -n default create deployment prod --image=nginxdemos/nginx-hello:plain-text
	kubectl -n default create deployment dev --image=nginxdemos/nginx-hello:plain-text
	kubectl -n default expose deployment prod --port=8080
	kubectl -n default expose deployment dev --port=8080

ingress-prep-delete:
	-kubectl -n default delete deployment prod
	-kubectl -n default delete deployment dev
	-kubectl -n default delete svc prod
	-kubectl -n default delete svc dev

ingress-path-routing:
	kubectl -n default create ingress tkng-1  --class=nginx --rule="/prod*=prod:8080" --rule="/dev*=dev:8080" 

ingress-host-routing:
	kubectl -n default create ingress tkng-2  --class=nginx --rule="prod/*=prod:8080" --rule="dev/*=dev:8080" 

ingress-delete: 
	-kubectl -n default delete ingress tkng-1
	-kubectl -n default delete ingress tkng-2

ingress-wait:
	kubectl wait --for=condition=ready --timeout=60s -n kube-system pod -l app.kubernetes.io/instance=ingress-controller

ingress-setup:
	make -s ingress-nginx-add

ingress-prep:
	make -s ingress-prep-add
	make -s ingress-path-routing
	make -s ingress-host-routing

ingress-cleanup: ingress-delete ingress-prep-delete
	-make -s ingress-nginx-delete

egress-prep: 
	-docker rm -f echo
	-docker run -d --rm --network kind --name echo mpolden/echoip -l ":80"

egress-setup: egress-prep
	kubectl apply -f flux/lab-configs/egress.yaml
	kubectl patch kustomizations -n flux egress-gw --patch '{"spec": {"postBuild": {"substitute": {"destination_cidr": "$(KIND_BRIDGE_SUBNET)"}}}}' --type=merge
	kubectl patch kustomizations -n flux egress-gw --patch '{"spec": {"postBuild": {"substitute": {"egress_ip": "$(CONTROL_PLANE_NODE_IP)"}}}}' --type=merge

egress-cleanup:
	-docker rm -f echo
	-kubectl delete -f flux/lab-configs/egress.yaml


gateway-setup: metallb
	kubectl apply -k github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.3.0
	kubectl apply -f flux/lab-configs/istio.yaml
	kubectl apply -f flux/lab-configs/gateway-api.yaml

gateway-check:
	@kubectl wait --for=condition=ready --timeout=60s -n istio-system pod --all
	@kubectl wait --for=condition=ready --timeout=60s -n kube-system pod -l app.kubernetes.io/instance=metallb

gateway-cleanup:
	kubectl delete -k github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.3.0
	kubectl delete -f flux/lab-configs/istio.yaml
	kubectl delete -f flux/lab-configs/gateway-api.yaml