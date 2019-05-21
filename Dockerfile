FROM phusion/baseimage:0.9.19

ARG BUILD_DATE
ARG VERSION
LABEL build_version="RadPenguin version:- ${VERSION} Build-date:- ${BUILD_DATE}"

ENV TZ="America/Edmonton"
ENV LANG en_US.UTF-8
ENV LC_ALL C.UTF-8
ENV LANGUAGE en_US.UTF-8

# Allow adding PPA repos
RUN apt-get -qq update && \
    apt-get -yqq install software-properties-common

# Install Apache
RUN add-apt-repository -y ppa:ondrej/apache2 && apt-get -qq update && \
    apt-get -yqq install \
    apache2 \
    libapache2-mod-php7.0 \
    libapache2-mod-security2 \
    libapache2-mod-wsgi \
    php7.0-cli \
    php7.0-curl \
    php7.0-gd \
    php7.0-intl \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-opcache \
    php7.0-xml

# Enable apache modules
RUN a2enmod \
    actions \
    cgid \
    expires\
    headers \
    macro \
    proxy \
    proxy_connect \
    proxy_html \
    rewrite \
    security2 \
    ssl \
    unique_id \
    wsgi \
    xml2enc

# Install Web Utils
RUN apt-get -qq update && \
    apt-get install -yqq \
      build-essential \
      git \
      libmysqlclient20 \
      libmysqlclient-dev \
      python-dev \
      unzip
RUN curl --silent https://getcomposer.org/composer.phar -o /usr/local/bin/composer && chmod 755 /usr/local/bin/composer

# Change the Apache user so it can read from /etc/apache2/ssl mount
RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

# Update file permissions
RUN chown -R www-data:www-data /var/lib/apache2

# Symlink the log files
RUN ln -sf /dev/stdout /var/log/apache2/access.log
RUN ln -sf /dev/stderr /var/log/apache2/error.log

# Set the timezone to America/Edmonton
RUN ln -sf /usr/share/zoneinfo/America/Edmonton /etc/localtime

# Setup the init scripts
RUN mkdir /etc/service/apache
ADD init-apache.sh /etc/service/apache/run

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]

