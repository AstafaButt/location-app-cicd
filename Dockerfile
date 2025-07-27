# Use PHP 8.2 FPM Alpine as the base
FROM php:8.2-fpm-alpine

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    unzip \
    bash \
    git \
    curl \
    oniguruma-dev \
    icu-dev \
    libxml2-dev

# GD extension config and install common PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo \
        pdo_mysql \
        mysqli \
        intl \
        mbstring \
        xml

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Ensure storage and bootstrap/cache directories exist
RUN mkdir -p /app/storage/framework/{cache,sessions,views} /app/bootstrap/cache

# Set proper permissions
RUN chmod -R 777 /app/storage /app/bootstrap/cache

# Install Laravel dependencies (with optimized autoloader)
RUN composer install --no-dev --optimize-autoloader

# Expose port for PHP-FPM (not usually needed directly)
EXPOSE 8181

# Start PHP-FPM
CMD ["php-fpm"]
