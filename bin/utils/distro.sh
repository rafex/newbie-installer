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
# Date: 29 June 2019
# Version: 0.1.0
# Written by: Raúl González <rafex.dev@gmail.com>

DISTRO_DEBIAN="debian"
DISTRO_CENTOS="centos"
DISTRO_FEDORA="fedora"
DISTRO_ALPINE="alpine"
DISTRO_RASPBIAN="raspbian"
DISTRO_RHEL="Red Hat Enterprise Linux Server"
RULZZ="rulzz!!"

function what_distribution_are_you () {
    local distro=$(awk -F= '/^NAME/{print $2}' /etc/*release* | tr "[:upper:]" "[:lower:]")
    if [[ $distro == *${DISTRO_DEBIAN}* ]]; then
        echo $DISTRO_DEBIAN
    elif [[ $distro == *${DISTRO_RASPBIAN}* ]]; then
        echo $DISTRO_RASPBIAN
    elif [[ $distro == *${DISTRO_CENTOS}* ]]; then
        echo $DISTRO_CENTOS
    elif [[ $distro == *${DISTRO_FEDORA}* ]]; then
        echo $DISTRO_FEDORA
    elif [[ $distro == *${DISTRO_ALPINE}* ]]; then
        echo $DISTRO_ALPINE
    fi
}

function what_distribution_are_you_v2 () {
    local what_name=$(uname | tr "[:upper:]" "[:lower:]")
    if [ "$UNAME" == "linux" ]; then
        if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
            export WHAT_DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'// | tr "[:upper:]" "[:lower:]")
        else
            export WHAT_DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1 | tr "[:upper:]" "[:lower:]")
        fi
    fi
    [ "$WHAT_DISTRO" == "" ] && export WHAT_DISTRO=$what_name
}

function what_os_are_you () {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        echo "GNU/Linux"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "GNU/Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    else
        red_text "Unknown"
        exit
    fi
}
