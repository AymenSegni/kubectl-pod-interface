#!/bin/bash

# Copyright © 2021 Aymen Segni segniaymen1@gmail.com
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# select pod
po_list_state() {
  names=($(kubectl $(ns_param) get pods -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}'))
  states=($(kubectl $(ns_param) get pods -o=jsonpath='{range .items[*].status.phase}{@}{"\n"}{end}'))
  for (( i=0; $i < ${#names[@]}; i+=1 )); do echo "${names[i]}: ${states[i]}"; done
}

po_list() {
  kubectl $(ns_param) \
    get pods \
    -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}'
}

po_number_list() {
  po_list_state | nl
}

po_select() {
  po_list | sed -n ${POD:-1}p
}