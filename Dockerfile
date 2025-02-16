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

# Copiar configuración de Nginx
COPY ./config/nginx.conf /etc/nginx/nginx.conf

# Exponer el puerto 80
EXPOSE 80

# Comando de inicio
CMD service php8.2-fpm start && nginx -g 'daemon off;'