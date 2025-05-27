#!/usr/bin/env bash
# shellcheck  disable=SC1091
set -e
set -x

#This script softlinks our modified files into the LLVM source tree

if [[ -z "${ENVIRONMENT_FOLDER}" ]]; then
  echo "ENVIRONMENT_FOLDER not set, leave"
  exit 1
fi
# set the environment properly, find better folder for the original script
source "${ENVIRONMENT_FOLDER}/environment_patched.sh"


# Setup WSS fodler
if [ -z "${WSS_FOLDER+x}" ]; then 
  echo "export WSS_FOLDER=\${TYPESAFETY_FOLDER}/wss" >> "${ENVIRONMENT_FOLDER}/environment_patched.sh"
  source "${ENVIRONMENT_FOLDER}/environment_patched.sh "
fi

if [ ! -d "${WSS_FOLDER}" ]; then
  mkdir "${WSS_FOLDER}"
  git clone  https://github.com/vwvw/wss.git "${WSS_FOLDER}"
else 
  cd "${WSS_FOLDER}"
  git pull
fi
