untaint:
	kubectl taint node k8s-guide-control-plane node-role.kubernetes.io/master-

headless: untaint
	kubectl apply -f flux/lab-configs/headless.yaml

headless-cleanup:
	kubectl delete -f flux/lab-configs/headless.yaml


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

nodeport:
	-kubectl expose deployment web --port=80 --type=NodePort

node-ip-1:
	@docker inspect --format='control-plane:{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k8s-guide-control-plane

node-ip-2:
	@docker inspect --format='worker:{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k8s-guide-worker

node-ip-3:
	@docker inspect --format='worker2:{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k8s-guide-worker2

loadbalancer:
	-kubectl expose deployment web --port=80 --type=LoadBalancer