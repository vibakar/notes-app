#!/bin/sh

envsubst < /usr/share/nginx/html/runtime-config.template.js > /usr/share/nginx/html/runtime-config.js

exec nginx -g 'daemon off;'