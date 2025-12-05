FROM php:7.4-fpm-alpine
ARG BUILD_DATE
ARG BUILD_VERSION
LABEL org.opencontainers.image.authors="trianwar@pm.me" \
    org.label-schema.authors="trianwar@pm.me" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="trianwar/mikhmon" \
    org.label-schema.url="https://deployer.dpdns.org" \
    org.label-schema.vcs-url="https://github.com/anwareset/mikhmon-container" \
    org.label-schema.version=$BUILD_VERSION \
    org.label-schema.docker.cmd="docker run --name mikhmon-app -d -p 8080:8080 -v mikhmon-volume trianwar/mikhmon" \
    org.label-schema.description="MIKHMON (MikroTik Hotspot Monitor) V3 by laksa19 inside container."
RUN apk add --no-cache curl unzip gmp-dev gettext-dev libpng-dev libjpeg-turbo-dev zlib-dev fcgi nginx supervisor && \
    docker-php-ext-install gmp gettext pcntl gd session && \
    docker-php-ext-enable gmp gettext pcntl gd session && \
    rm -rf /var/cache/apk/* /tmp/* && \
    curl -LJO https://github.com/laksa19/mikhmonv3/archive/refs/heads/master.zip && \
    unzip *.zip && \
    rm -rf *.zip && \
    cp -R mikhmon* /tmp/mikhmon && \
    rm -rf /etc/nginx/nginx.conf && \
    mkdir -p /etc/supervisor/conf.d
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
WORKDIR /var/www/mikhmon
RUN mkdir -p /var/www/mikhmon/storage && \
    chown -R www-data:www-data /var/www/mikhmon && \
    chmod -R 755 /var/www/mikhmon && \
    chmod +x /entrypoint.sh
VOLUME ["/var/www/mikhmon"]
EXPOSE 8080
HEALTHCHECK --interval=20s --timeout=5s --start-period=15s --retries=3 \
  CMD if [ "$MODE" = "caddy" ]; then \
        cgi-fcgi -bind -connect 127.0.0.1:9000 >/dev/null 2>&1 || exit 1; \
      else \
        curl -fsS http://127.0.0.1:8080 >/dev/null 2>&1 || exit 1; \
      fi
ENTRYPOINT ["/entrypoint.sh"]
