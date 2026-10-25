#!/bin/sh
# Render'ın verdiği portu Nginx için kullan, Node.js API'sini 3000 portunda başlat
export NGINX_PORT=${PORT:-10000}
export BACKEND_PORT=3000

echo "Starting Node.js backend on port $BACKEND_PORT..."
PORT=$BACKEND_PORT node /app/api/server.js &

echo "Processing Nginx configuration template..."
envsubst '$NGINX_PORT $PORT $BACKEND $RESOLVER $CF_CONNECTING_IP $BASE_PATH $MEDIA_UPLOAD_MAX $CONTENT_SECURITY_POLICY' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

echo "Starting Nginx on port $NGINX_PORT..."
exec nginx -g 'daemon off;'
