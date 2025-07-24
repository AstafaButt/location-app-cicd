# Use the PHP 8.2 FPM Alpine image as the base
FROM php:8.2-fpm-alpine

# Accept UID and GID as build arguments
ARG UID=1000
ARG GID=1000

# Install required extensions and tools
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    unzip \
    bash \
    git \
    curl \
    shadow  # needed for usermod/usermod-style commands

# Configure GD extension for image processing
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create user and group with specified UID/GID
RUN addgroup -g ${GID} appgroup \
    && adduser -D -G appgroup -u ${UID} appuser \
    && mkdir -p /app/storage /app/bootstrap/cache \
    && chown -R appuser:appgroup /app

# Set working directory
WORKDIR /app

# Copy application files into the container
COPY . .

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions again after copying
RUN chown -R appuser:appgroup /app

# Switch to non-root user (optional but recommended)
USER appuser

# Expose port
EXPOSE 8181

# Start PHP-FPM
CMD ["php-fpm"]
