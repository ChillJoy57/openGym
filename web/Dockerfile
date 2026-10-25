# --- Aşama 1: Frontend Build ---
FROM --platform=$BUILDPLATFORM node:22-alpine AS build
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci --ignore-scripts
COPY api/coach/core/ /app/api/coach/core/
COPY frontend/ ./
ARG APP_BUILD=""
RUN APP_BUILD="$APP_BUILD" npm run build

# --- Aşama 2: API Bağımlılıkları ---
FROM node:22-alpine AS api-deps
WORKDIR /app/api
COPY api/package.json api/package-lock.json* ./
RUN npm ci --omit=dev --omit=optional

# --- Aşama 3: Final Nginx + Node.js Birleşik Görüntü ---
FROM nginxinc/nginx-unprivileged:alpine
USER root
RUN apk update && apk add --no-cache nodejs npm

# Nginx güvenlik ve dizin izinleri
RUN sed -i '/^[[:space:]]*user[[:space:]]/d' /etc/nginx/nginx.conf \
 && sed -i 's,\(/var\)\{0\,1\}/run/nginx.pid,/tmp/nginx.pid,' /etc/nginx/nginx.conf \
 && if ! grep -q 'client_body_temp_path' /etc/nginx/nginx.conf; then \
      sed -i "/^http {/a \    proxy_temp_path /tmp/proxy_temp;\n    client_body_temp_path /tmp/client_temp;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n" /etc/nginx/nginx.conf; \
    fi \
 && chown -R nginx:root /var/cache/nginx /etc/nginx \
 && chmod -R g+w /var/cache/nginx /etc/nginx

# API dosyalarını konteykera taşıma
WORKDIR /app/api
COPY --from=api-deps /app/api/node_modules ./node_modules
COPY api/server.js api/push-messages.js api/nudge.js api/nudge-copy.js api/verify-error.js api/password.js api/rate-limit.js api/passkeys-store.js api/device-link.js api/media.js api/queue.js api/sync-stamps.js api/durable.js ./
COPY api/coach ./coach

# Frontend statik dosyalarını Nginx dizinine taşıma
COPY --from=build /app/frontend/dist /usr/share/nginx/html
COPY catalogue/media/ /usr/share/nginx/html/exercise-media/

# Nginx template ve entrypoint ayarları
COPY web/nginx.conf.template /etc/nginx/templates/default.conf.template
COPY web/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Çevre Değişkenleri
ENV NGINX_PORT=10000
ENV PORT=3000
ENV BACKEND=127.0.0.1
ENV RESOLVER=127.0.0.11
ENV CF_CONNECTING_IP=""
ENV BASE_PATH=""
ENV MEDIA_UPLOAD_MAX=48m
ENV CONTENT_SECURITY_POLICY="default-src 'self'; script-src 'self' 'sha256-z/iOLe5i8fD4VNlIXz/4hEayGLTQzoTc52dIY51OjYc='; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob: https:; media-src 'self' blob: https:; font-src 'self' data:; connect-src 'self' https: http:; worker-src 'self'; manifest-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'"

USER root
EXPOSE 10000
CMD ["/entrypoint.sh"]
