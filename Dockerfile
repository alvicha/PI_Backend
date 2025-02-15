# Usa la imagen oficial de PHP con Apache
FROM php:8.2-apache

# Instalar dependencias necesarias (como extensiones de PHP)
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    git \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl pdo pdo_pgsql

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar el código fuente del proyecto
COPY . /var/www/html/

# Establecer permisos
RUN chown -R www-data:www-data /var/www/html/var

# Habilitar el módulo de reescritura de Apache (para Symfony)
RUN a2enmod rewrite

# Exponer el puerto 80
EXPOSE 80

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Ejecutar Composer install
RUN composer install --no-interaction --optimize-autoloader

# Configurar Apache
CMD ["apache2-foreground"]
