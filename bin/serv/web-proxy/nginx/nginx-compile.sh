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
# Date: 29 June 2019
# Version: 0.1.0
# Written by: Raúl González <rafex.dev@gmail.com>

# . ../../utils/color.sh
# . ../../utils/is-root.sh

NAME_OF_THE_MODULE="Nginx compile"
INITIAL_TEXT="Load module ${NAME_OF_THE_MODULE}"
#INSTALLATION_PATH_NGINX="/opt/nginx"
NGINX_USER="nginx"
NGINX_GROUP="nginx"
TMP_PATH_NGINX="/opt/nginx-newbie-installer"

ZLIB_VERSION="zlib-1.2.11"
ZLIB_SRC="${ZLIB_VERSION}.tar.gz"
LIBRESSL_VERSION="libressl-3.0.0"
LIBRESSL_SRC="${LIBRESSL_VERSION}.tar.gz"
PCRE_VERSION="pcre-8.43"
PCRE_SRC="${PCRE_VERSION}.tar.gz"
NGINX_VERSION="1.17.4"
NGINX_SRC="nginx-${NGINX_VERSION}.tar.gz"

MODSECURITY_BRANCH="v3/master"

URL_ZLIB="https://www.zlib.net/"
URL_PCRE="https://ftp.pcre.org/pub/pcre/"
URL_LIBRESSL="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/"

URL_GIT_MODSECURITY="https://github.com/SpiderLabs/ModSecurity.git"
URL_GIT_MODSECURITY_NGINX="https://github.com/SpiderLabs/ModSecurity-nginx"
URL_OWASP_MODSECURITY_CRS="https://github.com/SpiderLabs/owasp-modsecurity-crs.git"

FOLDER_MODSECURITY="ModSecurity"
FOLDER_MODSECURITY_NGINX="ModSecurity-nginx"
FOLDER_OWASP_MODSECURITY_CRS="owasp-modsecurity-crs"

function path_nginx () {
  has_sudo
  sudo mkdir -vp $TMP_PATH_NGINX
  sudo chown $USER:$USER $TMP_PATH_NGINX
}

function download_libs () {
  curl $URL_ZLIB$ZLIB_SRC --output ${TMP_PATH_NGINX}/${ZLIB_SRC}
  curl $URL_PCRE$PCRE_SRC --output ${TMP_PATH_NGINX}/${PCRE_SRC}
  curl $URL_LIBRESSL$LIBRESSL_SRC --output ${TMP_PATH_NGINX}/${LIBRESSL_SRC}
  cd ${TMP_PATH_NGINX}
  git clone -b ${MODSECURITY_BRANCH} ${URL_GIT_MODSECURITY}
  git clone ${URL_GIT_MODSECURITY_NGINX}
  git clone ${URL_OWASP_MODSECURITY_CRS}
  cd $NEWBIE_INSTALLER_PATH

}

function download_nginx () {
  mkdir -vp $TMP_PATH_NGINX
  curl https://nginx.org/download/$NGINX_SRC --output ${TMP_PATH_NGINX}/${NGINX_SRC}
}

function unpackage_libs_nginx () {
  tar -xvf ${TMP_PATH_NGINX}/${ZLIB_SRC} -C ${TMP_PATH_NGINX}
  tar -xvf ${TMP_PATH_NGINX}/${PCRE_SRC} -C ${TMP_PATH_NGINX}
  tar -xvf ${TMP_PATH_NGINX}/${LIBRESSL_SRC} -C ${TMP_PATH_NGINX}

  install_pcre
  install_libressl
  install_zlib
}

function unpackage_nginx () {
  tar -xvf ${TMP_PATH_NGINX}/${NGINX_SRC} -C ${TMP_PATH_NGINX}
}

function install_dependencies_nginx_for_debian () {
  has_sudo
  red_text "Install dependencies for Debian"
  sudo apt -y install build-essential
  sudo apt -y install curl libxml2-dev libxslt1-dev libgd-dev libgeoip-dev libgoogle-perftools-dev libatomic-ops-dev git
}

