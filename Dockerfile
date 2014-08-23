FROM moul/tmux
MAINTAINER Manfred Touron <m@42.am>

RUN echo deb http://archive.ubuntu.com/ubuntu precise main universe > /etc/apt/sources.list && \
    apt-get -qqy update

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qqy install \
    git mysql-client apache2 php5-memcache \
    libapache2-mod-php5 pwgen python-setuptools \
    vim-tiny php5-mysql php-apc php5-gd \
    php5-memcache memcached drush mc \
    mysql-server curl apache2-utils php-apc && \
    apt-get clean

RUN a2enmod rewrite vhost_alias
RUN easy_install supervisor

RUN rm -rf /var/www/ && \
    cd /var && \
    drush dl drupal && \
    mv /var/drupal*/ /var/www/ && \
    \
     cd /var/www && \
    tar czf sites.tgz sites && \
    rm -rf sites && \
    \
    mkdir -p /data/ && \
    ln -sf /data/sites /var/www/sites && \
    mkdir -p /root/.ssh && \
    ln -sf /data/authorized_keys /root/.ssh/ && \
    ln -s /var/www/ /drupal && \
    ln -s /var/www/sites/ /sites && \
    mkdir -p /root/drush-backups

RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-available/default

EXPOSE 80
EXPOSE 22
VOLUMES ["/data"]
CMD ["/bin/bash", "/start.sh"]

ADD ./drushrc.php /root/.drushrc.php
ADD ./start.sh /
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf
