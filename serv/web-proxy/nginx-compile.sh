 # Licensed to the Apache Software Foundation (ASF) under one or more
 # contributor license agreements.  See the NOTICE file distributed with
 # this work for additional information regarding copyright ownership.
 # The ASF licenses this file to You under the Apache License, Version 2.0
 # (the "License"); you may not use this file except in compliance with
 # the License.  You may obtain a copy of the License at
 #
 #      http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.

#!/bin/bash

#!/bin/bash
# Date: 29 June 2019
# Version: 0.1.0
# Written by: Raúl González <rafex.dev@gmail.com>

# . ../../utils/color.sh
# . ../../utils/is-root.sh

INITIAL_TEXT="Load module nginx compile"
NAME_OF_THE_MODULE="Nginx compile"
NGINX_INSTALLATION_PATH="/opt/nginx"
NGINX_USER="nginx"
NGINX_GROUP="nginx"
TMP_PATH="/tmp"

ZLIB_VERSION="zlib-1.2.11"
ZLIB_SRC="${ZLIB_VERSION}.tar.gz"
LIBRESSL_VERSION="libressl-2.9.2"
LIBRESSL_SRC="${LIBRESSL_VERSION}.tar.gz"
PCRE_VERSION="pcre-8.43"
PCRE_SRC="${PCRE_VERSION}.tar.gz"
NGINX_VERSION="1.17.1"
NGINX_SRC="nginx-${NGINX_VERSION}.tar.gz"

function nginx_hello () {
  blue_text $INITIAL_TEXT
}

function download_libs () {
  curl https://www.zlib.net/$ZLIB_SRC --output ${TMP_PATH}/${ZLIB_SRC}
  curl ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$PCRE_SRC --output ${TMP_PATH}/${PCRE_SRC}
  curl https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/$LIBRESSL_SRC --output ${TMP_PATH}/${LIBRESSL_SRC}
}

function download_nginx () {
  curl https://nginx.org/download/$NGINX_SRC --output ${TMP_PATH}/${NGINX_SRC}
}

function unpackage_libs () {
  tar -xvf ${TMP_PATH}/${ZLIB_SRC} -C ${TMP_PATH}
  tar -xvf ${TMP_PATH}/${PCRE_SRC} -C ${TMP_PATH}
  tar -xvf ${TMP_PATH}/${LIBRESSL_SRC} -C ${TMP_PATH}
}

function unpackage_nginx () {
  tar -xvf ${TMP_PATH}/${NGINX_SRC} -C ${TMP_PATH}
}

function install_dependencies_for_debian () {
  red_text "Install dependencies for Debian"
  sudo apt install libxml2-dev libxslt1-dev libgd-dev libgeoip-dev libgoogle-perftools-dev libatomic-ops-dev
}

function install_dependencies_for_centos () {
  blue_text "Install dependencies for CentOS"
  sudo yum install libxml2-dev libxslt1-dev libgd-dev
}

function install_dependencies () {
  local distro=$(what_distribution_are_you)
  case $distro in
    Debian) install_dependencies_for_debian ;;
    CentOS) install_dependencies_for_centos ;;
    *) red_text "We have not detected your distribution, we're sorry!!! U.U";;
  esac
}

