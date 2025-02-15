# Usar una imagen base de PHP con Apache
FROM php:8.2-apache

# Instalar dependencias del sistema y extensiones de PHP necesarias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpq-dev \
    && docker-php-ext-install zip pdo pdo_mysql

# Habilitar el módulo de Apache para Symfony
RUN a2enmod rewrite

# Copiar el código de la aplicación al contenedor
COPY . /var/www/html

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instalar dependencias de Composer
RUN composer install --no-dev --optimize-autoloader

# Limpiar la caché de Symfony
RUN php bin/console cache:clear --env=prod

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html/var

# Exponer el puerto 80
EXPOSE 80