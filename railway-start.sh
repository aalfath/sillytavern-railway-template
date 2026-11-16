#!/bin/sh
# Railway wrapper for SillyTavern.
# - Keeps config, data, plugins and third-party extensions on one volume (/data).
# - Forces password protection (HTTP basic auth) and refuses to start without a password.
# - Runs SillyTavern on 127.0.0.1:8000 behind a tiny proxy on $PORT that also answers
#   /healthz without a login, so Railway's health check works.
set -eu

DATA_DIR="${RAILWAY_DATA_DIR:-/data}"
APP=/home/node/app

if [ -z "${SILLYTAVERN_BASICAUTHUSER_PASSWORD:-}" ]; then
  echo "SILLYTAVERN_BASICAUTHUSER_PASSWORD is empty: refusing to start an unprotected SillyTavern." >&2
  exit 1
fi
export SILLYTAVERN_BASICAUTHUSER_USERNAME="${SILLYTAVERN_BASICAUTHUSER_USERNAME:-admin}"

# Fixed settings (environment variables override config.yaml in SillyTavern).
export SILLYTAVERN_LISTEN=true
export SILLYTAVERN_PORT=8000
export SILLYTAVERN_LISTENADDRESS_IPV4=127.0.0.1
export SILLYTAVERN_PROTOCOL_IPV6=false
export SILLYTAVERN_WHITELISTMODE=false
export SILLYTAVERN_BASICAUTHMODE=true
export SILLYTAVERN_BROWSERLAUNCH_ENABLED=false
export SILLYTAVERN_RATELIMITING_PREFERREALIPHEADER="${SILLYTAVERN_RATELIMITING_PREFERREALIPHEADER:-true}"
export SILLYTAVERN_SECURITYOVERRIDE=false

# Persist everything on the volume through symlinks.
mkdir -p "$DATA_DIR"
cd "$APP"
for pair in config:config data:data plugins:plugins public/scripts/extensions/third-party:extensions backups:backups; do
  src="${pair%%:*}"; dst="$DATA_DIR/${pair##*:}"
  mkdir -p "$dst"
  if [ ! -L "$src" ]; then
    # Seed the volume with anything the image ships in that folder (first boot only).
    if [ -d "$src" ]; then cp -an "$src/." "$dst/" 2>/dev/null || true; rm -rf "$src"; fi
    ln -s "$dst" "$src"
  fi
done

export ST_UPSTREAM_PORT=8000
node /usr/local/lib/railway-proxy.mjs &

exec ./docker-entrypoint.sh "$@"
