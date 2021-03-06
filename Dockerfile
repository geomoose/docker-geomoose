# Mapserver for Docker
FROM ubuntu:trusty
MAINTAINER Fabien Reboia<srounet@gmail.com>

ENV LANG C.UTF-8
RUN update-locale LANG=C.UTF-8

# Update and upgrade system
RUN apt-get -qq update --fix-missing && apt-get -qq --yes upgrade

# Install mapcache compilation prerequisites
RUN apt-get install -y software-properties-common g++ make cmake wget git openssh-server

# Install mapcache dependencies provided by Ubuntu repositories
RUN apt-get install -y \
    libxml2-dev \
    libxslt1-dev \
    libproj-dev \
    libfribidi-dev \
    libcairo2-dev \
    librsvg2-dev \
    libmysqlclient-dev \
    libpq-dev \
    libcurl4-gnutls-dev \
    libexempi-dev \
    libgdal-dev \
    libgeos-dev

# Install libharfbuzz from source as it is not in a repository
RUN apt-get install -y bzip2
RUN cd /tmp && wget http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.19.tar.bz2 && \
    tar xjf harfbuzz-0.9.19.tar.bz2 && \
    cd harfbuzz-0.9.19 && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# Apache 2
RUN apt-get update && apt-get install -y apache2 apache2-threaded-dev curl

# Configure localhost in Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
COPY etc/000-default.conf /etc/apache2/sites-available/

# Install the Apache Worker MPM (Multi-Procesing Modules)
RUN sudo apt-get install apache2-mpm-worker

# To reconcile this, the multiverse repository must be added to the apt sources.
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty multiverse' >> /etc/apt/sources.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty-updates multiverse' >> /etc/apt/sources.list
RUN echo 'deb http://security.ubuntu.com/ubuntu trusty-security multiverse' >> /etc/apt/sources.list
RUN sudo apt-get update

# Install PHP5 and necessary modules
RUN sudo apt-get install -y libapache2-mod-fastcgi php5-fpm libapache2-mod-php5 php5-common php5-cli php5-fpm php5 php5-dev php5-gd php5-curl

# Enable these Apache modules
RUN sudo a2enmod actions cgi alias

# Apache configuration for PHP-FPM
COPY etc/php5-fpm.conf /etc/apache2/conf-available/

# Install supervisor
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
COPY etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create the following PHP file in the document root /var/www
RUN echo '<?php phpinfo();' > /var/www/html/info.php

# Install Mapserver itself
RUN git clone https://github.com/mapserver/mapserver/ /usr/local/src/mapserver

# Compile Mapserver for Apache
RUN mkdir /usr/local/src/mapserver/build && \
    cd /usr/local/src/mapserver/build && \
    cmake ../ -DWITH_THREAD_SAFETY=1 \
        -DWITH_PROJ=1 \
        -DWITH_KML=1 \
        -DWITH_SOS=1 \
        -DWITH_WMS=1 \
        -DWITH_FRIBIDI=1 \
        -DWITH_HARFBUZZ=1 \
        -DWITH_ICONV=1 \
        -DWITH_CAIRO=1 \
        -DWITH_RSVG=1 \
        -DWITH_MYSQL=1 \
        -DWITH_GEOS=1 \
        -DWITH_POSTGIS=1 \
        -DWITH_GDAL=1 \
        -DWITH_OGR=1 \
        -DWITH_CURL=1 \
        -DWITH_CLIENT_WMS=1 \
        -DWITH_CLIENT_WFS=1 \
        -DWITH_WFS=1 \
        -DWITH_WCS=1 \
        -DWITH_LIBXML2=1 \
        -DWITH_GIF=1 \
        -DWITH_EXEMPI=1 \
        -DWITH_XMLMAPFILE=1 \
	-DWITH_PHP=1 \
    -DWITH_FCGI=0 && \
    make && \
    make install && \
    ldconfig

# Install MapScript / PHP
RUN echo 'extension=php_mapscript.so' > /etc/php5/mods-available/mapscript.ini
RUN sudo ln -s /etc/php5/mods-available/mapscript.ini /etc/php5/apache2/conf.d/30-mapscript.ini


# Link to cgi-bin executable
RUN chmod o+x /usr/local/bin/mapserv
RUN ln -s /usr/local/bin/mapserv /usr/lib/cgi-bin/mapserv
RUN chmod 755 /usr/lib/cgi-bin


# Install GeoMOOSE
RUN git clone --recursive https://github.com/geomoose/geomoose.git /usr/local/geomoose

# Intall the local settings
COPY etc/local_settings.ini /usr/local/geomoose/conf

# Restart Apache
RUN sudo service apache2 restart


# SSH config
RUN mkdir /var/run/sshd
RUN echo 'root:toor' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22 80

ENV HOST_IP `ifconfig | grep inet | grep Mask:255.255.255.0 | cut -d ' ' -f 12 | cut -d ':' -f 2`

CMD ["/usr/bin/supervisord"]
