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

COLOR_WHITE="\033[0m"
COLOR_RED="\033[31m"
COLOR_BLUE="\033[34m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"

function red_text () {
	echo -e $COLOR_RED$1$COLOR_WHITE
}

function blue_text () {
	echo -e $COLOR_BLUE$1$COLOR_WHITE
}

function green_text () {
	echo -e $COLOR_GREEN$1$COLOR_WHITE
}

function yellow_text () {
	echo -e $COLOR_YELLOW$1$COLOR_WHITE
}

green_text "Load colors... :-)"
