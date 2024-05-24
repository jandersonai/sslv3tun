# stunnel Docker Container

This repository contains the Docker configuration for building and running an `stunnel` container that proxies modern encrypted connections to a server using SSLv3. The container is built in two stages: the first stage compiles OpenSSL and stunnel with SSLv3 support, and the second stage creates a minimal runtime environment.

## Table of Contents

- [Requirements](#requirements)
- [Build and Run](#build-and-run)
- [Configuration](#configuration)
- [Ports](#ports)

## Requirements

- Docker

## Build and Run

### Build the Docker Image

To build the Docker image, run the following command:

```sh
docker build -t stunnel-sslv3 .
```

### Run the Docker Container

To run the Docker container, use the following command:

```sh
docker run -d -p 4443:4443 --name stunnel-proxy stunnel-sslv3
```

## Configuration

The `stunnel.conf` file configures `stunnel` to listen on port 4443 with modern encryption and proxy the connections to a server using SSLv3. Here is an example configuration:

```ini
foreground = yes

[modern_to_local]
client = no
accept = 4443
connect = 127.0.0.1:4444
cert = /etc/stunnel/stunnel.crt
key = /etc/stunnel/stunnel.key
options = NO_SSLv2
options = NO_SSLv3
options = NO_TLSv1

[local_to_legacy]
client = yes
accept = 4444
connect = 192.168.1.10:443
sslVersion = SSLv3
```

- The `modern_to_local` section listens on port 4443 with modern encryption settings.
- The `local_to_legacy` section connects to the backend server using SSLv3.

## Ports

- **4443**: This port is exposed and listens for incoming connections using modern encryption. The traffic is then proxied to the backend server using SSLv3.