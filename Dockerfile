FROM requarks/wiki:2

USER root
RUN apk update && apk add --no-cache ca-certificates && update-ca-certificates

ENV PORT=8000

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
CMD ["/bin/sh", "-c", "cat > /wiki/config.yml <<ENDOFFILE\nbindIP: 0.0.0.0\nport: 8000\ndb:\n  type: postgres\n  host: aws-1-eu-west-1.pooler.supabase.com\n  port: 5432\n  user: postgres.qaxbwxmbrlejngsppeaa\n  pass: ${DB_PASS}\n  db: postgres\n  ssl: true\nENDOFFILE\nnode --require /wiki/disable-tls.js --dns-result-order=ipv4first server"]
