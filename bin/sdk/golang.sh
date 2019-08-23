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
# Date: 09 July 2019
# Version: 0.1.0
# Written by: Raúl González <rafex.dev@gmail.com>

NAME_OF_THE_MODULE="Golang install"
INITIAL_TEXT="Load module ${NAME_OF_THE_MODULE}"
INSTALLATION_PATH_GOLANG="/usr/local/go"
GOLANG_VERSION="1.12.9"
GOLANG_BINARY="go${GOLANG_VERSION}.linux-amd64.tar.gz"
TMP_PATH_GOLANG="${HOME}/tmp/golang"

function download_golang () {
  curl https://dl.google.com/go/$GOLANG_BINARY --output ${TMP_PATH_GOLANG}/${GOLANG_BINARY}
}

function unpackage_golang () {
  tar -xvf ${TMP_PATH_GOLANG}/${GOLANG_BINARY} -C ${TMP_PATH_GOLANG}
}

function install_golang() {
  if [ ! -f ${TMP_PATH_GOLANG}/${GOLANG_BINARY} ]; then
    download_golang
  fi
  unpackage_golang
  has_sudo
  sudo mv -vf ${TMP_PATH_GOLANG}/go $INSTALLATION_PATH_GOLANG
  create_profile
  echo "export PATH=\$PATH:${INSTALLATION_PATH_GOLANG}/bin" >> ~/${PROFILE_NEWBIE}
  mkdir -p $HOME/go
  echo "export GOPATH=\$HOME/go" >> ~/${PROFILE_NEWBIE}
  load_profile
}

function execute_all_golang() {
  install_golang
}

function golang_menu () {
 local option_1="Download Golang"
 local option_2="Install Golang"
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
   echo "Enter a) ${option_all}"
   red_text "Enter q) Quit"
   yellow_text "Enter your selection here and hit <return>"
   read answer
   case "$answer" in
    1) download_golang && green_text "Finished ${option_1}" ;;
    2) install_golang && green_text "Finished ${option_2}" ;;
    a) execute_all_golang && green_text "Finished ${option_all}" ;;
    q) good_bye ;;
   esac
   red_text "Hit the <return> key to continue"
   read input
 done
}
