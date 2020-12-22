# Targets to manage docker and quay.io pull-through registries
# some pointers 
# https://www.talos.dev/docs/v0.6/guides/configuring-pull-through-cache/
# https://maelvls.dev/docker-proxy-registry-kind/


DOCKER_CACHE := docker-cache
QUAYIO_CACHE := quay-cache

cache-start: docker-cache quayio-cache

docker-cache:
	@docker inspect -f '{{.State.Running}}' $(DOCKER_CACHE) 2>/dev/null || \
	docker run -d --restart=always --network $(KIND_NETWORK) \
	-e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
	--name $(DOCKER_CACHE) registry:2

quayio-cache:
	@docker inspect -f '{{.State.Running}}' $(QUAYIO_CACHE) 2>/dev/null || \
	docker run -d --restart=always --network $(KIND_NETWORK) \
	-e REGISTRY_PROXY_REMOTEURL=https://quay.io \
	--name $(QUAYIO_CACHE) registry:2

cache-stop: docker-cache-stop quayio-cache-stop

quayio-cache-stop:
	@docker inspect -f '{{.State.Running}}' $(QUAYIO_CACHE) 2>/dev/null && \
	docker rm -f $(QUAYIO_CACHE) 2>/dev/null || echo 'quay-cache is not running'

docker-cache-stop:
	@docker inspect -f '{{.State.Running}}' $(DOCKER_CACHE) 2>/dev/null && \
	docker rm -f $(DOCKER_CACHE) 2>/dev/null || echo 'docker-cache is not running'