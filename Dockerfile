# SillyTavern for Railway: official image, pinned by version and digest.
FROM ghcr.io/sillytavern/sillytavern:1.19.0@sha256:eef27ff0c7961f1a2f488400f581f48ff38f8b910c5d3b8d389138d71791bb14

COPY railway-start.sh /usr/local/bin/railway-start.sh
COPY railway-proxy.mjs /usr/local/lib/railway-proxy.mjs
RUN chmod +x /usr/local/bin/railway-start.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/railway-start.sh"]
