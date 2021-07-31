# Getting started

1. Install main dependencies:

  * Go https://golang.org/doc/install
  * Docker https://docs.docker.com/engine/install/
  * direnv https://direnv.net/

2. Clone this repository

```
$ git clone https://github.com/networkop/k8s-guide-labs.git && \
cd k8s-guide-labs && \
direnv allow
```

3. View available targets

```
$ make help

check           Check prerequisites
setup           Setup the lab environment
up              Bring up the cluster
connect         Connect to Weave Scope
tshoot          Connect to the troubleshooting pod
reset           Reset k8s cluster
down            Shutdown
cleanup         Destroy the lab environment
```

4. Check prerequisites

```
$ make check
all good
```

5. Bring up the lab

```
$ make setup
```

6. Configure the cluster

```
$ make up
```

