# base from centos 6.9 (https://hub.docker.com/r/italoc/php53)
FROM italoc/php53 

RUN groupadd -g 999 appuser && \
    useradd -r -u 999 -g appuser appuser
USER appuser

# delete apache dari imagenya
RUN yum -y remove httpd

# update & install dependencies
RUN yum -y update && yum -y install \
    perl \
    xorg-x11-xauth.x86_64 \
    xorg-x11-apps.x86_64 \
    libXp libXtst binutils compat-db compat-libstdc++-33 glibc glibc-devel glibc-headers gcc gcc-c++ libstdc++ cpp make libaio ksh elfutils-libelf sysstat libaio libaio-devel setarch  libXp.i686 libXtst-1.0.99.2-3.el6.i686 glibc-devel.i686 libgcc-4.4.4-13.el6.i686 compat-libstdc++* compat-libf2c* compat-gcc* compat-libgcc* libXt.i686 libXtst.i686 \
    git \
    php-fpm

# bikin user & group2 oracle    
RUN groupadd -g 54321 oinstall \
    && groupadd -g 54322 dba \
    && groupadd -g 54323 oper \
    && groupadd -g 54327 asmdba \
    && groupadd -g 54328 asmoper \
    && groupadd -g 54329 asmadmin \
    && groupadd -g 54330 oracle \
    && useradd -u 54321 -g oinstall -G dba,oper,asmadmin oracle

# download & install instantclient
RUN mkdir /home/instantclient11_2 \
    && cd /home/instantclient11_2 \
    && git clone -b instantclient11.2-rpm https://github.com/millenito/oracle-instantclient.git \
    && cd oracle-instantclient \
    && rpm -ivh oracle-instantclient11.2-*.rpm \
    && cd / \
    && rm -rf /home/instantclient11_2

# setup environment & instantclient
RUN ln -s /usr/include/oracle/11.2/client64 /usr/include/oracle/11 \
    && ln -s /usr/include/oracle/11.2/client64 /usr/include/oracle/11.2/client \
    && ln -s /usr/lib/oracle/11.2/client64 /usr/lib/oracle/11.2/client \
    && echo $'export ORACLE_HOME=/usr/lib/oracle/11.2/client64\n\
    export PATH=$PATH:$ORACLE_HOME/bin\n\
    export LD_LIBRARY_PATH=$ORACLE_HOME/lib\n\
    export TNS_ADMIN=$ORACLE_HOME/network/admin' > /etc/profile.d/client.sh \
    && chmod +x /etc/profile.d/client.sh \
    && echo $'export ORACLE_HOME=/usr/lib/oracle/11.2/client64\n\
    export PATH=$PATH:$ORACLE_HOME/bin\n\
    export LD_LIBRARY_PATH=$ORACLE_HOME/lib\n\
    export TNS_ADMIN=$ORACLE_HOME/network/admin' >> /etc/profile

# install oci8 & dependencies nya
RUN yum -y install libtool-ltdl-devel \
    epel-release \
    yum-utils \
    && yum -y groupinstall "Development Tools" \
    && yum -y install php-pear php-devel zlib zlib-devel bc libaio glibc libxml2-devel \
    && echo "instantclient,/usr/lib/oracle/11.2/client64/lib" | pecl install oci8-2.0.12 \
    && echo "extension=oci8.so" > /etc/php.d/oci8.ini

# install nginx
RUN groupadd nginx \
    && useradd -g nginx nginx \
    && usermod -a -G oracle nginx \
    && usermod -a -G oinstall nginx \
    && usermod -a -G dba nginx \
    && usermod -a -G apache nginx

COPY docker-webserver/nginx/yum.repos.d/nginx.repo /etc/yum.repos.d/

RUN yum install -y nginx \
    && rm -f /etc/nginx/conf.d/default.conf \
    && rm -f /usr/share/nginx/html/*

WORKDIR /usr/share/nginx/html

COPY index.php .

COPY docker-webserver/php/php.ini /etc/php.ini
COPY docker-webserver/php/www.conf /etc/php-fpm.d/www.conf

COPY docker-webserver/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker-webserver/nginx/conf.d/. /etc/nginx/conf.d/.


# port2 untuk nginx, ssl & php-fpm  
EXPOSE 80
EXPOSE 443
EXPOSE 9053

CMD service php-fpm start && nginx -g 'daemon off;'

