#!/usr/bin/env bash
set -e
set -x 
#export ENVIRONMENT_FOLDER=$HOME/typesafety_vtable_results
# mkdir -p $ENVIRONMENT_FOLDER

if [[ -z "${ENVIRONMENT_FOLDER}" ]]; then
  echo "ENVIRONMENT_FOLDER not set, leave"
  exit 1
fi
if "$(pip list | grep -q -F 'load_dotenv')"; then 
  pip install load_dotenv
fi

if [ ! -f /usr/bin/ccache ] || "$(/usr/bin/ccache --version | grep -q 'ccache version 4.')"; then 
  echo "Installing CCache"
  cd "${HOME}"
  wget https://github.com/ccache/ccache/releases/download/v4.6.3/ccache-4.6.3-linux-x86_64.tar.xz
  tar -xvf ccache-4.6.3-linux-x86_64.tar.xz
  sudo cp ccache-4.6.3-linux-x86_64/ccache /usr/bin/ccache 
  cd -
fi


export ENVIRONMENT_FILE=$ENVIRONMENT_FOLDER/environment_patched.sh
VTYPE_COMMIT_HASH=$(git rev-parse HEAD)
# the RESULT_FOLDER can be set manually if you want some specific name for the folder
RESULT_FOLDER=${ENVIRONMENT_FOLDER}/$(date '+%Y%m%d_%H%M')_${VTYPE_COMMIT_HASH}
export RESULT_FOLDER
sed -i 's@RESULT_FOLDER=.*@RESULT_FOLDER='"${RESULT_FOLDER}"'@g' "${ENVIRONMENT_FILE}"

# shellcheck source=environment_patched.sh
source "$ENVIRONMENT_FILE"

echo "$RESULT_FOLDER"
mkdir -p "$RESULT_FOLDER"


echo "Env. file: $ENVIRONMENT_FILE"
echo "Result folder: $RESULT_FOLDER"
echo "Num of iteration: $NUMBER_OF_ITERATION"

# build type++ clang
cd "${LLVM_FOLDER}"
./fetch_repos.sh
./build.sh
cd -

cd "${TYPESAFETY_FOLDER}/spec_cpu"
cd patch 
./apply_patches.sh
cd ..

#export REFERENCE=/reference
#source "$ENVIRONMENT_FILE"
##build reference clang (vanilla)
#cd "${LLVM_FOLDER}"
#./fetch_repos.sh
#./build.sh
#cd -
#unset REFERENCE
#source "$ENVIRONMENT_FILE"

cd "${TYPESAFETY_FOLDER}/spec_cpu"
NUMBER_OF_ITERATION=1


### run baseline
#./run.py -b cpu2006 -t baseline -i $NUMBER_OF_ITERATION -v
#./run.py -b cpu2017 -t baseline -i $NUMBER_OF_ITERATION -v
##
### run LLVM-CFI 
#./run.py -b cpu2006 -t cfi -i $NUMBER_OF_ITERATION -v
#./run.py -b cpu2017 -t cfi -i $NUMBER_OF_ITERATION -v $STATS

# run type++
#./run.py -b cpu2017 -t baseline -i $NUMBER_OF_ITERATION -v $STATS
#./run.py -b cpu2017 -t baseline -i $NUMBER_OF_ITERATION -v $STATS
#./run.py -b cpu2017 -t cfi -i $NUMBER_OF_ITERATION -v $STATS
#./run.py -b cpu2006 -t cfi -i $NUMBER_OF_ITERATION -v $STATS

#./run.py -b cpu2006 -t baseline -i 1 -v  -m
#./run.py -b cpu2017 -t baseline -i 1 -v  -m

#./run.py -b cpu2006 -t cfi -i 1 -v $STATS -m
#./run.py -b cpu2017 -t cfi -i 1 -v $STATS -m
#./run.py -b cpu2006 -t baseline -i 1 -v -m
#./run.py -b cpu2017 -t baseline -i 1 -v -m

./run.py -b cpu2006 -t vtype -i 1 -v "$STATS" -m
./run.py -b cpu2017 -t vtype -i 1 -v "$STATS" -m
#./run.py -b cpu2017 -t vtype -i $NUMBER_OF_ITERATION -v $STATS
#./run.py -b cpu2006 -t vtype -i $NUMBER_OF_ITERATION -v $STATS -p 444.namd
#./run.py -b cpu2017 -t vtype -i $NUMBER_OF_ITERATION -v $STATS -p 507.cactuBSSN_r 
#./run.py -b cpu2017 -t baseline -i $NUMBER_OF_ITERATION -v -p 526.blender_r


cd -
