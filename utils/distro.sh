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

DISTRO_DEBIAN="Debian"
DISTRO_CENTOS="CentOS"
RULZZ="rulzz!!"

function what_distribution_are_you () {
  local distro=$(awk -F= '/^NAME/{print $2}' /etc/*release*)
  if [[ $distro == *${DISTRO_DEBIAN}* ]]; then
    echo $DISTRO_DEBIAN
  elif [[ $distro == *${DISTRO_CENTOS}* ]]; then
    echo $DISTRO_CENTOS
  fi
}
