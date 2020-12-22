flux-repo:
	helm repo add fluxcd https://charts.fluxcd.io

flux-install:
	helm install --namespace flux --create-namespace -f flux-values.yml flux fluxcd/flux && \
	helm install --namespace flux --create-namespace -f helm-values.yml helm-operator fluxcd/helm-operator 

flux-init-wait:
	@echo 'Waiting for flux to initialize...'
	@kubectl wait --for=condition=available --timeout=60s -n flux deploy/flux \
	|| echo "ERROR: Flux Failed to Initialse. Please 'make down' and reboot."