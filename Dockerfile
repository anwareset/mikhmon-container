FROM alpine:latest AS sourcecode
RUN apk add --no-cache unzip curl \
    && curl -LJO https://github.com/laksa19/mikhmonv3/archive/refs/heads/master.zip \
    && unzip mikhmon*.zip \
    && rm -rf mikhmon*.zip \
    && mv -f mikhmon* /tmp/mikhmon \
    && rm -rf mikhmon*

FROM php:7.4-cli-alpine
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
    org.label-schema.docker.cmd="docker run -v .:/var/www/html -p 80:80 -d trianwar/mikhmon" \
    org.label-schema.description="MIKHMON (MikroTik Hotspot Monitor) V3 by laksa19 inside container."
WORKDIR /var/www/html
COPY --from=sourcecode /tmp/mikhmon ./
VOLUME ["/var/www/html"]
EXPOSE 80
CMD ["php", "-S", "0.0.0.0:80"]

