# Imagen base con PHP-FPM
FROM php:8.2-fpm

# Instalar dependencias necesarias y Nginx
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

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Copiar los archivos del proyecto Symfony
COPY . /var/www/html

# Instalar las dependencias de Composer
RUN composer install --optimize-autoloader --no-interaction

# Copiar la configuración de Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Habilitar la configuración de Nginx
RUN rm -f /etc/nginx/sites-enabled/default && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Establecer permisos
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Exponer el puerto 80
EXPOSE 80

# Comando de inicio para PHP-FPM y Nginx
CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]
