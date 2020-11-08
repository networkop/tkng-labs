FROM golang:1.15-alpine as builder

RUN apk add --no-cache git
RUN go get github.com/osrg/gobgp/cmd/gobgpd
RUN go get github.com/osrg/gobgp/cmd/gobgp

FROM alpine:3.12

COPY --from=builder /go/bin/gobgpd /usr/local/bin/
COPY --from=builder /go/bin/gobgp /usr/local/bin/

ENTRYPOINT [ "gobgpd" ]