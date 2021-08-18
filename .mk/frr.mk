FRR_IMG := frrouting/frr:v7.5.1
FRR_IP ?= $(shell docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' frr)

frr-start: frr-cleanup
	docker run -d --name frr \
	--privileged \
	--mount type=bind,source="$$(pwd)"/frr/daemons,target=/etc/frr/daemons \
	--mount type=bind,source="$$(pwd)"/frr/frr.conf,target=/etc/frr/frr.conf \
	--network kind \
	$(FRR_IMG) 

frr-cleanup:
	-docker rm -f frr
	sudo chown -R $$USER:$$USER frr/*

frr-ip:
	@echo ${FRR_IP}

