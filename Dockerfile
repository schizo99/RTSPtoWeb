<<<<<<< HEAD
# syntax=docker/dockerfile:1

FROM --platform=${BUILDPLATFORM} golang:1.18-alpine3.15 AS builder

RUN apk add git

WORKDIR /go/src/app
COPY . .

ARG TARGETOS TARGETARCH TARGETVARIANT

ENV CGO_ENABLED=0
RUN go get \
    && go mod download \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT#"v"} go build -a -o rtsp-to-web

FROM alpine:3.15

WORKDIR /app

COPY --from=builder /go/src/app/rtsp-to-web /app/
COPY --from=builder /go/src/app/web /app/web

RUN mkdir -p /config
COPY --from=builder /go/src/app/config.json /config

ENV GO111MODULE="on"
ENV GIN_MODE="release"

CMD ["./rtsp-to-web", "--config=/config/config.json"]
=======
FROM golang:1.15 as builder
LABEL maintainer="andreas.ahman@ingka.ikea.com"

# Create guestuser.
RUN adduser --disabled-password --gecos '' guest


ENV GO111MODULE=on

COPY . /app

WORKDIR /app

RUN go mod download

# Install the package
# RUN go install -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -mod=readonly -v -o RTSPtoWeb

FROM alpine

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /app/RTSPtoWeb /RTSPtoWeb
COPY --from=builder /app/web /web
EXPOSE 8083

USER guest

# Run the executable
CMD ["/RTSPtoWeb"]
>>>>>>> 9c6276f (Add Dockerfile)
