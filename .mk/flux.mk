
flux-install:
	@kubectl apply -f flux/install.yaml
	@kubectl apply -f flux/git-source.yaml
	@kubectl apply -f flux/app.yaml

flux-init-wait:
	@echo 'Waiting for flux to initialize...'
	@kubectl wait --for=condition=available --timeout=60s -n flux deploy/kustomize-controller \
	|| echo "ERROR: Flux Failed to Initialse. Please 'make down' and reboot."


