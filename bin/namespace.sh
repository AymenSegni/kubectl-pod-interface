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
# select namespace
ns_current() {
  # Borrowed partly from kubens current_namespace().
  cur_ctx=$(kubectl config current-context)
  echo "$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${cur_ctx}\")].context.namespace}")"
}

ns_param() {
  local ns=$(ns_select)
  if [[ ! -z ${ns:-} ]]; then
    echo "--namespace=${ns}"
  fi
}

ns_list() {
  kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}'
}

ns_number_list() {
  ns_list | nl
}

ns_select() {
  if [[ ! -z ${NS:-} ]]; then
    ns_list | sed -n ${NS}p
  elif [[ ! -z ${NAMESPACE:-} ]]; then
    echo $NAMESPACE
  else
    ns_current
  fi
}