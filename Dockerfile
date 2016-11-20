FROM php:5.6.28-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip mysqli mysql

WORKDIR /var/www/html

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.52
ENV DRUPAL_MD5 4963e68ca12918d3a3eae56054214191
ENV CIVICRM_VERSION 4.6.23
ENV CIVICRM_MD5 58ae0594b94ccbbfb96cbc0cbf9de2b1

RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
  && echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f drupal.tar.gz \
  && rm drupal.tar.gz \
  && chown -R www-data:www-data sites \
  && mkdir /sites-default-source \
  && cp -r sites/default/* /sites-default-source/ \
  && cd /var/www/html/sites/all/modules \
  && curl -fSL "https://download.civicrm.org/civicrm-${CIVICRM_VERSION}-drupal.tar.gz" -o civicrm.tar.gz \
  && echo "${CIVICRM_MD5} *civicrm.tar.gz" | md5sum -c - \
  && tar -xzf civicrm.tar.gz \
  && rm civicrm.tar.gz \
  && chown -R www-data:www-data civicrm

COPY start.sh /usr/local/bin

CMD ["start.sh"]
