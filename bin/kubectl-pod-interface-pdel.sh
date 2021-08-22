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

po_del() {
  kubectl $(ns_param) \
    delete pod $(po_select)
}

po_del_all() {
  kubectl $(ns_param) \
    delete pod $(po_list)
}

po_del_force() {
  kubectl \
    delete pod $(kubectl get pods -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}' |head -n1)
}
