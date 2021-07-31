helm-test:
	@which helm 1>/dev/null 2>&1

helm-install:
	@echo 'helm is not found. Follow: https://helm.sh/docs/intro/install/'

helm-ensure: 
	@make -s helm-test || make -s helm-install

