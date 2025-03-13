# Author name: Boni Yeamin
# Email: boniyeamin@gmail.com
# Date: 2022-01-01
# Description: Dockerfile for creating a Docker image for a simple web application using Cacti

# Base image
FROM debian:latest

# Maintainer Information
LABEL maintainer="Boni Yeamin <boniyeamin.cse@gmail.com>"

# Install necessary packages
RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    libapache2-mod-php \
    php-mysql \
    mariadb-server \
    mariadb-client \
    snmp \
    snmpd \
    rrdtool \
    wget \
    unzip \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and set up Cacti
RUN cd /var/www/html && \
    wget https://www.cacti.net/downloads/cacti-latest.tar.gz && \
    tar -zxvf cacti-latest.tar.gz && \
    mv cacti-* cacti && \
    rm cacti-latest.tar.gz

# Set permissions
RUN chown -R www-data:www-data /var/www/html/cacti && \
    chmod -R 755 /var/www/html/cacti

# Configure Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
COPY cacti.conf /etc/apache2/sites-available/cacti.conf
RUN a2ensite cacti.conf && \
    a2enmod rewrite

# Configure MySQL
RUN service mysql start && \
    mysql -e "CREATE DATABASE cacti;" && \
    mysql -e "CREATE USER 'cacti'@'localhost' IDENTIFIED BY 'cactipass';" && \
    mysql -e "GRANT ALL PRIVILEGES ON cacti.* TO 'cacti'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Expose Ports
EXPOSE 80 3306

# Start Services
CMD ["/bin/bash", "-c", "service mysql start && service apache2 start && tail -f /dev/null"]