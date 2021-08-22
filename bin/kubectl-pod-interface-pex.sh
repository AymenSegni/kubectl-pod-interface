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

po_exec() {
  kubectl $(ns_param) \
    exec -it $(po_select) -- sh -c ${COMMAND:-bash}
}

con_list() {
  kubectl $(ns_param) \
    get po $(po_select) \
    -o=jsonpath='{..containers[*].name}' \
    | tr " " "\n" \
    | sort -u
}

con_number_list() {
  con_list | nl
}

con_select() {
  con_list | sed -n ${CON:-1}p
}

con_count() {
  con_list | wc -w
}

co_param() {
  local container=$(con_select)
  if [[ $(con_count) -gt 1 && ! -z ${container:-} ]]; then
    echo "--container=${container}"
  fi
}

po_exec_con() {
  kubectl $(ns_param) \
    exec -it $(po_select) $(co_param) -- sh -c ${COMMAND:-bash}
}