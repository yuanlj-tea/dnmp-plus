ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

ARG PHP_EXTENSIONS
ARG MORE_EXTENSION_INSTALLER
ARG ALPINE_REPOSITORIES
ARG INSTALL_LARAVEL

#COPY ./conf/resolv.conf /etc/resolv.conf
COPY ./conf/sources.list /etc/apt/sources.list
COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions

ENV EXTENSIONS=",${PHP_EXTENSIONS},"
ENV MC="-j$(nproc)"

# Install modules
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libicu-dev \
        wget \
        git \
        librabbitmq-dev \
        apt-utils \
        net-tools \
        iputils-ping \
        --no-install-recommends


RUN export MC="-j$(nproc)" \
    && chmod +x install.sh \
    && chmod +x "${MORE_EXTENSION_INSTALLER}" \
    && sh install.sh \
    && sh "${MORE_EXTENSION_INSTALLER}" \
    && rm -rf /tmp/extensions

# composer
RUN curl -sS https://getcomposer.org/installer | php \
    && cp composer.phar /usr/bin/composer \
    && mv composer.phar /usr/local/bin/composer
## use aliyun composer
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
&& composer global require hirak/prestissimo

WORKDIR /var/www/html

#RUN cd /var/www/html && composer create-project --prefer-dist laravel/laravel blog "5.8.*"

