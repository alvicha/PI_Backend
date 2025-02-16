# Imagen base con PHP-FPM
FROM php:8.2-fpm

# Instalar dependencias y Nginx
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

# Copiar archivos del proyecto Symfony
WORKDIR /var/www/html
COPY . /var/www/html

# Establecer permisos correctos
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Exponer el puerto 80
EXPOSE 80

# Configurar Nginx para Symfony directamente desde el Dockerfile
RUN echo "\
server {\n\
    listen 80;\n\
    server_name _;\n\
    root /var/www/html/public;\n\
    index index.php;\n\
\n\
    location / {\n\
        try_files \$uri /index.php\$is_args\$args;\n\
    }\n\
\n\
    location ~ ^/index\\.php(/|$) {\n\
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;\n\
        fastcgi_split_path_info ^(.+\\.php)(/.*)$;\n\
        include fastcgi_params;\n\
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;\n\
        fastcgi_param DOCUMENT_ROOT \$realpath_root;\n\
        internal;\n\
    }\n\
\n\
    location ~ \\.php\$ {\n\
        return 404;\n\
    }\n\
\n\
    error_log /var/log/nginx/error.log;\n\
    access_log /var/log/nginx/access.log;\n\
}" > /etc/nginx/sites-available/default

# Comando de inicio
CMD ["sh", "-c", "service php8.2-fpm start && exec nginx -g 'daemon off;'"]
