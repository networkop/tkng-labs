
flux-install:
	@kubectl apply -f flux/install.yaml
	@kubectl apply -f flux/kustomization.yaml

flux-bootstrap:
	@kubectl apply -f flux/git-master.yaml


flux-init-wait:
	@echo 'Waiting for flux to initialize...'
	@kubectl wait --for=condition=available --timeout=60s -n flux deploy/kustomize-controller \
	|| echo "ERROR: Flux Failed to Initialse. Please 'make down' and reboot."


