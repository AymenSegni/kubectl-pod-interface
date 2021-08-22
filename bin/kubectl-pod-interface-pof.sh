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

port_list() {
  kubectl get po $(ctx_param) $(ns_param) $(po_select)\
  -o=jsonpath='{..containerPort}' \
  | tr " " "\n" \
  | sort -u
}

# Because *nix denies binding to ports below 1001, we assign a port of N+50000,
# where `n` is a sub-1001 port. Much better to adhere to the security protocol
# than to manipulate the bash binary.
# See second caveat: https://stackoverflow.com/a/414258/4096495
port_check() {
  if [[ $1 -lt 1001 ]]; then
    echo "$(($1+50000))";
  else
    echo $1;
  fi
}

port_x() {
  for i in $(port_list); do
    echo $(port_check $i):${i}
  done
}

port_number_list() {
  port_list | nl
}

po_pf_all() {
  # Store CMD as an array, because passing strings with colons is unpredictable.
  local CMD=(kubectl port-forward $(ctx_param) $(ns_param) $(po_select) $(port_x))
  if [ ! -z "${KILLD:-}" ]; then killd "${CMD[@]}"; exit 0; fi
  checkdaemon "${CMD[@]}"
}

# Requires daemon process CMD array as argument.
killd() {
  CMD=("$@")
  STRING=$(printf ' %q' "${CMD[@]}"  | sed -e 's/^[[:space:]]*//')
  local PID=$(ps -aef | grep $STRING | grep -v grep | awk '{print $2}')
  if [ ! -z "${PID}" ]; then
    kill -9 ${PID} || true
  fi

  # Remove CMD entry from daemon file.
  local TMPFILE="${APPDIR}"/kpoofd.tmp
  if [ -f $DAEMONSFILE ]; then
    awk -v cmd=$STRING '$0!=cmd {print $0}' $DAEMONSFILE > $TMPFILE && mv $TMPFILE $DAEMONSFILE
  fi
}

killdall() {
  if [ -f $DAEMONSFILE ]; then
    while read CMD;
    do
      killd ${CMD}
    done < $DAEMONSFILE
    rm $DAEMONSFILE
  fi
}

# Requires daemon process CMD array as argument.
checkdaemon() {
  CMD=("$@")
  if [ ! -z "${DAEMON:-}" ]; then
    daemon "${CMD[@]}"
  else
    "${CMD[@]}"
  fi
}

# Requires daemon process CMD array as argument.
# Each daemon CMD (see `man ps`) consists of a unique `kubectl port-forward`
# command string, represented in this argument as an array.
daemon() {
  CMD=("$@")
  STRING=$(printf ' %q' "${CMD[@]}"  | sed -e 's/^[[:space:]]*//')
  # Always kill any running version of this exact process to avoid port-forward
  # conflicts.
  # Note that we could alternatively check whether the process is already
  # running, and if so, not bother killing/restarting the daemon. owever, if the
  # earlier running process is running but no longer works, then the user would
  # need to `kpoof -k` to kill it and then `kpoof -d` to start it again. Since
  # the port-forward process is quick to both kill and start, we do it for the
  # user automatically to save manual checking and frustration.
  killd "${CMD[@]}"

  # Start daemon.
  "${CMD[@]}" > ${LOGFILE} 2>&1 &

  # Add to list of running daemons.
  echo $STRING >> ${DAEMONSFILE}

  # Give the user initial output so they have immediate port-forwarding info
  # even when daemonizing. However, it may take a short time for the kubectl
  # port-forward command to write output to the logfile, so wait a reasonable
  # amount of time (10 seconds total, at 1/2 second intervals).
  for i in $(seq 1 20);
  do
    OUTPUT=$(cat ${LOGFILE})
    if [ ! -z "$OUTPUT" ]; then
      echo "${OUTPUT}"
      echo 'When finished, stop this daemon process with kpoof -k, or stop all kubectl port-forward processes with kpoof -a'
      exit 0
    fi
    echo 'Port forwarding is still pending. Waiting...'
    sleep 0.5
  done
  echo "Port forwarding didn't resolve within 10 seconds"
}

initappdir() {
  mkdir -p ${APPDIR}
}