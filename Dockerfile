FROM ghcr.io/jeffvli/feishin:latest

USER root:root

RUN rm -f /etc/nginx/conf.d/*.conf

COPY --from=rexezugebuild/appservicelauncher /.AppServiceLauncher /.AppServiceLauncher

COPY overlay/ /

RUN chmod +x /usr/local/bin/feishin-entrypoint.sh

ENV WEBSITES_PORT=80

EXPOSE 80/tcp

ENTRYPOINT ["/.AppServiceLauncher/launcher.sh"]

CMD ["/usr/local/bin/feishin-entrypoint.sh"]
