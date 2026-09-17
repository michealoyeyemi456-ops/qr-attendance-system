FROM php:8.3-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install SQLite and PDO extensions
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    sqlite3 \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo pdo_sqlite pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Set DocumentRoot to /var/www/html
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html/

# If bundle.zip exists, automatically unpack all subdirectories & files
RUN if [ -f /var/www/html/bundle.zip ]; then (unzip -o -q /var/www/html/bundle.zip -d /var/www/html/ || true) && rm -f /var/www/html/bundle.zip; fi

# Ensure database directory exists and set permissions safely
RUN mkdir -p /var/www/html/database \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 777 /var/www/html/database \
    && chmod -R 755 /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]
