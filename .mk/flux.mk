flux-repo:
	helm repo add fluxcd https://charts.fluxcd.io

flux-install:
	helm install --namespace flux --create-namespace -f flux-values.yml flux fluxcd/flux && \
	helm install --namespace flux --create-namespace -f helm-values.yml helm-operator fluxcd/helm-operator 