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
# Date: 30 June 2019
# Version: 0.1.0
# Written by: Raúl González <rafex.dev@gmail.com>

. serv/web-proxy/web-proxy.sh
. serv/vcs/vcs.sh

function serv_menu () {
  local option_1="Web/Proxy"
  local option_2="Version Control System"

  trap '' 2  # ignore control + c
  while true
  do
    local answer
    local input
    clear # clear screen for each loop of menu
    green_text "================================"
    green_text "================================"
    echo "-------------      -------------"
    echo "----------- Servers  -----------"
    echo "-----------          -----------"
    green_text "================================"
    green_text "================================"
    echo "Enter 1) ${option_1}"
    echo "Enter 2) ${option_2}"
    red_text "Enter q) Quit"
    yellow_text "Enter your selection here and hit <return>"
    read answer
    case "$answer" in
     1) web_proxy_menu ;;
     2) vcs_menu ;;
     q) good_bye ;;
    esac
    red_text "Hit the <return> key to continue"
    read input
  done
}
