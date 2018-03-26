FROM golang:1.10

RUN mkdir -p /go/src/app
ADD main.go /go/src/app
ENV GOPATH /go
WORKDIR /go/src/app

RUN go get github.com/sclevine/agouti && \
    go vet && \
    CGO_ENABLED=1 go build -o main main.go

ENTRYPOINT /go/src/app/main