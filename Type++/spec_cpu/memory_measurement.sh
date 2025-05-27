#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo 'You need to pass the benchmark type as 1st argument.'
    echo 'You need to pass the benchmark program name as 2nd argument.'
    exit 1
fi

if [[ -z "${ENVIRONMENT_FOLDER}" ]]; then
  echo "ENVIRONMENT_FOLDER not set, leave"
  exit 1
fi

export ENVIRONMENT_FILE=$ENVIRONMENT_FOLDER/environment_patched.sh
# shellcheck source=../environment_patched.sh
source "$ENVIRONMENT_FILE"

GREP_STRING="^../run_base_"

pgrep_command () { pgrep --full --newest -u "$(whoami)" ${GREP_STRING}; return $?; }

until pgrep_command; do
	echo "PID not yet found"
	sleep 1
done
pid=$(pgrep_command)

"${WSS_FOLDER}"/wss.pl -s 0 "$(pgrep_command)" 1 >> "${RESULT_FOLDER}/total_result_memory_${1}_${2}_$(pgrep_command).csv"

mv  "${RESULT_FOLDER}/total_result_memory_${1}_${2}_${pid}.csv" "${RESULT_FOLDER}/total_result_memory_${1}_${2}.csv"
