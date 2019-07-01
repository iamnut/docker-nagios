FROM ubuntu:18.04

ENV TZ=Asia/Bangkok

# apt cache enabled and update mirror to bangmod
RUN sh -c "ls /etc/apt/apt.conf.d/*proxy* &> /dev/null || echo 'Acquire::http::Proxy 'http://proxy.stdin.bid:3128';' > /etc/apt/apt.conf.d/02proxy" \
    && sed -i 's/archive.ubuntu.com/mirrors.bangmod.cloud/g'  /etc/apt/sources.list

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install tzdata

RUN apt-get install -y \
       build-essential autoconf gcc libc6 make libgd-dev libmcrypt-dev libssl-dev \
       wget unzip bc gawk dc snmp libnet-snmp-perl gettext \
       apache2 php libapache2-mod-php7.2

RUN cd /tmp \
    && wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.3.tar.gz \
    && wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz \
    && tar xzf nagioscore.tar.gz \
    && tar zxf nagios-plugins.tar.gz

RUN cd /tmp/nagioscore-nagios-4.4.3 \
    && ./configure --with-httpd-conf=/etc/apache2/sites-enabled \
    && make all \
    && make install-groups-users \
    && usermod -a -G nagios www-data \
    && make install \
    && make install-daemoninit \
    && make install-commandmode \
    && make install-config \
    && make install-webconf \
    && a2enmod rewrite \
    && a2enmod cgi

RUN cd /tmp/nagios-plugins-release-2.2.1 \
    && ./tools/setup \
    && ./configure \
    && make \
    && make install

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/**

# ENTRYPOINT ["/docker-entrypoint.sh"]
