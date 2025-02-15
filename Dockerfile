# Usar una imagen oficial de PHP con Apache
FROM php:8.2-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    git \
    unzip \
    zip \
    && docker-php-ext-install intl pdo pdo_mysql opcache mysqli \
    && docker-php-ext-enable mysqli

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Definir directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos de la aplicación
COPY . .

# 🔹 Crear directorios si no existen
RUN mkdir -p var public

# 🔹 Establecer permisos en directorios existentes
RUN chown -R www-data:www-data var public

# Configurar Apache
RUN a2enmod rewrite
RUN service apache2 restart

EXPOSE 80

# Comando de inicio
CMD ["apache2-foreground"]