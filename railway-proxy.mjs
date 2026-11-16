// Minimal reverse proxy: $PORT -> SillyTavern on 127.0.0.1:8000.
// /healthz answers 200 without a login once SillyTavern responds (any status).
import http from 'node:http';
import net from 'node:net';

const port = Number(process.env.PORT || 8080);
const upstreamPort = Number(process.env.ST_UPSTREAM_PORT || 8000);
const upstreamHost = '127.0.0.1';

function probe(cb) {
  const req = http.request({ host: upstreamHost, port: upstreamPort, path: '/', method: 'HEAD', timeout: 3000 }, (res) => { res.resume(); cb(true); });
  req.on('timeout', () => req.destroy());
  req.on('error', () => cb(false));
  req.end();
}

const server = http.createServer((req, res) => {
  if (req.url === '/healthz') {
    return probe((ok) => { res.writeHead(ok ? 200 : 503, { 'content-type': 'text/plain' }); res.end(ok ? 'ok' : 'starting'); });
  }
  const headers = { ...req.headers };
  const peer = req.socket.remoteAddress || '';
  headers['x-forwarded-for'] = headers['x-forwarded-for'] ? `${headers['x-forwarded-for']}, ${peer}` : peer;
  if (!headers['x-real-ip']) headers['x-real-ip'] = String(headers['x-forwarded-for']).split(',')[0].trim();
  const up = http.request({ host: upstreamHost, port: upstreamPort, path: req.url, method: req.method, headers }, (upRes) => {
    res.writeHead(upRes.statusCode || 502, upRes.headers);
    upRes.pipe(res);
  });
  up.on('error', () => { if (!res.headersSent) { res.writeHead(502, { 'content-type': 'text/plain' }); } res.end('SillyTavern is starting'); });
  req.pipe(up);
});

// Pass WebSocket upgrades straight through.
server.on('upgrade', (req, socket, head) => {
  const up = net.connect(upstreamPort, upstreamHost, () => {
    let raw = `${req.method} ${req.url} HTTP/${req.httpVersion}\r\n`;
    for (let i = 0; i < req.rawHeaders.length; i += 2) raw += `${req.rawHeaders[i]}: ${req.rawHeaders[i + 1]}\r\n`;
    up.write(raw + '\r\n'); if (head && head.length) up.write(head);
    up.pipe(socket); socket.pipe(up);
  });
  up.on('error', () => socket.destroy()); socket.on('error', () => up.destroy());
});

process.on('uncaughtException', (err) => console.error('[railway-proxy]', err));
server.requestTimeout = 0;
server.headersTimeout = 120000;
server.listen(port, '::', () => console.log(`[railway-proxy] listening on ${port} -> ${upstreamHost}:${upstreamPort}`));
