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
# Date: 08 July 2019
# Version: 0.1.0
# Written by: Raúl González <rafex.dev@gmail.com>

NAME_OF_THE_MODULE="Gogs install"
INITIAL_TEXT="Load module ${NAME_OF_THE_MODULE}"
GOGS_INSTALLATION_PATH="/opt/gogs"
GOGS_USER="gogs"
GOGS_GROUP="gogs"
TMP_PATH="/tmp"
GOGS_PORT=3000
NAME_REPOSITORY="Newbie Installer Repository"

GOGS_VERSION="0.11.79"
GOGS_BIN="gogs_${GOGS_VERSION}_linux_amd64.tar.gz"

function install_dependencies_for_debian () {
  has_sudo
  red_text "Install dependencies for Debian"
  sudo apt -y install curl sqlite3
}

function install_dependencies_for_centos () {
  has_sudo
  blue_text "Install dependencies for CentOS"
  sudo yum -y install curl sqlite3
}

function install_dependencies () {
  local distro=$(what_distribution_are_you)
  case $distro in
    debian) install_dependencies_for_debian ;;
    centos) install_dependencies_for_centos ;;
    *) red_text "We have not detected your distribution, we're sorry!!! U.U";;
  esac
}

function download_gogs() {
  curl https://dl.gogs.io/0.11.79/$GOGS_BIN --output ${TMP_PATH}/${GOGS_BIN}
}

function  create_user () {
  has_sudo
  sudo useradd --system $GOGS_USER
  sudo usermod -s /sbin/nologin $GOGS_USER
}

function unpackage_gogs () {
  tar -xvf ${TMP_PATH}/${GOGS_BIN} -C ${TMP_PATH}
  sudo mv ${TMP_PATH}/gogs
  sudo chown -R $GOGS_USER:$GOGS_GROUP ${GOGS_INSTALLATION_PATH}
  sudo rm -rf ${GOGS_INSTALLATION_PATH}/scripts
}

function create_folders () {
  has_sudo
  sudo mkdir -p /var/log/gogs
  sudo mkdir -p /etc/gogs/config
  sudo mkdir -p ${GOGS_INSTALLATION_PATH}/custom/config
  sudo mkdir -p ${GOGS_INSTALLATION_PATH}/data/repository
  sudo mkdir -p ${GOGS_INSTALLATION_PATH}/data/sqlite
  sudo chown -R $GOGS_USER:$GOGS_GROUP /var/log/gogs
  sudo chown -R $GOGS_USER:$GOGS_GROUP ${GOGS_INSTALLATION_PATH}
}

function create_config_gogs () {
  ip_detect_v01
  random_alphanumeric 32
  cat > ${TMP_PATH}/app.ini.newbie << EOF
  APP_NAME = ${NAME_REPOSITORY}
  RUN_USER = ${GOGS_USER}
  RUN_MODE = prod

  [database]
  DB_TYPE  = sqlite3
  HOST     = 127.0.0.1:3306
  NAME     = ${GOGS_USER}
  USER     = root
  PASSWD   =
  SSL_MODE = disable
  PATH     = ${GOGS_INSTALLATION_PATH}/data/sqlite/gogs.db

  [repository]
  ROOT = ${GOGS_INSTALLATION_PATH}/data/repository

  [server]
  DOMAIN           = ${MY_IP}
  HTTP_PORT        = ${GOGS_PORT}
  ROOT_URL         = http://${MY_IP}:${GOGS_PORT}/
  DISABLE_SSH      = false
  SSH_PORT         = 22
  START_SSH_SERVER = false
  OFFLINE_MODE     = true

  [mailer]
  ENABLED = false

  [service]
  REGISTER_EMAIL_CONFIRM = false
  ENABLE_NOTIFY_MAIL     = false
  DISABLE_REGISTRATION   = false
  ENABLE_CAPTCHA         = true
  REQUIRE_SIGNIN_VIEW    = true

  [picture]
  DISABLE_GRAVATAR        = true
  ENABLE_FEDERATED_AVATAR = false

  [session]
  PROVIDER = file

  [log]
  MODE      = file
  LEVEL     = Info
  ROOT_PATH = /var/log/gogs

  [security]
  INSTALL_LOCK = true
  SECRET_KEY   = ${RANDOM_ALPHANUMERIC}
EOF
  has_sudo
  sudo cp -v ${TMP_PATH}/app.ini.newbie /etc/gogs/config/app.ini
  sudo ln -s /etc/gogs/config/app.ini ${GOGS_INSTALLATION_PATH}/custom/conf/app.ini
}

function create_service() {
  cat > ${TMP_PATH}/gogs.service.newbie << EOF
  [Unit]
  Description=Gogs git server
  After=syslog.target
  After=network.target

  [Service]
  User=${GOGS_USER}
  Group=${GOGS_GROUP}
  ExecStart=${GOGS_INSTALLATION_PATH}/gogs web
  Restart=always
  WorkingDirectory=${GOGS_INSTALLATION_PATH}

  [Install]
  WantedBy=multi-user.target
EOF
  has_sudo
  sudo cp -v ${TMP_PATH}/gogs.service.newbie /etc/systemd/system/gogs.service
  sudo chmod 755 /etc/systemd/system/gogs.service
  sudo systemctl daemon-reload
  sudo systemctl enable gogs.service
}

function create_data_base_sqlite () {
  cd ${GOGS_INSTALLATION_PATH}/data/sqlite
  sudo echo ".open gogs.db" | sqlite3
  sudo chown $GOGS_USER:$GOGS_GROUP gogs.db
  cd $NEWBIE_INSTALLER_PATH
}

function run_service () {
  has_sudo
  sudo systemctl start gogs
}

function install_gogs () {
  create_user
  unpackage_gogs
  create_folders
  create_data_base_sqlite
  create_config_gogs
  create_service
}

function execute_all() {
  download_gogs
  sleep 1
  install_gogs
  run_service
}

function gogs_install_menu () {

  local option_1="Download Gogs 64 bits"
  local option_2="Install Gogs"
  local option_3="Create service"
  local option_4="Start service"
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
    echo "Enter a) ${option_all}"
    red_text "Enter q) Quit"
    yellow_text "Enter your selection here and hit <return>"
    read answer
    case "$answer" in
     1) install_dependencies && download_gogs && green_text "Finished ${option_1}" ;;
     2) install_dependencies && install_gogs && green_text "Finished ${option_2}" ;;
     3) create_service && green_text "Finished ${option_3}" ;;
     4) run_service && green_text "Finished ${option_4}" ;;
     a) execute_all && green_text "Finished ${option_all}" ;;
     q) good_bye ;;
    esac
    red_text "Hit the <return> key to continue"
    read input
  done
}
