#!/bin/bash
cd ${HOME}/LLVM-typepp
export NUMBER_OF_REPLICATION=1
export RESULT_FOLDER=./results

perf_containers=("cpu_baseline" "cpu_sourcerer" "cpu_sourcerer_no_check" "cpu_sourcerer_abi_only")

for container in "${perf_containers[@]}"; do
    docker build . --target $container -t $container
done
wait

for container in "${perf_containers[@]}" "${stats_containers[@]}" "${memory_containers[@]}"; do
    docker kill ${container}_container > /dev/null 2>&1 || true
    docker rm ${container}_container > /dev/null 2>&1 || true
    rm -drf results_${container} || true
done

cd ${HOME}/LLVM-typepp
mkdir -p results

for container in "${perf_containers[@]}"; do
    # run the experiment
    docker run --env NUMBER_OF_ITERATION=$NUMBER_OF_REPLICATION --name ${container}_container -t $container || { echo "Failed to run ${container}_container"; exit 1; }
    # collect the results
    docker container cp ${container}_container:/home/nbadoux/results results_${container} || { echo "Failed to copy results from ${container}_container"; exit 1; }
    sed -i 's/baseline/ablation_baseline/g'      results_${container}/runtime_performance.csv      
    sed -i "s/sourcerer/ablation_${container}/g" results_${container}/runtime_performance.csv      
    sed -i "s/cpu_//g"                           results_${container}/runtime_performance.csv      
    cat results_${container}/runtime_performance.csv >> ${RESULT_FOLDER}/ablation_performance_${container}.csv || echo "Failed to append results for ${container}_container" 
    echo "hello" 
done

cat $RESULT_FOLDER/ablation_performance_* > ${RESULT_FOLDER}/ablation_performance.csv

cd ${HOME}/LLVM-typepp
./Type++/script/getperformanceresult.py
