FROM golang:1.27.1-trixie@sha256:b475798fb16158e6c38e8b5ca2d870fbeaa8b7fec0fc8ec64b3dc20966040635 AS builder
WORKDIR /src

RUN apt-get update -qq && apt-get install -qqy \
  build-essential \
  libsystemd-dev
COPY go.mod go.sum ./
RUN go mod download
RUN go mod verify
COPY . .
RUN go build -o /bin/postfix_exporter

FROM debian:trixie-slim@sha256:abc9cb88a5587630d7f915f47b23b0668fe250fbfc6457aa4d52b534c1bbf73f
EXPOSE 9154
WORKDIR /
COPY --from=builder /bin/postfix_exporter /bin/
ENTRYPOINT ["/bin/postfix_exporter"]