function nginx_conf_default () {
  sudo cat > /etc/systemd/system/nginx.service << EOF
  user  nginx;
  worker_processes  4;

  error_log  /var/log/nginx/error.log warn;
  pid        /var/run/nginx.pid;


  events {
      worker_connections  1024;
      use epoll;
      multi_accept on;
  }

  http {
      include	  /etc/nginx/mime.types;
      default_type  application/octet-stream;

      log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

      access_log  /var/log/nginx/access.log  main;
      sendfile        on;
      #tcp_nopush     on;
      keepalive_timeout  65;
      gzip on;
      gzip_disable "msie6";
      gzip_vary on;
      gzip_proxied any;
      gzip_comp_level 9;
      gzip_buffers 16 8k;
      gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
      include   /etc/nginx/conf.d/*.conf;
  }
EOF
}

function final_adjustments () {
  sudo ln -s /usr/lib64/nginx/modules /etc/nginx/modules
  sudo mkdir -p /usr/share/nginx
  sudo mv -v /etc/nginx/html /usr/share/nginx/html
  sudo chown -R $NGINX_USER:$NGINX_GROUP /usr/share/nginx
  sudo rm -rfv /etc/nginx/*.default
  sudo mkdir -p /etc/nginx/conf.d
}

function  create_user () {
  sudo useradd --system $NGINX_USER
  sudo usermod -s /sbin/nologin $NGINX_USER
}

function create_folders () {
  sudo mkdir -p /var/cache/nginx/
  sudo mkdir -p /var/log/nginx/
  sudo chown -R $NGINX_USER:$NGINX_GROUP /var/cache/nginx
  sudo chown -R $NGINX_USER:$NGINX_GROUP /var/log/nginx
}

function create_service () {
  sudo cat > /etc/systemd/system/nginx.service << EOF
[Unit]
Description=Nginx ${NGINX_VERSION}
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target
EOF
  sudo chmod 755 /etc/systemd/system/nginx.service
  sudo systemctl daemon-reload
  sudo systemctl enable nginx.service
}

function configure_nginx () {
  cd ${TMP_PATH}/nginx-${NGINX_VERSION}
  ./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib64/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=$NGINX_USER \
            --group=$NGINX_GROUP \
            --build=Debian \
            --builddir=nginx-${NGINX_VERSION} \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-google_perftools_module \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_stub_status_module \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-mail=dynamic \
            --with-mail_ssl_module \
            --with-stream=dynamic \
            --with-stream_ssl_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-stream_ssl_preread_module \
            --with-compat \
            --with-pcre=${TMP_PATH}/${PCRE_VERSION} \
            --with-pcre-jit \
            --with-openssl=${TMP_PATH}/${LIBRESSL_VERSION} \
            --with-openssl-opt=no-nextprotoneg \
            --with-zlib=${TMP_PATH}/${ZLIB_VERSION} \
            --with-zlib-asm=CPU \
            --with-libatomic \
            --with-debug
  cd $NEWBIE_INSTALLER_PATH
}

function make_nginx () {
  cd ${TMP_PATH}/nginx-${NGINX_VERSION}
  make
  cd $NEWBIE_INSTALLER_PATH
}

function make_install_nginx () {
  cd ${TMP_PATH}/nginx-${NGINX_VERSION}
  sudo make install
  cd $NEWBIE_INSTALLER_PATH

  create_user
  create_folders
  final_adjustments

}

function execute_nginx_compile () {
  download_libs
  sleep 1
  download_nginx
  sleep 1
  unpackage_libs
  sleep 1
  unpackage_nginx
  sleep 1
  has_sudo
  install_dependencies
  sleep 1
  configure_nginx
  sleep 2
  make_nginx
  sleep 2
  make_install_nginx
  sleep 2
  create_service
}

function nginx_compile_menu () {
  trap '' 2  # ignore control + c
  while true
  do
    local answer
    local input
    clear # clear screen for each loop of menu
    green_text "================================"
    green_text "================================"
    echo "-------------      -------------"
    blue_text "----------- Distro   -----------"
    what_distribution_are_you
    echo "-----------          -----------"
    red_text "${NAME_OF_THE_MODULE}"
    echo "-----------          -----------"
    green_text "================================"
    green_text "================================"
    echo "Enter 1) Download libs"
    echo "Enter 2) Download Nginx"
    echo "Enter 3) Unpackage libs"
    echo "Enter 4) Unpackage Nginx"
    echo "Enter 5) Install dependencies"
    echo "Enter 6) Configure"
    echo "Enter 7) Make"
    echo "Enter 8) Make install"
    echo "Enter 9) Create service"
    echo "Enter a) All"
    red_text "Enter q) Quit"
    yellow_text "Enter your selection here and hit <return>"
    read answer
    case "$answer" in
     1) download_libs ;;
     2) download_nginx ;;
     3) unpackage_libs ;;
     4) unpackage_nginx ;;
     5) install_dependencies ;;
     6) configure_nginx ;;
     7) make_nginx;;
     8) make_install_nginx;;
     9) create_service ;;
     a) execute_nginx_compile ;;
     q) exit ;;
    esac
    red_text "Hit the <return> key to continue"
    read input
  done
}

nginx_hello
