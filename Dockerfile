FROM alpine AS builder
RUN apk --no-cache add wget unzip
RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 --directory-prefix=/tmp/confd/ -q
RUN wget https://github.com/ampache/ampache/releases/download/4.1.1/ampache-4.1.1_all.zip -q &&\
    mkdir /tmp/ampache &&\
    unzip ampache-4.1.1_all.zip -d /tmp/ampache &&\
    rm ampache-4.1.1_all.zip &&\
    mv /tmp/ampache/channel/.htaccess.dist /tmp/ampache/channel/.htaccess &&\
    mv /tmp/ampache/play/.htaccess.dist /tmp/ampache/play/.htaccess &&\
    mv /tmp/ampache/rest/.htaccess.dist /tmp/ampache/rest/.htaccess




FROM php:7.4.8-apache-buster
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd pdo_mysql &&\
    a2enmod rewrite &&\
    sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
COPY --from=builder /tmp/confd/confd-0.16.0-linux-amd64 /opt/confd/bin/confd
RUN chmod +x /opt/confd/bin/confd
ENV PATH="/opt/confd/bin:${PATH}"
COPY config/ampache.toml /etc/confd/conf.d/ampache.toml
COPY --from=builder /tmp/ampache /var/www/html
COPY config/ampache.cfg.php.tmpl /etc/confd/templates/ampache.cfg.php.tmpl
RUN mkdir -m 777 /var/log/ampache
COPY custom-entrypoint /usr/local/bin/custom-entrypoint
RUN chmod 544 /usr/local/bin/custom-entrypoint
ENTRYPOINT ["custom-entrypoint"]
CMD ["apache2-foreground"]
