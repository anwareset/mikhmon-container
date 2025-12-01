FROM alpine:latest AS sourcecode
RUN apk add --no-cache unzip curl \
    && curl -LJO https://github.com/laksa19/mikhmonv3/archive/refs/heads/master.zip \
    && unzip *.zip \
    && rm -rf *.zip \
    && mv -f mikhmon* /tmp/mikhmon

FROM php:7.4-fpm-alpine
ARG BUILD_DATE
ARG BUILD_VERSION
LABEL org.opencontainers.image.authors="trianwar@pm.me" \
    org.label-schema.authors="trianwar@pm.me" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="trianwar/mikhmon" \
    org.label-schema.url="https://init.web.id" \
    org.label-schema.vcs-url="https://github.com/anwareset/mikhmon-container" \
    org.label-schema.version=$BUILD_VERSION \
    org.label-schema.docker.cmd="docker run --name mikhmon-app -d -p 8080:8080 -v mikhmon-volume trianwar/mikhmon" \
    org.label-schema.description="MIKHMON (MikroTik Hotspot Monitor) V3 by laksa19 inside container."

# Install system dependencies and PHP extensions
RUN apk add --no-cache curl unzip gmp-dev gettext-dev libpng-dev libjpeg-turbo-dev zlib-dev nginx supervisor \
    && docker-php-ext-install gmp gettext pcntl gd session \
    && docker-php-ext-enable gmp gettext pcntl gd session

WORKDIR /var/www/mikhmon
COPY --from=sourcecode /tmp/mikhmon ./

# Copy nginx and supervisord configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisord.conf

VOLUME ["/var/www/mikhmon"]
EXPOSE 8080

# Start supervisord to manage both nginx and php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
