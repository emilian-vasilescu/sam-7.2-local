#FROM debian:jessie
FROM php:7.2-apache

MAINTAINER Alexandru Voinescu "voinescu.alex@gmail.com"

# Setup environment
ENV DEBIAN_FRONTEND noninteractive

RUN php -v
RUN php --ini
RUN apt-get update -y --fix-missing
RUN apt-get install libzip-dev zlib1g-dev authbind curl libpq-dev -y
RUN apt-get install apache2 mariadb-client -y
RUN pecl install timecop-beta
RUN echo "extension=timecop.so" >> /usr/local/etc/php/php.ini
RUN docker-php-ext-install pdo pdo_mysql mysqli zip opcache sockets > /dev/null

EXPOSE 80
EXPOSE 3306

ENV MYSQL_ROOT_PASSWORD nopass
RUN export MYSQL_ROOT_PASSWORD=nopass

RUN apt-get install mariadb-server -y
WORKDIR /etc/mysql/
RUN sed -i '/^bind-address		= 127.0.0.1$/s/^/#/' my.cnf
RUN sed '/bind-address		= 127.0.0.1/a skip-name-resolve' my.cnf
WORKDIR /usr/local/
RUN mkdir sam-tool-database
WORKDIR /usr/local/sam-tool-database/
COPY samtool.sql.zip samtool.sql.zip

RUN export APPLICATION_ENV=test
WORKDIR /etc/apache2/conf-available/
COPY sam.conf sam.conf
RUN a2enconf sam.conf

WORKDIR /
RUN mkdir -p builds/bi/sam-tool/web
WORKDIR /etc/apache2/sites-available/
COPY local.sam.tool.conf local.sam.tool.conf
RUN a2ensite local.sam.tool
RUN echo '127.0.0.1 local.sam.tool' >> /etc/hosts
RUN echo '127.0.0.1 mysql_tests_host' >> /etc/hosts
RUN a2enmod rewrite

RUN curl -sS https://getcomposer.org/installer | php
RUN chmod +x composer.phar
RUN mv composer.phar /usr/local/bin/composer
RUN composer -V
