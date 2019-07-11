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

PROFILE_NEWBIE=".newbie"

function create_profile() {
  if [  -f ~/.bashrc ]; then
    if [ ! -f ~/${PROFILE_NEWBIE} ]; then
         touch ~/${PROFILE_NEWBIE}
    fi
    echo "if [ -f ~/${PROFILE_NEWBIE} ]; then
  . ~/${PROFILE_NEWBIE}
fi" >> ~/.bashrc
  fi

  if [  -f ~/.bash_profile ]; then
    if [ ! -f ~/${PROFILE_NEWBIE} ]; then
         touch ~/${PROFILE_NEWBIE}
    fi
    echo "if [ -f ~/${PROFILE_NEWBIE} ]; then
  . ~/.newbie
fi" >> ~/.bash_profile
  fi
}

function load_profile() {
  if [  -f ~/.bashrc ]; then
    source ~/.bashrc
  fi

  if [  -f ~/.bash_profile ]; then
    source ~/.bash_profile
  fi
  red_text "Load you bash source ~/.bashrc or source ~/.bash_profile"
}
