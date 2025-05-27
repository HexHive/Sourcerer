
#!/bin/bash

cp ../../spec2006/cpu2006.patch .
./../../spec2006/run-spec2006.sh test ref 444.namd 447.dealII 450.soplex 453.povray 
./../../spec2006/run-spec2006.sh test ref 471.omnetpp 473.astar 483.xalancbmk
