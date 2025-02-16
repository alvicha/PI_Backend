# Imagen base con PHP-FPM
FROM php:8.2-fpm

# Instalar extensiones de PHP
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    git \
    unzip \
    zip \
    nginx \
    && docker-php-ext-install intl pdo pdo_mysql opcache \
    && docker-php-ext-enable opcache

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configurar directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos del proyecto Symfony
COPY . /var/www/html

# Establecer permisos correctos
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Exponer el puerto 80
EXPOSE 80

# Configurar Nginx directamente desde el Dockerfile (sin archivo externo)
RUN echo "\
server {\
    listen 80;\
    server_name _;\
    root /var/www/html/public;\
    index index.php;\
    location / {\
        try_files \$uri /index.php\$is_args\$args;\
    }\
    location ~ ^/index\\.php(/|$) {\
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;\
        fastcgi_split_path_info ^(.+\\.php)(/.*)$;\
        include fastcgi_params;\
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;\
        fastcgi_param DOCUMENT_ROOT \$realpath_root;\
        internal;\
    }\
    location ~ \\.php\$ {\
        return 404;\
    }\
    error_log /var/log/nginx/error.log;\
    access_log /var/log/nginx/access.log;\
}" > /etc/nginx/sites-available/default

# Comando de inicio
CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]
