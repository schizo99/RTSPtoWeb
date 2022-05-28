FROM golang:1.18 as builder
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
