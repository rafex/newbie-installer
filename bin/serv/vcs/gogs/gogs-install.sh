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
INSTALLATION_PATH_GOGS="/opt/gogs"
GOGS_USER="gogs"
GOGS_GROUP="gogs"
TMP_PATH_GOGS="/opt/tmp/gogs"
GOGS_PORT=3000
NAME_REPOSITORY="Newbie Installer Repository"

GOGS_VERSION="0.11.79"
GOGS_BIN="gogs_${GOGS_VERSION}_linux_amd64.tar.gz"

function path_gogs () {
  has_sudo
  sudo mkdir -vp $TMP_PATH_GOGS
  sudo chown $USER:$USER $TMP_PATH_GOGS
}

function install_dependencies_gogs_for_debian () {
  has_sudo
  red_text "Install dependencies for Debian"
  sudo apt -y install curl sqlite3 git
}

function install_dependencies_gogs_for_centos () {
  has_sudo
  blue_text "Install dependencies for CentOS"
  sudo yum -y install curl sqlite3 git
}

function install_dependencies_gogs () {
  local distro=$(what_distribution_are_you)
  case $distro in
    debian) install_dependencies_gogs_for_debian ;;
    centos) install_dependencies_gogs_for_centos ;;
    *) red_text "We have not detected your distribution, we're sorry!!! U.U";;
  esac
}

function download_gogs() {
  mkdir -vp $TMP_PATH_GOGS
  curl https://dl.gogs.io/$GOGS_VERSION/$GOGS_BIN --output ${TMP_PATH_GOGS}/${GOGS_BIN}
}

function  create_user_gogs () {
  has_sudo
  sudo useradd --system $GOGS_USER -d ${INSTALLATION_PATH_GOGS}
  sudo usermod -s /sbin/nologin $GOGS_USER
}

function unpackage_gogs () {
  tar -xvf ${TMP_PATH_GOGS}/${GOGS_BIN} -C ${TMP_PATH_GOGS}
  sudo mv -vf ${TMP_PATH_GOGS}/gogs /opt/
  sudo chown -R $GOGS_USER:$GOGS_GROUP ${INSTALLATION_PATH_GOGS}
  sudo rm -rf ${INSTALLATION_PATH_GOGS}/scripts
}

function create_folders_gogs () {
  has_sudo
  sudo mkdir -vp /var/log/gogs
  sudo mkdir -vp /etc/gogs/config
  sudo mkdir -vp ${INSTALLATION_PATH_GOGS}/custom/conf
  sudo mkdir -vp ${INSTALLATION_PATH_GOGS}/data/repository
  sudo mkdir -vp ${INSTALLATION_PATH_GOGS}/data/sqlite
  sudo chown -R $GOGS_USER:$GOGS_GROUP /var/log/gogs
  sudo chown -R $GOGS_USER:$GOGS_GROUP ${INSTALLATION_PATH_GOGS}
}

function create_config_gogs () {
  ip_detect_v01
  random_alphanumeric 32
  cat > ${TMP_PATH_GOGS}/app.ini.newbie << EOF
  APP_NAME = ${NAME_REPOSITORY}
  RUN_USER = ${GOGS_USER}
  RUN_MODE = prod

  [database]
  DB_TYPE  = sqlite3
  HOST     = 127.0.0.1:3306
  PATH     = ${INSTALLATION_PATH_GOGS}/data/sqlite/gogs.db

  [repository]
  ROOT = ${INSTALLATION_PATH_GOGS}/data/repository

  [server]
  DOMAIN           = ${MY_IP}
  HTTP_PORT        = ${GOGS_PORT}
  ROOT_URL         = http://${MY_IP}:${GOGS_PORT}/
  DISABLE_SSH      = true
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
  sudo cp -v $TMP_PATH_GOGS/app.ini.newbie /etc/gogs/config/app.ini
  sudo ln -s /etc/gogs/config/app.ini $INSTALLATION_PATH_GOGS/custom/conf/app.ini
}

function create_service_gogs() {
  cat > ${TMP_PATH_GOGS}/gogs.service.newbie << EOF
  [Unit]
  Description=Gogs git server
  After=syslog.target
  After=network.target

  [Service]
  User=${GOGS_USER}
  Group=${GOGS_GROUP}
  ExecStart=${INSTALLATION_PATH_GOGS}/gogs web
  Restart=always
  WorkingDirectory=${INSTALLATION_PATH_GOGS}

  [Install]
  WantedBy=multi-user.target
EOF
  has_sudo
  sudo cp -v ${TMP_PATH_GOGS}/gogs.service.newbie /etc/systemd/system/gogs.service
  sudo chmod 755 /etc/systemd/system/gogs.service
  sudo systemctl daemon-reload
  sudo systemctl enable gogs.service
}

function create_data_base_sqlite () {
  cd ${INSTALLATION_PATH_GOGS}/data/sqlite
  cd ${TMP_PATH_GOGS}
  echo ".save gogs.db" | sqlite3
  sudo mv -vf ${TMP_PATH_GOGS}/gogs.db ${INSTALLATION_PATH_GOGS}/data/sqlite/.
  sudo chown -R $GOGS_USER:$GOGS_GROUP ${INSTALLATION_PATH_GOGS}/data/sqlite
  cd $NEWBIE_INSTALLER_PATH
}

function run_service_gogs () {
  has_sudo
  sudo systemctl start gogs
}

function install_gogs () {
  create_user_gogs
  sleep 2
  unpackage_gogs
  sleep 2
  create_folders_gogs
  sleep 2
  create_data_base_sqlite
  sleep 2
  create_config_gogs
  sleep 2
  create_service_gogs
}

function execute_all_gogs() {
  path_gogs
  sleep 2
  download_gogs
  sleep 2
  install_gogs
  sleep 2
  run_service_gogs
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
     1) path_gogs && install_dependencies_gogs && download_gogs && green_text "Finished ${option_1}" ;;
     2) install_dependencies_gogs && install_gogs && green_text "Finished ${option_2}" ;;
     3) create_service_gogs && green_text "Finished ${option_3}" ;;
     4) run_service_gogs && green_text "Finished ${option_4}" ;;
     a) execute_all_gogs && green_text "Finished ${option_all}" ;;
     q) good_bye ;;
    esac
    red_text "Hit the <return> key to continue"
    read input
  done
}
