FROM debian:11-slim

ENV COMPOSER_HOME=/home/composer
ENV PACKAGIST_TOKEN=d415b8ea82b6c15e3215033e9e0269f384efe7e77f18cfa1d58efe86434e
ENV DG_DRUPAL_VERSION=8.x-manage
ENV PDFJS_VERSION=2.0.943
ENV OPENSEADRAGON_VERSION=2.4.0
ENV ICONPICKER_VERSION=3.2.0
ENV MASONRY_THEME_VERSION=3.3.2
ENV JQUERY_SELECTBOXIT_GIT_REF=648c62a2821713386ae111712f1f3e10c9965d4c
ENV PROVISIONED_CONTENT_VERSION=2021-05-10
ENV I8_SPECIFIC_VERSION=2021-05-18
ENV D8_CONFIGS_VERSION=i8manage
ENV CRAYFISH_GIT_REF=937e394ebfd585aa53a561a839438a739f2ab715

EXPOSE 80 443 8080 8888 9000

RUN apt-get -qqy update \
  && apt-get -qqy --no-install-recommends install \
     ca-certificates curl git openssh-client openssl sudo unzip wget \
     postgresql-client-13 postgresql-client-common \
     ffmpeg imagemagick poppler-utils tesseract-ocr \
     apache2 apache2-utils php php-common php-dev libapache2-mod-php \
     php-ctype php-curl php-fileinfo php-gd php-iconv php-json \
     php-mbstring php-pgsql php-phar php-pdo \
     php-simplexml php-tokenizer php-xml php-zip \
     php-memcached libmemcached-tools \
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
#RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf \
RUN echo 'ErrorLog /dev/stderr' >> /etc/apache2/apache2.conf \
  && echo 'TransferLog /dev/stdout' >> /etc/apache2/apache2.conf \
  && echo 'CustomLog /dev/stdout combined' >> /etc/apache2/apache2.conf \
  && chown -R www-data /var/log/apache2

