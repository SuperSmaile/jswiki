FROM requarks/wiki:2

USER root
RUN apk update && apk add --no-cache ca-certificates && update-ca-certificates

RUN cat <<'EOF' > /wiki/disable-tls.js
const tls = require('tls');
const origConnect = tls.connect;
tls.connect = function(...args) {
  if (args[0] && typeof args[0] === 'object') {
    args[0].rejectUnauthorized = false;
  }
  return origConnect.apply(this, args);
};
EOF

EXPOSE 8000
CMD ["node", "--require", "/wiki/disable-tls.js", "--dns-result-order=ipv4first", "server"]
