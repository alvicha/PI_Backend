# Usar una imagen oficial de PHP con Apache
FROM php:8.2-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    git \
    unzip \
    zip \
    && docker-php-ext-install intl pdo pdo_mysql opcache

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar archivos de la aplicación
WORKDIR /var/www/html
COPY . .

# Establecer permisos
RUN chown -R www-data:www-data /var/www/html/var /var/www/html/public

# Configurar Apache
RUN a2enmod rewrite
RUN service apache2 restart

EXPOSE 80

# Comando de inicio
CMD ["apache2-foreground"]