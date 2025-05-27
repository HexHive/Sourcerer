#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "matplotlib",
#   "numpy",
#   "pandas",
# ]
# ///


import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import re
import pandas as pd
import os
from multiprocessing import Pool
from matplotlib.ticker import MaxNLocator
matplotlib.rcParams.update({'font.size': 20})
matplotlib.rcParams['text.usetex'] = True
log_folder = "/media/bigDisk/sourcerer_bck/"
FUZZERS = [
    "core_fuzzer",
    "filestorage_read_filename_fuzzer",
    "generateusergallerycollage_fuzzer",
    "imdecode_fuzzer",
    "imencode_fuzzer",
    "imread_fuzzer",
    "readnetfromtensorflow_fuzzer"
]
#FUZZERS = [ "core_fuzzer"]

TIMEOUT = 24*3600

#FUZZERS = FUZZERS[:1]

NUMBER_OF_CAMPAIGNS = 4

METRICS =  [
{
    "name": "Branch coverage",
    "column_name": "Branch coverage",
    "method": "cov_files",
    "unit": "\%"
},
{
    "name": "Execs per second",
    "method": "afl_stats",
    "column_name": " execs_per_sec",
    "unit": "exec/s"
    
},
{
    "name": "Total executions",
    "method": "afl_stats",
    "column_name": " total_execs",
    
}
]

def process_metric(METRIC):
    print("Metric:", METRIC["name"])
    TIME_METRIC = "Time" if METRIC["method"] != "afl_stats" else "# relative_time"
    for fuzzer in FUZZERS:
        print("\tProcessing", fuzzer)

        # new plot
        plt.figure(figsize=(8, 5))

        for idx, isASAN in enumerate([False, True]):
            ASAN = "_asan" if isASAN else ""
            campaigns = pd.DataFrame()
            campaigns[TIME_METRIC] = np.arange(0, TIMEOUT, 60)

            for i in range(NUMBER_OF_CAMPAIGNS):
                fuzzer_folder = f"{fuzzer}{ASAN}_{i+1}"
                queue = os.path.join(log_folder, fuzzer_folder, fuzzer + "_data", "output", "default", "queue")
                if METRIC["method"] == "cov_files":
                    data = pd.DataFrame()
                    times = []
                    coverages = []
                    for file in sorted(os.listdir(queue)):
                        if file.endswith(".report") and not file.endswith("report.report"):
                            seed = os.path.join(queue, file)
                            # extract time from such filenames
                            # id:000000,time:0,execs:0,orig:random_20kb.bin
                            # id:000428,src:000427,time:84320907,execs:596520959,op:havoc,rep:1
                            r = re.sub(r".*time:(\d+),.*", r"\1", file)
                            time = int(r) // 1000
                            times.append(time)

                            with open(seed, 'r') as f:
                                # Filename                                                                            Regions    Missed Regions     Cover   Functions  Missed Functions  Executed       Lines      Missed Lines     Cover    Branches   Missed Branches     Cover
                                # TOTAL                                                                                 73980             72127     2.50%        6558              6308     3.81%       64720             62898     2.82%       28670             28227     1.55%

                                coverage = float(f.readlines()[-1].split(" ")[-1].replace("%", "").strip())
                                coverages.append(coverage)
                    datas = {TIME_METRIC: times, METRIC["name"]: coverages}  
                    data_got = pd.DataFrame(datas)
                    full_time_range = pd.DataFrame({TIME_METRIC: range(0, TIMEOUT)})
                    data = full_time_range.merge(data_got, on=TIME_METRIC, how='left').ffill()
                elif METRIC["method"] == "afl_stats":
                    # Index(['# relative_time', ' cycles_done', ' cur_item', ' corpus_count',
                    # ' pending_total', ' pending_favs', ' map_size', ' saved_crashes',
                    # ' saved_hangs', ' max_depth', ' execs_per_sec', ' total_execs',
                    # ' edges_found'],
                    data = pd.read_csv(os.path.join(log_folder, fuzzer_folder, fuzzer + "_data", "output", "default", "plot_data"))
                    # trim "%" from data
                    if data[METRIC["column_name"]].dtype == "string":
                        data[METRIC["column_name"]] = data[METRIC["column_name"]].str.rstrip('%')

                    # convert to float
                    data[METRIC["column_name"]] = data[METRIC["column_name"]].astype(float)


                # drop data after 24h
                data = data[data[TIME_METRIC] <= TIMEOUT]


                # store 
                campaigns[f"campaign_{i+1}"] = data[METRIC["column_name"]]

            # compute the average
            campaigns["mean"] = campaigns.iloc[:, 1:NUMBER_OF_CAMPAIGNS + 1].mean(axis=1)
            campaigns["max"] = campaigns.iloc[:, 1:NUMBER_OF_CAMPAIGNS + 1].max(axis=1)
            campaigns["min"] = campaigns.iloc[:, 1:NUMBER_OF_CAMPAIGNS + 1].min(axis=1)

            # compute 95% interval 


            # plot on the same figure
            plt.plot(campaigns[TIME_METRIC], campaigns['mean'], label="ASan" if isASAN else "Sourcerer")

            plt.fill_between(campaigns[TIME_METRIC], campaigns['min'], campaigns['max'], color='blue' if idx == 0 else 'red', alpha=0.1)

        # time is in seconds. Only have 6h, 12h, 18h, 24h marks
        plt.xticks(np.arange(0, 30*3600, 6*3600), ['0', '6h', '12h', '18h', '24h'])
        #y axis start a 0
        plt.ylim(bottom=0)
        # y axis is only integer
        #plt.gca().yaxis.set_major_locator(MaxNLocator(integer=True))
        #plt.gca().ticklabel_format(style='plain', axis='y')
        # add legend
        plt.legend()

        # add title
        plt.title(f"{METRIC['name']} of {fuzzer}")

        # add labels
        plt.xlabel("Time")
        plt.ylabel(f"{METRIC['name']}" + (f" [{METRIC['unit']}]" if "unit" in METRIC.keys() else ""))

        # make it tight layout
        plt.tight_layout()
        #plt.subplots_adjust(left=0.12, right=0.99, top=0.93, bottom=0.15, wspace=0.3, hspace=0.3)
        # save plot to file
        plt.savefig(f"{fuzzer}_{METRIC['name']}.png")
        plt.close()

if __name__ == "__main__":
    with Pool() as pool:
        pool.map(process_metric, METRICS)
