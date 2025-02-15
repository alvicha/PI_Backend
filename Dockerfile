FROM php:8.1-apache

# Instalar dependencias del sistema necesarias para PHP y las extensiones
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip intl

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copiar el código de la aplicación al contenedor
COPY . /var/www/html/

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Ejecutar Composer para instalar dependencias
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-cache

# Establecer permisos para el servidor web
RUN chown -R www-data:www-data /var/www/html

# Exponer el puerto 80 para Apache
EXPOSE 80
