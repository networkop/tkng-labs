FROM golang:1.16-alpine as builder

ENV GO111MODULE=on
ENV CGO_ENABLED=0

RUN apk add --no-cache git
RUN git clone https://github.com/osrg/gobgp /gobgp

WORKDIR /gobgp
RUN git checkout tags/v2.30.0
RUN go install /gobgp/cmd/gobgp
RUN go install /gobgp/cmd/gobgpd

FROM alpine:3.12

COPY --from=builder /go/bin/gobgpd /usr/local/bin/
COPY --from=builder /go/bin/gobgp /usr/local/bin/

ENTRYPOINT [ "gobgpd" ]