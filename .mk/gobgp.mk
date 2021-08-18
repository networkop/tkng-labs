GOBGP_IMG := gobgp:k8s-labs
GOBGP_IP ?= $(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gobgp)

gobgp-build:
	docker build -t $(GOBGP_IMG) gobgp/

gobgp-rr: gobgp-cleanup gobgp-build
	docker run -d --name gobgp \
	--mount type=bind,source="$$(pwd)"/gobgp,target=/tmp/gobgp \
	--network kind \
	$(GOBGP_IMG) \
	-f /tmp/gobgp/rr.conf

gobgp-cleanup:
	-docker rm -f gobgp

gobgp-ip:
	@echo ${GOBGP_IP}

# 1. extract existing bgppeer definition
# 2. change the name to prevent flux from overwriting it
# 3. change the peerIP to match the IP of the gobgp container
gobgp-calico-patch:
	kubectl get bgppeers gobgp-peer -oyaml | \
	kubectl patch -f - --type=merge -oyaml \
		--dry-run=client --local \
		-p '{"metadata":{"name": "gobgp-peer-updated"}}' | \
	kubectl patch  -f - --type=json -oyaml \
		--dry-run=client --local \
		-p='[{"op": "replace", "path": "/spec/peerIP", "value":"$(GOBGP_IP)"}]' | \
	kubectl apply -f -
	