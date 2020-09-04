#FROM debian:jessie
FROM php:7.2-apache

MAINTAINER Alexandru Voinescu "voinescu.alex@gmail.com"

# Setup environment
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update -y --fix-missing
RUN apt-get install wget apt-transport-https lsb-release ca-certificates -y
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN apt-get update -y
RUN apt-get install apache2 mysql-client -y
RUN apt-get install php7.2 -y
RUN apt-get install php7.2-dev -y
RUN apt-get install php7.2-xml -y
RUN apt-get install php7.2-opcache -y
RUN apt-get install php7.2-mysql -y
RUN apt-get install php7.2-zip -y
RUN apt-get install php7.2-curl -y
RUN apt-get install libapache2-mod-php7.2 -y
RUN apt-get install php7.2-mbstring -y
RUN apt-get install php-pear -y
RUN apt-get install curl -y
RUN pecl install timecop-beta
RUN echo "extension=timecop.so" >> /etc/php/7.2/cli/php.ini
RUN php -v

EXPOSE 80
EXPOSE 3306

ENV MYSQL_ROOT_PASSWORD nopass
RUN export MYSQL_ROOT_PASSWORD=nopass

RUN apt-get install mysql-server -y
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
RUN echo "extension=timecop.so" >> /etc/php/7.2/apache2/php.ini


RUN curl -sS https://getcomposer.org/installer | php
RUN chmod +x composer.phar
RUN mv composer.phar /usr/local/bin/composer
RUN composer -V