function install_dependencies_nginx_for_centos () {
  has_sudo
  blue_text "Install dependencies for CentOS"
  sudo yum -y groupinstall "Development Tools"
  sudo yum -y install curl gd-devel GeoIP-devel gperftools-devel libxslt-devel libxml2-devel libatomic_ops-devel curl-devel git gcc-c++ flex bison yajl yajl-devel doxygen
}

function install_dependencies_nginx_for_fedora () {
  has_sudo
  blue_text "Install dependencies for Fedora"
  sudo dnf -y groupinstall "C Development Tools and Libraries"
  sudo dnf -y install curl gd-devel GeoIP-devel gperftools-devel libxslt-devel libxml2-devel libatomic_ops-devel curl-devel git gcc-c++ flex bison yajl yajl-devel doxygen
}

function install_dependencies_nginx () {
  local distro=$(what_distribution_are_you)
  case $distro in
    debian) install_dependencies_nginx_for_debian ;;
    centos) install_dependencies_nginx_for_centos ;;
    fedora) install_dependencies_nginx_for_fedora;;
    *) red_text "We have not detected your distribution, we're sorry!!! U.U";;
  esac
}

function nginx_conf_default () {
  cat > ${TMP_PATH_NGINX}/client.conf.newbie << EOF
  client_body_buffer_size 1k;
  client_header_buffer_size 1k;
  client_max_body_size 1k;
  large_client_header_buffers 2 1k;

  client_body_timeout 10;
  client_header_timeout 10;
EOF

  cat > ${TMP_PATH_NGINX}/gzip.conf.newbie << EOF
  gzip on;
  gzip_disable "msie6";
  gzip_vary on;
  gzip_proxied any;
  gzip_comp_level 9;
  gzip_buffers 16 8k;
  gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
EOF

cat > ${TMP_PATH_NGINX}/security.conf.newbie << EOF
add_header X-Frame-Options "SAMEORIGIN" always;
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload" always;
add_header X-XSS-Protection "1; mode=block" always;

modsecurity on;
modsecurity_rules_file /etc/nginx/modsec/main.conf;
EOF

  cat > ${TMP_PATH_NGINX}/proxy.conf.newbie << EOF
  proxy_redirect          off;
  proxy_set_header        Host            \$host;
  proxy_set_header        X-Real-IP       \$remote_addr;
  proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_connect_timeout   90;
  proxy_send_timeout      90;
  proxy_read_timeout      90;
  proxy_buffers           32 4k;
EOF
  cat > ${TMP_PATH_NGINX}/timeout.conf.newbie << EOF
  send_timeout 60;
  keepalive_timeout 5 5;
EOF
  cat > ${TMP_PATH_NGINX}/nginx.conf.newbie << EOF
  user  ${NGINX_USER};
  worker_processes  4;

  error_log  /var/log/nginx/error.log warn;
  pid        /var/run/nginx.pid;

  load_module modules/ngx_http_modsecurity_module.so;

  events {
      worker_connections  1024;
      use epoll;
      multi_accept on;
  }

  http {
      include	  /etc/nginx/mime.types;
      include   /etc/nginx/conf.d/*.conf;
      default_type  application/octet-stream;

      server_tokens off;

      log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                        '\$status \$body_bytes_sent "\$http_referer" '
                        '"\$http_user_agent" "\$http_x_forwarded_for"';

      access_log  /var/log/nginx/access.log  main;
      sendfile        on;
      tcp_nopush     on;

      include   /etc/nginx/sites-enabled/*.conf;
  }
EOF
  cat > ${TMP_PATH_NGINX}/default-site.conf.newbie << EOF
  server {
      listen       80;
      listen       localhost:80;
      server_name  localhost;
      server_tokens off;
      
      charset UTF-8;
      access_log  /var/log/nginx/host.access.log  main;

      location / {
          root   /usr/share/nginx/html;
          index  index.html index.htm;
      }

      error_page  404              /404.html;

      # redirect server error pages to the static page /50x.html
      #
      error_page   500 502 503 504  /50x.html;
      location = /50x.html {
          root   /usr/share/nginx/html;
      }

      # deny access to .htaccess files, if Apache's document root
      # concurs with nginx's one
      #
      location ~ /\.ht {
          deny  all;
      }
  }
EOF
  has_sudo
  sudo cp -v ${TMP_PATH_NGINX}/client.conf.newbie /etc/nginx/conf.d/client.conf
  sudo cp -v ${TMP_PATH_NGINX}/gzip.conf.newbie /etc/nginx/conf.d/gzip.conf
  sudo cp -v ${TMP_PATH_NGINX}/security.conf.newbie /etc/nginx/conf.d/security.conf
  sudo cp -v ${TMP_PATH_NGINX}/proxy.conf.newbie /etc/nginx/conf.d/proxy.conf
  sudo cp -v ${TMP_PATH_NGINX}/timeout.conf.newbie /etc/nginx/conf.d/timeout.conf
  sudo cp -v ${TMP_PATH_NGINX}/nginx.conf.newbie /etc/nginx/nginx.conf
  sudo cp -v ${TMP_PATH_NGINX}/default-site.conf.newbie /etc/nginx/sites-available/default-site.conf
  cd /etc/nginx/sites-enabled
  sudo ln -s ../sites-available/default-site.conf .
  cd $NEWBIE_INSTALLER_PATH
}

function modified_html () {
  local distro=$(what_distribution_are_you)
  cat > ${TMP_PATH_NGINX}/index.html.newbie << EOF
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx! Installed with Newbie Installer</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx ${NGINX_VERSION}!</h1>
<h2>Installed with Newbie Installer in ${distro}</h2>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>
<p>For online documentation please refer to
<a href="https://github.com/rafex/newbie-installer">Newbie Installer</a>.<br/>

<p><em>Thank you for using nginx with install <a href="https://github.com/rafex/newbie-installer">Newbie Installer</a>.</em></p>
</body>
</html>
EOF
  cat > ${TMP_PATH_NGINX}/50x.html.newbie << EOF
  <!DOCTYPE html>
  <html>
  <head>
  <title>Error</title>
  <style>
      body {
          width: 35em;
          margin: 0 auto;
          font-family: Tahoma, Verdana, Arial, sans-serif;
      }
  </style>
  </head>
  <body>
  <h1>An error occurred.</h1>
  <p>Sorry, the page you are looking for is currently unavailable.<br/>
  Please try again later.</p>
  <p>If you are the system administrator of this resource then you should check
  the error log for details.</p>
  <p><em>Faithfully yours, nginx.</em></p>

  <p><em>Thank you for using nginx with <a href="https://github.com/rafex/newbie-installer">Newbie Installer</a>.</em></p>
  </body>
  </html>
EOF
  has_sudo
  sudo cp ${TMP_PATH_NGINX}/50x.html.newbie /usr/share/nginx/html/50x.html
  sudo cp ${TMP_PATH_NGINX}/index.html.newbie /usr/share/nginx/html/index.html
  sudo rm -rf /usr/share/nginx/html/html
}

function final_adjustments () {
  has_sudo
  sudo ln -s /usr/lib64/nginx/modules /etc/nginx/modules
  sudo mkdir -vp /usr/share/nginx
  sudo mv -v /etc/nginx/html /usr/share/nginx/html
  sudo chown -R $NGINX_USER:$NGINX_GROUP /usr/share/nginx
  sudo rm -rfv /etc/nginx/*.default
  sudo mkdir -vp /etc/nginx/conf.d
  sudo mkdir -vp /etc/nginx/sites-available
  sudo mkdir -vp /etc/nginx/sites-enabled
  sudo mkdir -vp /etc/nginx/modsec
  nginx_conf_default
  modified_html
}

function  create_user_nginx () {
  has_sudo
  sudo useradd --system $NGINX_USER -d /usr/share/nginx/html
  sudo usermod -s /sbin/nologin $NGINX_USER
}

function create_folders_nginx () {
  has_sudo
  sudo mkdir -vp /var/cache/nginx/
  sudo mkdir -vp /var/log/nginx/
  sudo chown -R $NGINX_USER:$NGINX_GROUP /var/cache/nginx
  sudo chown -R $NGINX_USER:$NGINX_GROUP /var/log/nginx
}

function create_service_nginx () {
  cat > ${TMP_PATH_NGINX}/nginx.service.newbie << EOF
[Unit]
Description=Nginx ${NGINX_VERSION}
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID

KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
  has_sudo
  sudo cp -v ${TMP_PATH_NGINX}/nginx.service.newbie /etc/systemd/system/nginx.service
  sudo chmod 755 /etc/systemd/system/nginx.service
  sudo systemctl daemon-reload
  sudo systemctl enable nginx.service
}

function install_zlib () {
  cd ${TMP_PATH_NGINX}/${ZLIB_VERSION}
  ./configure
  make
  has_sudo
  sudo make install
  cd $NEWBIE_INSTALLER_PATH
}

function install_libressl () {
  cd ${TMP_PATH_NGINX}/${LIBRESSL_VERSION}
  ./configure
  make
  has_sudo
  sudo make install
  cd $NEWBIE_INSTALLER_PATH
}

function install_pcre () {
  cd ${TMP_PATH_NGINX}/${PCRE_VERSION}
  ./configure
  make
  has_sudo
  sudo make install
  cd $NEWBIE_INSTALLER_PATH
}

function install_modsecurity () {

  cd ${TMP_PATH_NGINX}/${FOLDER_MODSECURITY}
  git submodule init
  git submodule update
  ./build.sh
  ./configure --with-pcre=${TMP_PATH_NGINX}/${PCRE_VERSION}/ \
    #--prefix=/opt/modsecurity \
    --with-libmodsecurity
  make
  has_sudo
  sudo make install

  cd $NEWBIE_INSTALLER_PATH
}

function module_modsecurity_nginx (){
  cd ${TMP_PATH_NGINX}/nginx-${NGINX_VERSION}
  ./configure --with-compat --add-dynamic-module=${TMP_PATH_NGINX}/${FOLDER_MODSECURITY_NGINX}/
  make modules
  sudo cp -vr objs/ngx_http_modsecurity_module.so /etc/nginx/modules/.

  cd $NEWBIE_INSTALLER_PATH
  configure_modsecurity
}

function configure_modsecurity () {
  cat > ${TMP_PATH_NGINX}/main.conf.newbie << EOF
Include /etc/nginx/modsec/modsecurity.conf
Include /etc/nginx/modsec/crs-setup.conf
Include /etc/nginx/modsec/rules/*.conf
EOF
  has_sudo
  sudo cp ${TMP_PATH_NGINX}/main.conf.newbie /etc/nginx/modsec/main.conf
  sudo cp -v ${TMP_PATH_NGINX}/${FOLDER_MODSECURITY}/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
  sudo cp -v ${TMP_PATH_NGINX}/${FOLDER_MODSECURITY}/unicode.mapping /etc/nginx/modsec/unicode.mapping
  sudo cp -v ${TMP_PATH_NGINX}/${FOLDER_OWASP_MODSECURITY_CRS}/crs-setup.conf.example /etc/nginx/modsec/crs-setup.conf
  sudo cp -vr ${TMP_PATH_NGINX}/${FOLDER_OWASP_MODSECURITY_CRS}/rules /etc/nginx/modsec/.

}


function configure_nginx () {
  cd ${TMP_PATH_NGINX}/nginx-${NGINX_VERSION}
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
            --without-http_autoindex_module \
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
            --with-pcre=${TMP_PATH_NGINX}/${PCRE_VERSION} \
            --with-pcre-jit \
            --with-openssl=${TMP_PATH_NGINX}/${LIBRESSL_VERSION} \
            --with-openssl-opt=no-nextprotoneg \
            --with-zlib=${TMP_PATH_NGINX}/${ZLIB_VERSION} \
            --with-zlib-asm=CPU \
            --with-libatomic \
            --with-debug
  cd $NEWBIE_INSTALLER_PATH
}

function make_nginx () {
  cd ${TMP_PATH_NGINX}/nginx-${NGINX_VERSION}
  make
  cd $NEWBIE_INSTALLER_PATH
}

function make_install_nginx () {
  has_sudo
  cd ${TMP_PATH_NGINX}/nginx-${NGINX_VERSION}
  sudo make install
  cd $NEWBIE_INSTALLER_PATH

  create_user_nginx
  create_folders_nginx
  final_adjustments
}

function run_service_nginx () {
  has_sudo
  sudo systemctl start nginx
}

function execute_nginx_compile () {
  path_nginx
  sleep 1
  download_libs
  sleep 1
  download_nginx
  sleep 1
  unpackage_libs_nginx
  sleep 1
  unpackage_nginx
  sleep 1
  install_dependencies_nginx
  sleep 1
  configure_nginx
  sleep 2
  make_nginx
  sleep 2
  make_install_nginx
  sleep 2
  create_service_nginx
  install_modsecurity
  sleep 2
  module_modsecurity_nginx
  sleep 1
  run_service_nginx
}

function nginx_compile_menu () {

  local option_1="Download libs"
  local option_2="Download Nginx"
  local option_3="Unpackage libs"
  local option_4="Unpackage Nginx"
  local option_5="Install dependencies"
  local option_6="Configure nginx"
  local option_7="Make nginx"
  local option_8="Make install nginx"
  local option_9="Create service"
  local option_10="Configure and compile ModSecurity 3"
  local option_11="ModSecurity - Nginx"
  local option_12="Start service"
  local option_all="All"
  trap '' 2  # ignore control + c
  while true
  do
    local answer
    local input
    clear # clear screen for each loop of menu
    green_text "================================"
    green_text "================================"
    echo "-----------          -----------"
    red_text "${NAME_OF_THE_MODULE}"
    echo "-----------          -----------"
    green_text "================================"
    green_text "================================"
    echo "Enter 1) ${option_1}"
    echo "Enter 2) ${option_2}"
    echo "Enter 3) ${option_3}"
    echo "Enter 4) ${option_4}"
    echo "Enter 5) ${option_5}"
    echo "Enter 6) ${option_6}"
    echo "Enter 7) ${option_7}"
    echo "Enter 8) ${option_8}"
    echo "Enter 9) ${option_9}"
    echo "Enter 10) ${option_10}"
    echo "Enter 11) ${option_11}"
    echo "Enter 12) ${option_12}"
    echo "Enter a) ${option_all}"
    red_text "Enter q) Quit"
    yellow_text "Enter your selection here and hit <return>"
    read answer
    case "$answer" in
     1) path_nginx && download_libs && green_text "Finished ${option_1}" ;;
     2) path_nginx && download_nginx && green_text "Finished ${option_2}" ;;
     3) unpackage_libs_nginx && green_text "Finished ${option_3}" ;;
     4) unpackage_nginx && green_text "Finished ${option_4}" ;;
     5) install_dependencies_nginx && green_text "Finished ${option_5}" ;;
     6) configure_nginx && green_text "Finished ${option_6}" ;;
     7) make_nginx && green_text "Finished ${option_7}" ;;
     8) make_install_nginx && green_text "Finished ${option_8}" ;;
     9) create_service_nginx && green_text "Finished ${option_9}" ;;
     10) install_modsecurity && green_text "Finished ${option_10}" ;;
     11) module_modsecurity_nginx && green_text "Finished ${option_11}" ;;
     12) run_service_nginx && green_text "Finished ${option_12}" ;;
     a) execute_nginx_compile && green_text "Finished ${option_all}" ;;
     q) good_bye ;;
    esac
    red_text "Hit the <return> key to continue"
    read input
  done
}
