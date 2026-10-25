#!/bin/sh
# Render'ın dış dünyadan dinlemesini istediği port NGINX_PORT olur
export NGINX_PORT=${PORT:-10000}
# Arka plan Node.js ve Nginx'in haberleşeceği iç port
export BACKEND_PORT=3001

echo "Starting Node.js backend on internal port $BACKEND_PORT..."
PORT=$BACKEND_PORT node /app/api/server.js &

echo "Processing Nginx configuration template..."
envsubst '$NGINX_PORT $BACKEND_PORT $BACKEND $RESOLVER $CF_CONNECTING_IP $BASE_PATH $MEDIA_UPLOAD_MAX $CONTENT_SECURITY_POLICY' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

echo "Starting Nginx on primary port $NGINX_PORT..."
exec nginx -g 'daemon off;'
