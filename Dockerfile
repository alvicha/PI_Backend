# Usar una imagen base de PHP-FPM en Alpine
FROM php:8.2-fpm-alpine

# Instalar dependencias necesarias y Nginx
RUN apk update && apk add --no-cache \
    nginx \
    icu-dev \
    libpq-dev \
    git \
    unzip \
    zip \
    && docker-php-ext-install intl pdo pdo_mysql opcache \
    && docker-php-ext-enable opcache

# Instalar Composer (para gestionar dependencias de Symfony)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configurar el directorio de trabajo en la ruta de Symfony
WORKDIR /var/www/html

# Copiar los archivos del proyecto Symfony al contenedor
COPY . /var/www/html

# Instalar las dependencias de Symfony usando Composer
RUN composer install --optimize-autoloader --no-interaction

# Copiar la configuración de Nginx a la ruta correcta dentro del contenedor
COPY nginx.conf /etc/nginx/nginx.conf

# Habilitar la configuración de Nginx
RUN rm -f /etc/nginx/sites-enabled/default && ln -s /etc/nginx/nginx.conf /etc/nginx/sites-enabled/default

# Establecer permisos correctos para los archivos y directorios de Symfony
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Exponer el puerto 80 para Nginx
EXPOSE 80

# Comando de inicio para PHP-FPM y Nginx
CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]