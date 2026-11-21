# SillyTavern for Railway: official image, pinned by version and digest.
FROM ghcr.io/sillytavern/sillytavern:1.19.1@sha256:660d1a23c70517fa6d5b9b76f4456ee11f002cd911007d838569e4a771a096bc

COPY railway-start.sh /usr/local/bin/railway-start.sh
COPY railway-proxy.mjs /usr/local/lib/railway-proxy.mjs
RUN chmod +x /usr/local/bin/railway-start.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/railway-start.sh"]
