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

. utils/is-root.sh
. utils/color.sh
. utils/distro.sh
. utils/arch.sh
. utils/exit.sh
. serv/serv.sh

if is_root; then
    red_text "Error: need to call this script as a normal user, not as root!"
    exit 1
fi

NEWBIE_INSTALLER_VERSION="0.1.0-SNAPSHOT"
NEWBIE_INSTALLER_PATH=$(pwd)

function runs_rookie_menu () {
  local option_1="Servers"
  local option_2=""
  local option_3=""
  trap '' 2  # ignore control + c
  while true
  do
    local answer
    local input
    clear # clear screen for each loop of menu
    red_text "Version: ${NEWBIE_INSTALLER_VERSION}"
    green_text "================================"
    green_text "================================"
    echo "-------------      -------------"
    blue_text "------------- Menu -------------"
    echo "-------                  -------"
    echo "-----------    OS    -----------"
    what_os_are_you
    echo "-----------          -----------"
    green_text "================================"
    green_text "================================"
    echo "Enter 1) ${option_1}"
    red_text "Enter q) Quit"
    yellow_text "Enter your selection here and hit <return>"
    read answer
    case "$answer" in
     1) serv_menu ;;
     q) good_bye ;;
    esac
    red_text "Hit the <return> key to continue"
    read input
  done
}

runs_rookie_menu
