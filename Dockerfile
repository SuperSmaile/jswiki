FROM requarks/wiki:2

USER root
RUN apk update && apk add --no-cache ca-certificates && update-ca-certificates

ENV PORT=8000

RUN cat <<'ENDOFFILE' > /wiki/config.yml
bindIP: 0.0.0.0
port: 8000
db:
  type: postgres
  host: aws-1-eu-west-1.pooler.supabase.com
  port: 5432
  user: postgres.qaxbwxmbrlejngsppeaa
  pass: $(DB_PASS)
  db: postgres
  ssl: true
ENDOFFILE

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
CMD ["/bin/sh", "-c", "sed -i \"s|\\$(DB_PASS)|$DB_PASS|\" /wiki/config.yml && node --require /wiki/disable-tls.js --dns-result-order=ipv4first server"]
