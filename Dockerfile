FROM --platform=$BUILDPLATFORM golang:1.27.4-alpine3.24@sha256:0a5f7fe796599ff487605987432e7619ae45beeb2fba4c2ce0b907879932aebf AS builder

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION

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
