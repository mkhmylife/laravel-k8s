ARG PHP_EXTENSIONS="apcu bcmath opcache pcntl pdo_mysql redis zip sockets imagick gd exif"
FROM thecodingmachine/php:7.3-v2-slim-apache as php_base
ENV TEMPLATE_PHP_INI=production \
    APACHE_DOCUMENT_ROOT=/var/www/html/public
COPY --chown=docker:docker . /var/www/html
RUN composer install --quiet --optimize-autoloader --no-dev

FROM node:10 as node_dependencies
WORKDIR /var/www/html
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false
COPY --from=php_base /var/www/html /var/www/html
RUN npm set progress=false && \
    npm config set depth 0 && \
    npm install && \
    npm run prod && \
    rm -rf node_modules

FROM php_base
COPY --from=node_dependencies --chown=docker:docker /var/www/html /var/www/html


