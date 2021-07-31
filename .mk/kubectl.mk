kubectl-test:
	@which kubectl 1>/dev/null 2>&1

kubectl-install:
	echo 'kubectl not found. Follow: https://kubernetes.io/docs/tasks/tools/install-kubectl/'

kubectl-ensure: 
	@make -s kubectl-test || make -s kubectl-install

