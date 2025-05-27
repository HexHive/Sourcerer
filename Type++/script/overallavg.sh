#!/bin/bash

cd /home/tregua/typesafety_vtable_results/FINALRESULTS
SUM_VTYPE_CPU2017=$(cat runtime_performance_clean.csv | grep vtype | grep cpu2017 | awk -F "|" '{sum += $5}END{print sum}')
echo "sum vtype cpu 2017"
echo $SUM_VTYPE_CPU2017

SUM_BASELINE_CPU2017=$(cat runtime_performance_clean.csv | grep baseline | grep cpu2017 | awk -F "|" '{sum += $5}END{print sum}')
echo "sum baseline cpu 2017"
echo $SUM_BASELINE_CPU2017

SUM_VTYPE_CPU2006=$(cat runtime_performance_clean.csv | grep vtype | grep cpu2006 | awk -F "|" '{sum += $5}END{print sum}')
echo "sum vtype cpu 2006"
echo $SUM_VTYPE_CPU2006

SUM_BASELINE_CPU2006=$(cat runtime_performance_clean.csv | grep baseline | grep cpu2006 | awk -F "|" '{sum += $5}END{print sum}')
echo "sum baseline cpu 2006"
echo $SUM_BASELINE_CPU2006

SUM_OVERHEAD_CPU2006=$(echo "($SUM_VTYPE_CPU2006/$SUM_BASELINE_CPU2006)*100-100" | bc -l)
echo "sum overhead cpu 2006"
echo $SUM_OVERHEAD_CPU2006

SUM_OVERHEAD_CPU2017=$(echo "($SUM_VTYPE_CPU2017/$SUM_BASELINE_CPU2017)*100-100" | bc -l)
echo "sum overhead cpu 2017"
echo $SUM_OVERHEAD_CPU2017

cd /home/tregua/typesafety_vtable_results/PATCHLESS
for p in 453.povray 447.dealII 511.povray_r 526.blender_r; do
    SUM_PATCHED=$(cat runtime_performance_patched.csv | grep $p | awk -F "|" '{sum += $5}END{print sum}')
    SUM_ORIGINAL=$(cat runtime_performance_original.csv | grep $p | awk -F "|" '{sum += $5}END{print sum}')
    OVERHEAD=$(echo "($SUM_PATCHED/$SUM_ORIGINAL)*100-100" | bc -l)
    echo "overhead $p: $OVERHEAD %"
done
