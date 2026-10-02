FROM khairul169/garage-webui:1.1.0 AS ui
FROM quay.io/oauth2-proxy/oauth2-proxy:v7.15.5 AS auth
FROM alpine:3.22
RUN apk add --no-cache ca-certificates curl
COPY --from=ui /bin/main /usr/local/bin/garage-webui
COPY --from=auth /bin/oauth2-proxy /usr/local/bin/oauth2-proxy
COPY oauth2-proxy.cfg /etc/oauth2-proxy.cfg
COPY allowed-emails.txt /etc/allowed-emails.txt
COPY start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start
EXPOSE 4180
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s CMD curl -fsS http://127.0.0.1:4180/ping || exit 1
ENTRYPOINT ["/usr/local/bin/start"]
