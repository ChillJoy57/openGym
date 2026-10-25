#!/bin/sh
# Render'ın verdiği PORT (örn: 10000) NGINX_PORT olacak, 
# arka plandaki Node.js API'si ise 3000 portunda çalışacak.
export NGINX_PORT=${PORT:-10000}
export BACKEND_PORT=3000

echo "Starting Node.js backend on port $BACKEND_PORT..."
PORT=$BACKEND_PORT node /app/api/server.js &

echo "Starting Nginx on port $NGINX_PORT..."
nginx -g 'daemon off;'