# disable and enable sites
#RUN a2dissite default-ssl.conf \
#  && a2dissite 000-default.conf \
COPY sites-available/*.conf /etc/apache2/sites-available/
COPY conf-available/*.conf /etc/apache2/conf-available/
RUN a2ensite 25-80-dgi.conf

# enable apache2 modules and sites
RUN a2enmod rewrite \
  && a2enmod ssl \
  && a2enmod proxy_http \
  && a2enmod headers 


RUN useradd composer -g www-data -m \
  && mkdir -p /home/composer/.ssh \
  && chmod 700 /home/composer/.ssh

COPY id_rsa /home/composer/.ssh/

RUN chmod 600 /home/composer/.ssh/id_rsa \
  && chmod 700 /home/composer/.ssh \
  && chown -R composer:www-data /home/composer \
  && chown -R composer:root /home/composer/.ssh


#--------------------------------------------------------------
# composer install Drupal project

USER root

COPY drupal_${DG_DRUPAL_VERSION}.tgz /tmp/

RUN mkdir -p /opt/www/drupal \
             /opt/www/drupal/sites/default/files \
  && tar -zxvf /tmp/drupal_${DG_DRUPAL_VERSION}.tgz -C /opt/www/drupal \
  && chown -R composer:www-data /opt/www/drupal \
  && chown www-data:www-data /opt/www/drupal/sites/default/files \
  && rm -f /tmp/drupal_${DG_DRUPAL_VERSION}.tgz

# install Drupal project and drupal scaffold
# https://github.com/drupal/core-composer-scaffold
USER composer

RUN composer config -g http-basic.repo.packagist.com puppet-insecure-dgi ${PACKAGIST_TOKEN} \
  && composer config -g preferred-install.'*' 'dist'

RUN cd /opt/www/drupal \
  && composer install --no-interaction \
  && composer drupal:scaffold


#--------------------------------------------------------------
# Libraries

USER root

RUN chown -R www-data:www-data /opt/www/drupal/themes/contrib/dgi_i8_base

# pdfjs
RUN mkdir -p /opt/www/drupal/libraries \
             /opt/www/drupal/sites/all/libraries \
  && wget https://github.com/mozilla/pdf.js/releases/download/v${PDFJS_VERSION}/pdfjs-${PDFJS_VERSION}-dist.zip \
  && unzip pdfjs-${PDFJS_VERSION}-dist.zip -d /opt/www/drupal/sites/all/libraries/pdfjs \
  && ln -s /opt/www/drupal/sites/all/libraries/pdfjs /opt/www/drupal/libraries/pdf.js \
  && rm pdfjs-${PDFJS_VERSION}-dist.zip

# openseadragon
RUN mkdir -p /opt/www/drupal/sites/all/assets/vendor \
             /opt/www/drupal/sites/default/files/library-definitions \
  && wget https://github.com/openseadragon/openseadragon/releases/download/v2.4.0/openseadragon-bin-${OPENSEADRAGON_VERSION}.tar.gz \
  && tar -zxvf openseadragon-bin-${OPENSEADRAGON_VERSION}.tar.gz -C /opt/www/drupal/sites/all/libraries \
  && ln -s /opt/www/drupal/sites/all/libraries/openseadragon-bin-${OPENSEADRAGON_VERSION} /opt/www/drupal/libraries/openseadragon \
  && ln -s /opt/www/drupal/sites/all/libraries/openseadragon-bin-${OPENSEADRAGON_VERSION} /opt/www/drupal/sites/all/assets/vendor/openseadragon \
  && cp /opt/www/drupal/modules/contrib/openseadragon/openseadragon.json /opt/www/drupal/sites/default/files/library-definitions/openseadragon.json \
  && rm openseadragon-bin-${OPENSEADRAGON_VERSION}.tar.gz

# fontawesome
COPY fontawesome.tar.gz /tmp/

RUN tar -zxvf /tmp/fontawesome.tar.gz -C /opt/www/drupal/sites/all/libraries \
  && ln -s /opt/www/drupal/sites/all/libraries/fontawesome /opt/www/drupal/libraries/fontawesome \
  && rm /tmp/fontawesome.tar.gz

COPY fontawesome-iconpicker_${ICONPICKER_VERSION}.tgz /tmp/

RUN tar -zxvf /tmp/fontawesome-iconpicker_${ICONPICKER_VERSION}.tgz -C /opt/www/drupal/sites/all/libraries \
  && ln -s /opt/www/drupal/sites/all/libraries/fontawesome-iconpicker /opt/www/drupal/libraries/fontawesome-iconpicker \
  && rm /tmp/fontawesome-iconpicker_${ICONPICKER_VERSION}.tgz

# masonry theme
RUN wget https://github.com/desandro/masonry/archive/v${MASONRY_THEME_VERSION}.tar.gz \
 && tar -zxvf v${MASONRY_THEME_VERSION}.tar.gz -C /opt/www/drupal/sites/all/libraries \
 && ln -s /opt/www/drupal/sites/all/libraries/masonry-${MASONRY_THEME_VERSION} /opt/www/drupal/libraries/masonry \
 && rm v${MASONRY_THEME_VERSION}.tar.gz

# jquery.selectBoxIt
RUN cd /opt/www/drupal/sites/all/libraries/ \
  && git clone https://github.com/gfranko/jquery.selectBoxIt.js.git \
  && cd jquery.selectBoxIt.js \
  && git checkout ${JQUERY_SELECTBOXIT_GIT_REF} \
  && ln -s /opt/www/drupal/sites/all/libraries/jquery.selectBoxIt.js /opt/www/drupal/libraries/jquery.selectBoxIt.js

RUN chown -R root:www-data /opt/www/drupal/sites/all/libraries


#--------------------------------------------------------------
# setup required directories

RUN mkdir -p /opt/islandora_data/repo-meta \
  && chown -R www-data:www-data /opt/islandora_data \
  && mkdir -p /opt/drupal_private_filesystems/d8/default \
  && chown -R www-data:www-data /opt/drupal_private_filesystems \
  && chmod -R 770 /opt/drupal_private_filesystems

COPY i8-specific-2021-05-18.tar.gz /tmp/i8-specific-2021-05-18.tar.gz
COPY provisioned_content-2021-05-10.tar.gz /tmp/provisioned_content-2021-05-10.tar.gz
RUN mkdir -p /opt/www/drupal/sites/default \
  && tar -zxvf /tmp/i8-specific-2021-05-18.tar.gz -C /opt/www/drupal/sites/default/ \
  && tar -zxvf /tmp/provisioned_content-2021-05-10.tar.gz -C /opt/www/drupal/sites/default/ \
  && chmod -R 644 /opt/www/drupal/sites/default/provisioned_content* \
  && chmod -R 644 /opt/www/drupal/sites/default/i8-specific* \
  && chown -R www-data:www-data /opt/www/drupal \
  && rm /tmp/i8-specific-2021-05-18.tar.gz /tmp/provisioned_content-2021-05-10.tar.gz

COPY drupal_sites_default/*.php /opt/www/drupal/sites/default/
COPY drupal_sites_default/*.json /opt/www/drupal/sites/default/

# config overrides
RUN mkdir -p /opt/www/drupal/sites/default/config_override
COPY config_override/*.yml /opt/www/drupal/sites/default/config_override/
RUN chown -R root:www-data /opt/www/drupal/sites/default/config_override \
  && chmod -R 550 /opt/www/drupal/sites/default/config_override


#--------------------------------------------------------------
# setup crayfish

# JWT for crayfish
RUN mkdir -p /opt/drupal_keys/default/keys/ \
  && openssl genrsa -out /opt/drupal_keys/default/keys/default.key 2048 \
  && openssl rsa -pubout -in /opt/drupal_keys/default/keys/default.key -out /opt/drupal_keys/default/keys/default.pub \
  && chown -R www-data:www-data /opt/drupal_keys/


RUN mkdir -p /opt/www \
  && cd /opt/www/ \
  && git clone https://github.com/Islandora/Crayfish.git crayfish \
  && cd crayfish \
  && git checkout ${CRAYFISH_GIT_REF} \
  && mkdir -p /var/log/crayfish \
  && chown -R www-data /var/log/crayfish

COPY crayfish/Homarus_cfg_config.yaml /opt/www/crayfish/Homarus/cfg/config.yaml
COPY crayfish/Houdini_config_packages_crayfish_commons.yaml /opt/www/crayfish/Houdini/config/packages/crayfish_commons.yaml
COPY crayfish/Houdini_cfg_config.yaml /opt/www/crayfish/Houdini/cfg/config.yaml
COPY crayfish/Houdini_config_services_dev.yaml /opt/www/crayfish/Houdini/config/services_dev.yaml
COPY crayfish/Hypercube_cfg_config.yaml /opt/www/crayfish/Hypercube/cfg/config.yaml
COPY crayfish/syn-settings.xml /opt/www/crayfish/syn-settings.xml

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
  && a2enconf 25-crayfish-houdini


#--------------------------------------------------------------
# d8 config
#

USER root 

COPY i8-proto-config_i8manage.tar /tmp/i8-proto-config_i8manage.tar
RUN mkdir -p /opt/www/drupal/sites/default/ /opt/www/d8_configs/ \
  && tar -xvf /tmp/i8-proto-config_i8manage.tar -C /opt/www/d8_configs/ \
  && mv /opt/www/d8_configs/i8-proto-config /opt/www/d8_configs/default \
  && chown -R www-data:www-data /opt/www/drupal /opt/www/d8_configs \
  && rm /tmp/i8-proto-config_i8manage.tar


#--------------------------------------------------------------
# drush

RUN ln -s /opt/www/drupal/vendor/bin/drush /usr/bin/drush


#--------------------------------------------------------------
# cleanup

RUN rm /etc/apache2/sites-enabled/000-default.conf


#--------------------------------------------------------------

USER root 

WORKDIR /opt/www/drupal

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND", "-f", "/etc/apache2/apache2.conf"]
