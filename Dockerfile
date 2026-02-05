FROM rexezugedockerutils/cloudflared AS cloudflared

FROM rexezugedockerutils/upx AS upx

FROM debian:12 AS builder

WORKDIR /tmp

# Install Dependencies
RUN apt update \
 && apt install -y --no-install-recommends build-essential

COPY --from=upx /upx /usr/local/bin/upx

COPY Init.c /tmp/Init.c

RUN gcc -static -o /tmp/Init -Ofast /tmp/Init.c \
 && upx --best --lzma /tmp/Init

RUN gcc -static -o /tmp/Init -Ofast /tmp/Init.c

FROM ghcr.io/jeffvli/feishin:latest AS runtime

COPY webApp.conf /etc/nginx/conf.d/webApp.conf

COPY --from=cloudflared /cloudflared /usr/local/bin/cloudflared

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
