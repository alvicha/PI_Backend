FROM php:8.2-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip intl

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copiar el código de la aplicación al contenedor
COPY . /var/www/html/mi_proyecto

# Establecer el directorio de trabajo
WORKDIR /var/www/html/mi_proyecto

# Ejecutar Composer para instalar dependencias
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-cache

# Establecer permisos para el servidor web
RUN chown -R www-data:www-data /var/www/html/mi_proyecto

# Exponer el puerto 80 para Apache
EXPOSE 80
