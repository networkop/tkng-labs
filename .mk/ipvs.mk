ipvs: flux-init-wait
	helm upgrade --namespace flux -f flux-values.yml --set git.branch=ipvs flux fluxcd/flux

kube-proxy-logs:
	kubectl logs -l k8s-app=kube-proxy -n kube-system


