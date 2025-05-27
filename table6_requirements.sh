#!/bin/bash
sudo apt install -qq -y tightvncserver x11-apps unzip 

mkdir -p ${HOME}/.vnc
echo 123456 | vncpasswd -f > ${HOME}/.vnc/passwd
sudo chown -R $USERNAME:$USERNAME ${HOME}/.vnc
sudo chmod 0600 ${HOME}/.vnc/passwd
tightvncserver
DISPLAY=:1 xhost +localhost

cd ${HOME}/LLVM-typepp
export DEPTH=100
export CHROMIUM_REPO=https://github.com/vwvw/chromium
export CHROMIUM_BRANCH_BASELINE=typepp
export CHROMIUM_BRANCH_TYPEPP=typepp-partial-changes
export CHROMIUM_FOLDER=${HOME}/LLVM-typepp/Type++/chromium
git clone $CHROMIUM_REPO --single-branch --branch $CHROMIUM_BRANCH_BASELINE ${CHROMIUM_FOLDER}/chromium-baseline --depth $DEPTH
git clone $CHROMIUM_REPO --single-branch --branch $CHROMIUM_BRANCH_TYPEPP ${CHROMIUM_FOLDER}/chromium-typepp --depth $DEPTH
