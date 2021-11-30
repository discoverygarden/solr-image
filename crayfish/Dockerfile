FROM debian:11-slim

ENV COMPOSER_HOME=/home/composer
ENV PACKAGIST_TOKEN=d415b8ea82b6c15e3215033e9e0269f384efe7e77f18cfa1d58efe86434e
#ENV CRAYFISH_GIT_REF=937e394ebfd585aa53a561a839438a739f2ab715
ENV CRAYFISH_VERSION=1.1.1

EXPOSE 80 8888

RUN apt-get -qqy update \
  && apt-get -qqy --no-install-recommends install \
     ca-certificates curl git openssh-client openssl unzip wget \
     ffmpeg imagemagick poppler-utils tesseract-ocr \
     apache2 apache2-utils php php-common php-dev libapache2-mod-php \
     php-dom php-mbstring php-simplexml \
  && apt-get clean

# composer install
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 

COPY imagemagick_policy.xml /etc/ImageMagick-6/policy.xml


#--------------------------------------------------------------
# setup PHP
RUN mkdir -p /etc/php/7.4/dgi
COPY dgi_99-config.ini /etc/php/7.4/dgi/99-config.ini
RUN ln -s /etc/php/7.4/dgi/99-config.ini /etc/php/7.4/apache2/conf.d/99-config.ini \
  && ln -s /etc/php/7.4/dgi/99-config.ini /etc/php/7.4/cli/conf.d/99-config.ini

# setup apache2
RUN echo 'ErrorLog /dev/stderr' >> /etc/apache2/apache2.conf \
  && echo 'TransferLog /dev/stdout' >> /etc/apache2/apache2.conf \
  && echo 'CustomLog /dev/stdout combined' >> /etc/apache2/apache2.conf \
  && chown -R www-data /var/log/apache2

# disable and enable sites
#RUN a2dissite default-ssl.conf \
#  && a2dissite 000-default.conf \
COPY conf-available/*.conf /etc/apache2/conf-available/

# enable apache2 modules and sites
RUN a2enmod rewrite \
  && a2enmod ssl \
  && a2enmod proxy_http \
  && a2enmod headers 

# setup Forensic logging (for debugging)
#RUN a2enmmod log_forensic \
#  && echo echo 'ForensicLog /dev/stdout' >> /etc/apache2/apache2.conf


RUN useradd composer -g www-data -m \
  && mkdir -p /home/composer/.ssh \
  && chmod 700 /home/composer/.ssh

COPY id_rsa /home/composer/.ssh/

RUN chmod 600 /home/composer/.ssh/id_rsa \
  && chmod 700 /home/composer/.ssh \
  && chown -R composer:www-data /home/composer \
  && chown -R composer:root /home/composer/.ssh


#--------------------------------------------------------------
# setup crayfish

# JWT for crayfish (but realistically, you would mount your actual keys over these)
RUN mkdir -p /opt/drupal_keys/default/keys/ \
  && openssl genrsa -out /opt/drupal_keys/default/keys/default.key 2048 \
  && openssl rsa -pubout -in /opt/drupal_keys/default/keys/default.key -out /opt/drupal_keys/default/keys/default.pub \
  && chown -R www-data:www-data /opt/drupal_keys/


# /var/log/crayfish directory required for Homarus and Hypercube to work
RUN mkdir -p /opt/www /var/log/crayfish \
  && chown -R www-data /var/log/crayfish \
  && cd /opt/www/ \
  && git clone https://github.com/Islandora/Crayfish.git crayfish \
  && cd crayfish \
  && git checkout ${CRAYFISH_VERSION}

COPY configs/Homarus_cfg_config.yaml /opt/www/crayfish/Homarus/cfg/config.yaml
COPY configs/Houdini_config_packages_crayfish_commons.yaml /opt/www/crayfish/Houdini/config/packages/crayfish_commons.yaml
COPY configs/Houdini_cfg_config.yaml /opt/www/crayfish/Houdini/cfg/config.yaml
COPY configs/Houdini_config_services_dev.yaml /opt/www/crayfish/Houdini/config/services_dev.yaml
COPY configs/Hypercube_cfg_config.yaml /opt/www/crayfish/Hypercube/cfg/config.yaml
COPY configs/syn-settings.xml /opt/www/crayfish/syn-settings.xml

RUN ln -s /opt/www/crayfish/Houdini/config/services_dev.yaml /opt/www/crayfish/Houdini/config/services_prod.yaml \
  && chown -R composer:www-data /opt/www/crayfish


USER composer

RUN cd /opt/www/crayfish/Homarus \
  && composer install --no-interaction \
  && cd /opt/www/crayfish/Houdini \
  && composer install --no-interaction \
  && cd /opt/www/crayfish/Hypercube \
  && composer install --no-interaction

USER root

RUN chown -R www-data:www-data /opt/www/crayfish \
  && a2enconf 25-crayfish-hypercube \
  && a2enconf 25-crayfish-homarus \
  && a2enconf 25-crayfish-houdini \
  && a2dissite default-ssl.conf \
  && a2dissite 000-default.conf


#--------------------------------------------------------------
# drush

RUN ln -s /opt/www/drupal/vendor/bin/drush /usr/bin/drush


#--------------------------------------------------------------

USER root 

WORKDIR /opt/www/crayfish

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND", "-f", "/etc/apache2/apache2.conf"]
