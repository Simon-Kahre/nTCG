FROM golang:1.25.0-alpine

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -o login .

EXPOSE 4000

CMD ["./login"]