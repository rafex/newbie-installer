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
# Date: 24 September 2020
# Version: 0.1.0
# Written by: Raúl González <rafex.dev@gmail.com>

# . ../../utils/color.sh
# . ../../utils/is-root.sh

NAME_OF_THE_MODULE="Jitsi"
INITIAL_TEXT="Load module ${NAME_OF_THE_MODULE}"
TMP_PATH_JITSI="/opt/jitsi-newbie-installer"

function add_dependencies () {
  has_sudo
  sudo apt-get install -y apt-transport-https curl gnupg2
}

function key_repository () {
  has_sudo
  curl https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
}

function add_repository () {
  has_sudo
  echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null
  sudo apt-get update
}

function download_debs () {
  has_sudo
  sudo apt-get install -y --download-only jitsi-meet
}


function jitsi_install_menu () {

 local option_1="Download Key Repository"
 local option_2="Add Repository"
 local option_3="Download Packages"
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
