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
. serv/web-proxy/nginx-compile.sh

if is_root; then
    echo "Error: need to call this script as a normal user, not as root!"
    exit 1
fi

trap '' 2  # ignore control + c
while true
do
  local answer
  local input
  clear # clear screen for each loop of menu
  echo "================================"
  echo "================================"
  echo "-------------      -------------"
  echo "------------- Menu -------------"
  echo "------- Newbie Installer -------"
  echo "================================"
  echo "================================"
  echo "Enter 1 compile Nginx:"
  echo "Enter q to quit q:"
  echo -e "Enter your selection here and hit <return>"
  read answer
  case "$answer" in
   1) nginx_hello;;
   q) exit ;;
  esac
  echo -e "Hit the <return> key to continue"
  read input
done
