#!/bin/sh
envsubst < /etc/nginx/templates/settings.js.template > /etc/nginx/conf.d/settings.js
exec sleep infinity
