#!/bin/bash

if [[ -z "${ENVIRONMENT_FOLDER}" ]]; then
  echo "ENVIRONMENT_FOLDER not set, leave"
  exit 1
fi

export ENVIRONMENT_FILE=$ENVIRONMENT_FOLDER/environment_patched.sh
source ${ENVIRONMENT_FILE}

# Apply official patch
PATCH_FOLDER=${TYPESAFETY_FOLDER}/spec_cpu/patch
wget https://www.spec.org/cpu2006/src.alt/447.dealII.libcxx_pair.cpu2006.v1.2.tar.xz
mv 447.dealII.libcxx_pair.cpu2006.v1.2.tar.xz $PATCH_FOLDER
cd $CPU2006_FOLDER
. ./shrc
go top
specxz -dc $PATCH_FOLDER/447.dealII.libcxx_pair.cpu2006.v1.2.tar.xz | spectar -xvf -
