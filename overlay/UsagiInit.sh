#!/UsagiInit
mkdir -p /tmp/nginx/logs
envsubst < /etc/nginx/templates/settings.js.template > /etc/nginx/conf.d/settings.js
/ChordDHT-Node -uri $NODE_URI -tracker-url $TRACKER_URL -listen :8443 -tls-cert /etc/ssl/selfsigned/server.crt -tls-key /etc/ssl/selfsigned/server.key -skip-tls-verify &
/usr/sbin/nginx -p /tmp/nginx -c /etc/nginx/nginx.conf -g "daemon off;" &
/usr/local/bin/cloudflared tunnel --no-autoupdate run --token $CLOUDFLARE_TOKEN > /dev/null 2>&1 &
