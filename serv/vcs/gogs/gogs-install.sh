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

GOGS_VERSION="0.11.79"
GOGS_BIN="gogs_${GOGS_VERSION}_linux_amd64.tar.gz"

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
}

function install_gogs () {
  create_user
  unpackage_gogs
}

function execute_all() {
  download_gogs
  sleep 1
  install_gogs
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
     1) download_gogs && green_text "Finished ${option_1}" ;;
     2) install_gogs && green_text "Finished ${option_2}" ;;
     3) unpackage_libs && green_text "Finished ${option_3}" ;;
     4) unpackage_nginx && green_text "Finished ${option_4}" ;;
     a) execute_all && green_text "Finished ${option_all}" ;;
     q) good_bye ;;
    esac
    red_text "Hit the <return> key to continue"
    read input
  done
}
