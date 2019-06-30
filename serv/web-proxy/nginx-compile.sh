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
NGINX_INSTALLATION_PATH="/opt/nginx"
NGINX_USER="nginx"
TMP_PATH="/tmp"

local zlib="zlib-1.2.11.tar.gz"
local libressl="libressl-2.9.2.tar.gz"
local pcre="pcre-8.43.tar.gz"
local nginx_version="1.17.1"
local nginx_src="nginx-${nginx_version}.tar.gz"

function nginx_hello () {
  blue_text $INITIAL_TEXT
}

function download_libs () {
  curl https://www.zlib.net/$zlib --output $TMP_PATH/$zlib --silent
  curl ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$pcre --output $TMP_PATH/$pcre --silent
  curl https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/$libressl --output $TMP_PATH/$libressl --silent
}

function download_nginx () {
  curl https://nginx.org/download/$nginx_src --output $TMP_PATH/$nginx_src --silent
}

function unpackage_libs () {
  tar -xvf $TMP_PATH/$zlib
  tar -xvf $TMP_PATH/$pcre
  tar -xvf $TMP_PATH/$libressl
}

function unpackage_nginx () {
  tar -xvf $TMP_PATH/$nginx_src
}

# mkdir -p $NGINX_INSTALLATION_PATH

function  create_user () {
  useradd --system $NGINX_USER
  usermod -s /sbin/nologin $NGINX_USER
}

function execute () {
  download_libs
  download_nginx
  unpackage_libs
  unpackage_nginx
}

nginx_hello
