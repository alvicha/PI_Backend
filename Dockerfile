FROM php:8.2-apache

# Instala extensiones necesarias para Symfony y bases de datos
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev zip unzip git curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mysqli opcache

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Habilita mod_rewrite para el funcionamiento correcto de Symfony
RUN a2enmod rewrite

# Configura el directorio de trabajo para la API
WORKDIR /var/www/html/proyecto

# Copia los archivos del proyecto
COPY . /var/www/html/php_pinacoteca

# Instala las dependencias de Symfony
RUN composer install --no-dev --optimize-autoloader

# Establece permisos correctos para Apache y Symfony
RUN chown -R www-data:www-data /var/www/html/proyecto \
    && chmod -R 775 /var/www/html/proyecto

# Expone el puerto 80
EXPOSE 80

# Configura las variables de entorno
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Inicia Apache en primer plano
CMD ["apache2-foreground"]
