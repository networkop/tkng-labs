untaint:
	kubectl taint node k8s-guide-control-plane node-role.kubernetes.io/master-

headless: untaint
	kubectl apply -f flux/lab-config/headless.yaml

headless-cleanup:
	kubectl delete -f flux/lab-config/weave.yaml


deployment:
	-kubectl create deployment web --image=nginx

deployment-show:
	kubectl get pod -owide -l app=web

scale-up:
	-kubectl scale --replicas=3 deployment/web

scale-down:
	-kubectl scale --replicas=0 deployment/web

cluster-ip:
	-kubectl expose deployment web --port=80