# Targets to manage docker pull-through registry

CACHE_NAME ?= cache

cache-start: 
	docker inspect -f '{{.State.Running}}' $(CACHE_NAME) 2>/dev/null || \
	docker run -d --restart=always -p 5000:5000 --network $(KIND_NETWORK) \
	-e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
	--name $(CACHE_NAME) registry:2

cache-stop:
	docker inspect -f '{{.State.Running}}' $(CACHE_NAME) 2>/dev/null && \
	docker rm -f $(CACHE_NAME) 2>/dev/null || echo 'cache is not running'