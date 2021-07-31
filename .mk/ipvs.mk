ipvs: flux-init-wait
	kubectl apply -f flux/lab-configs/ipvs.yaml

kube-proxy-logs:
	kubectl logs -l k8s-app=kube-proxy -n kube-system


