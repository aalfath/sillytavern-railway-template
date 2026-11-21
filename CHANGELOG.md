# Changelog

## 1.19.1 (2026-11-21): security release

- No breaking changes. Characters, chats and settings on the `/data` volume and your basic-auth password are kept.
- SillyTavern [1.19.1](https://github.com/SillyTavern/SillyTavern/releases/tag/1.19.1) is a security release that upstream recommends for everyone: `<style>` blocks in chat messages and creator notes could let a crafted character card, imported chat or model response run scripts in the app; CharX and BYAF imports could overwrite other character files; the user backup and delete endpoints accepted handles of users that don't exist.
- Image: `ghcr.io/sillytavern/sillytavern:1.19.1@sha256:660d1a23c70517fa6d5b9b76f4456ee11f002cd911007d838569e4a771a096bc`.

## Unreleased (2026-11-16)

- README: Deploy on Railway button for the published template `sillytavern-1`. No change to the image or the app.

## 1.19.0 (2026-11-16)

- First release of the template: SillyTavern 1.19.0 (`ghcr.io/sillytavern/sillytavern:1.19.0@sha256:eef27ff0c7961f1a2f488400f581f48ff38f8b910c5d3b8d389138d71791bb14`).
- Basic auth always on with a generated password, one volume at `/data`, health check at `/healthz`.
