# https

Simple HTTP(S) server in Crystal

## Usage

```
Simple HTTP(S) Server

Usage: ./https [OPTIONS] IP:PORT
    -h, --help                       Show this help
    -s, --tls                        Enable TLS
    -k KEY, --key=KEY                Specify the private key
    -c CERT, --cert=CERT             Specify the certificate
    -d DIRECTORY, --dir=DIRECTORY    Serve the directory
    --cgi                            Enable basic CGI support for files in /cgi
```

Example:

`./https --cgi 127.0.0.1:8080`

`./https -s -k ssl/key.pem ssl/cert.pem -d website 0.0.0.0:443`

## How to build

Simply run `crystal build --release ./https.cr`
