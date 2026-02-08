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

RUN cat <<'SCRIPT' > /wiki/start.sh
#!/bin/sh
echo "DB_PASS length: ${#DB_PASS}"
cat > /wiki/config.yml <<YML
bindIP: 0.0.0.0
port: 8000
db:
  type: postgres
  host: aws-1-eu-west-1.pooler.supabase.com
  port: 5432
  user: postgres.qaxbwxmbrlejngsppeaa
  pass: '${DB_PASS}'
  db: postgres
  ssl: true
YML
cat /wiki/config.yml
node --require /wiki/disable-tls.js --dns-result-order=ipv4first server
SCRIPT
RUN chmod +x /wiki/start.sh

EXPOSE 8000
CMD ["/wiki/start.sh"]
