FROM alpine

RUN mkdir /opt/bin

WORKDIR /opt/bin

ADD https://github.com/containernetworking/plugins/releases/download/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tgz ./

RUN tar zxvf cni-plugins-linux-amd64-v0.8.7.tgz && rm cni-plugins-linux-amd64-v0.8.7.tgz


