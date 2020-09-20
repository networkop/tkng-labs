helm-test:
	@which helm 1>/dev/null

helm-install:
	echo 'Follow: https://helm.sh/docs/intro/install/'

helm-ensure: 
	@make -s helm-test || make -s helm-install

