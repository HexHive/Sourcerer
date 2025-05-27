#!/bin/bash
set -x
set -e

cp -u /home/nbadoux/LLVM-typepp/cpu2006-1.2.iso .
docker build . --target effective-san-eval -t effective-san-eval
docker run --privileged  -t effective-san-eval 
#docker run --privileged  -it effective-san-eval bash
