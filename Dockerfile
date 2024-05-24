# Stage 1: Build stage
FROM alpine:3.18 AS builder

# Install necessary packages
RUN apk add --no-cache \
    wget \
    build-base \
    perl \
    coreutils \
    linux-headers \
    openssl-dev

# Install OpenSSL with SSLv3 support
RUN wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz && \
    tar -xvzf openssl-1.0.2u.tar.gz && \
    cd openssl-1.0.2u && \
    ./config enable-ssl3 enable-ssl3-method && \
    make && \
    make install && \
    cd .. && \
    rm -rf openssl-1.0.2u.tar.gz openssl-1.0.2u

# Ensure OpenSSL is in the PATH
ENV PATH="/usr/local/ssl/bin:${PATH}"

# Install stunnel
RUN wget https://www.stunnel.org/downloads/stunnel-5.72.tar.gz && \
    tar -xvzf stunnel-5.72.tar.gz && \
    cd stunnel-5.72 && \
    ./configure --with-ssl=/usr/local/ssl && \
    make && \
    make install && \
    cd .. && \
    rm -rf stunnel-5.72.tar.gz stunnel-5.72

# Generate a self-signed certificate
RUN mkdir -p /etc/stunnel && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/stunnel/stunnel.key -out /etc/stunnel/stunnel.crt \
    -subj "/C=US/ST=Georgia/L=Alpharetta/O=None/CN=www.example.com"

# Stage 2: Final stage
FROM alpine:3.18

# Copy stunnel from the builder stage
COPY --from=builder /usr/local/bin/stunnel /usr/local/bin/stunnel
COPY --from=builder /usr/local/etc/stunnel /usr/local/etc/stunnel
COPY --from=builder /usr/local/ssl /usr/local/ssl

# Copy the stunnel configuration file and certificates
COPY --from=builder /etc/stunnel/stunnel.crt /etc/stunnel/stunnel.crt
COPY --from=builder /etc/stunnel/stunnel.key /etc/stunnel/stunnel.key
COPY stunnel.conf /etc/stunnel/stunnel.conf

# Expose ports
EXPOSE 4443

# Run stunnel
CMD ["stunnel", "/etc/stunnel/stunnel.conf"]
