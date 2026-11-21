[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/sillytavern-1?utm_medium=integration&utm_source=button&utm_campaign=sillytavern)

# SillyTavern on Railway

This repo is the source of the **SillyTavern** Railway template. It deploys [SillyTavern](https://github.com/SillyTavern/SillyTavern) **1.19.1**, the official image `ghcr.io/sillytavern/sillytavern:1.19.1`, pinned by digest in the `Dockerfile`.

## What the template deploys

One service, built from this repo:

- SillyTavern 1.19.1, password-protected with HTTP basic auth (always on: the container refuses to start without a password).
- A Railway volume at `/data` holding SillyTavern's `config`, `data` (characters, chats, settings, user files), `plugins`, third-party `extensions` and `backups`. Everything survives redeploys and updates.
- A small built-in proxy listens on `PORT` (8080) and forwards to SillyTavern on `127.0.0.1:8000`. It also answers `/healthz` without a login, which Railway uses as the health check.

## Variables

| Variable | Default | What it is |
|---|---|---|
| `SILLYTAVERN_BASICAUTHUSER_USERNAME` | `admin` | Login username |
| `SILLYTAVERN_BASICAUTHUSER_PASSWORD` | generated (`${{secret(32)}}`) | Login password. Find it in the service's Variables tab |
| `PORT` | `8080` | Port the proxy listens on (the Railway domain points here) |

Any other SillyTavern setting can be set as an environment variable: `SILLYTAVERN_` plus the `config.yaml` key in upper case, with dots as underscores (for example `SILLYTAVERN_ENABLEUSERACCOUNTS=true`). The wrapper fixes `listen`, `port`, `whitelistMode=false` and `basicAuthMode=true`.

## After deploying

1. Open the service's public URL and log in with the username and password from the Variables tab.
2. In the API Connections panel, add your LLM provider (OpenAI, Anthropic, OpenRouter, a KoboldCpp or Ollama server, and so on) with your own API key.

## Updates

Each change to this repo's `main` branch (for example a new SillyTavern version) shows up as an "update available" notice in the Railway projects deployed from the template. You choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first. Your data stays on the volume.
