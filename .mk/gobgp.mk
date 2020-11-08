GOBGP_IMG := gobgp:k8s-labs
GOBGP_IP ?= $(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gobgp)

gobgp-build:
	docker build -t $(GOBGP_IMG) gobgp/

gobgp-rr:
	docker run -d --name gobgp \
	--mount type=bind,source="$$(pwd)"/gobgp,target=/tmp/gobgp \
	--network kind \
	$(GOBGP_IMG) \
	-f /tmp/gobgp/rr.conf

gobgp-cleanup:
	-docker rm -f gobgp


gobgp-calico-patch:
	kubectl patch bgppeer gobgp-peer --type json \
	-p='[{"op": "replace", "path": "/spec/peerIP", "value":"$(GOBGP_IP)"}]'