FROM debian:12 AS builder

WORKDIR /tmp

# Install Dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential curl unzip zlib1g-dev libpcre2-dev perl ca-certificates

# Download and Install upx
ENV UPX_VERSION=5.0.0

RUN curl -L https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-amd64_linux.tar.xz -o /tmp/upx.tar.xz \
 && tar -xf /tmp/upx.tar.xz -C /tmp \
 && mv /tmp/upx-${UPX_VERSION}-amd64_linux/upx /usr/local/bin/upx

# Download Cloudflare Tunnel and Compress
RUN curl -L -o /tmp/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
 && chmod +x /tmp/cloudflared \
 && upx --best --lzma /tmp/cloudflared

COPY Init.c /tmp/Init.c

RUN gcc -static -o /tmp/Init -Ofast /tmp/Init.c \
 && upx --best --lzma /tmp/Init

RUN gcc -static -o /tmp/Init -Ofast /tmp/Init.c

FROM ghcr.io/jeffvli/feishin:latest AS runtime

COPY webApp.conf /etc/nginx/conf.d/webApp.conf

COPY --from=builder /tmp/cloudflared /usr/local/bin/cloudflared

COPY --from=builder /tmp/Init /Init

FROM scratch

COPY --from=runtime / /

ENV SERVER_URL="https://navidrome.example.com"

ENV SERVER_TYPE="navidrome"

ENV SERVER_LOCK="true"

ENV SERVER_NAME="Navidrome"

EXPOSE 80/tcp

CMD ["/Init"]

ENTRYPOINT ["/docker-entrypoint.sh"]
