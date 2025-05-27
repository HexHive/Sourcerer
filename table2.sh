#!/bin/bash
set -e
set -x
cd ${HOME}/LLVM-typepp
export NUMBER_OF_REPLICATION=1
export RESULT_FOLDER=./results

#perf_containers=("cpu_baseline" "cpu_cfi" "cpu_sourcerer")
#perf_containers=("cpu_sourcerer")
perf_containers=("memory_baseline" "cpu_cfi" "memory_sourcerer")
stats_containers=("cpu_cfi_stats" "cpu_sourcerer_stats")
#stats_containers=("cpu_sourcerer_stats")

for container in "${perf_containers[@]}" "${stats_containers[@]}" "${memory_containers[@]}"; do
    docker build . --target $container -t $container &
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
    cp results_${container}/runtime_performance.csv ${RESULT_FOLDER}/runtime_performance_${container}.csv || { echo "Failed to append results for ${container}_container"; exit 1; }
    if [[ $container == memory* ]]; then
        cp results_${container}/total_result_${container}_* ${RESULT_FOLDER}/ || { echo "Failed to copy results for ${container}_container"; exit 1; }
    fi

    # clean up if we did not run memory runs
    cp cpu_baseline/* memory_baseline || true
    cp cpu_sourcerer/* memory_sourcerer || true 
    rm -drf cpu_baseline cpu_sourcerer || true
done

cd ${HOME}/LLVM-typepp

for container in "${stats_containers[@]}"; do
    # run the experiment
    docker run --env NUMBER_OF_ITERATION=1 --env VERSION="13.0.0" --name ${container}_container -t $container || { echo "Failed to run ${container}_container"; exit 1; }
    # collect the results
    docker container cp ${container}_container:/home/nbadoux/results results_${container} || { echo "Failed to copy results from ${container}_container"; exit 1; }
    cp results_${container}/total_result* ${RESULT_FOLDER}/ || { echo "Failed to copy results for ${container}_container"; exit 1; }
    if [[ $container == cpu_sourcerer* ]]; then
        cp results_${container}/merge_log_* ${RESULT_FOLDER}/ || { echo "Failed to copy results for ${container}_container"; exit 1; }
    fi
done

cat ${RESULT_FOLDER}/runtime_performance_* > ${RESULT_FOLDER}/runtime_performance.csv

./Type++/script/getmemoryoverhead.py
./Type++/script/getperformanceresult.py
