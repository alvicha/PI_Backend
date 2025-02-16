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
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Definir directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos de la aplicación
COPY . /var/www/html

# 🔹 Crear directorios si no existen
RUN mkdir -p var public

# 🔹 Establecer permisos en directorios existentes
RUN chown -R www-data:www-data /var/www/html

# 🔹 Establecer permisos correctos para los archivos
RUN chmod -R 755 /var/www/html

# Configurar Apache
RUN a2enmod rewrite
RUN service apache2 restart

# Exponer el puerto 80
EXPOSE 80

# Comando de inicio para el contenedor
CMD ["apache2-foreground"]
