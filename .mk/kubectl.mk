kubectl-test:
	@which kubectl 1>/dev/null

kubectl-install:
	echo 'Follow: https://kubernetes.io/docs/tasks/tools/install-kubectl/'

kubectl-ensure: 
	@make -s kubectl-test || make -s kubectl-install

