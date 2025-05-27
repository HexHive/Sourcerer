#!/usr/bin/env python3

import os, io, glob, statistics, pickle, re
from subprocess import Popen, PIPE
from dotenv import load_dotenv
TYPESAFETY_FOLDER = os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir)

# load_dotenv(os.path.join(TYPESAFETY_FOLDER, "environment.sh"))
# load_dotenv(os.path.join(TYPESAFETY_FOLDER, "environment.sh"))
# CPU2006_FOLDER = os.environ.get("CPU2006_FOLDER")
# CPU2017_FOLDER = os.environ.get("CPU2017_FOLDER")
# TEMP_FOLDER = os.environ.get("TEMP_FOLDER")

# RESULTS PATHS
RESULTS_PATH = os.path.join(os.environ["RESULT_FOLDER"])

COLUMN = 1 # RSS
# COLUMN = 2 # PSS
# COLUMN = 3 # Ref

ISNUM = re.compile("[0-9. ].*")

def get_mem_stats():

    # (avg, max)
    stats = {}
    for l in os.listdir(RESULTS_PATH):
        if l.startswith("total_result_memory_"):

            program = None
            conf = None

            l_trim = l.replace("total_result_memory_", "")

            if l_trim.startswith("vtype"):
                l_trim = l_trim.replace("vtype_", "")
                conf = "vtype"
            
            if l_trim.startswith("sourcerer"):
                l_trim = l_trim.replace("sourcerer_", "")
                conf = "srcer"

            if l_trim.startswith("baseline"):
                l_trim = l_trim.replace("baseline_", "")
                conf = "baseline"
            
            if l_trim.startswith("cfi"):
                l_trim = l_trim.replace("cfi_", "")
                conf = "cfi"

            if conf == None:
                print(f"[ERROR] {l} has unknown configuration {{vtype}}")

            program = l_trim[:-4]

            all_memory = []

            with open(os.path.join(RESULTS_PATH, l)) as f:
                next(f)
                unit_measurement = None
                for l in f:
                    l = l.strip()
                    l_arr = l.split(";")
                    if not ISNUM.fullmatch(l_arr[0]): # ensure line start with number (had some weird header lines a few times)
                        continue
                    if unit_measurement is None:
                        unit_measurement = l_arr[COLUMN].strip()[4:-1]
                    else:
                        all_memory += [float(l_arr[COLUMN])]

            avg_memory = statistics.mean(all_memory)
            max_memory = max(all_memory)

            # print(f"Average memory: {avg_memory:.2f}{unit_measurement}")
            # print(f"Max memory: {max_memory:.2f}{unit_measurement}")

            if program not in stats.keys():
                stats[program] = {}

            stats[program][conf] = (avg_memory, max_memory, unit_measurement)

    incomplete_info = set()
    aggr_stats = {}
    get_overhead = lambda new_val, ref_val: round((new_val-ref_val)/ref_val*100,2)
    for p, c in stats.items():
        try:
            baselines = c["baseline"]
            aggr_stats[p] = {}
            for k, v in c.items():
                if k == "baseline":
                    continue
                else:
                    aggr_stats[p][f"avg_{k}_overhead"] = get_overhead(v[0], baselines[0]) 
                    aggr_stats[p][f"max_{k}_overhead"] = get_overhead(v[1], baselines[1])  
        except KeyError as e:
            print(f"[ERROR] failing for {p}: {e}")
            incomplete_info.add((p, str(c)))

    
    # print(aggr_stats)
    #print("Overhead:")
    #for x, v in aggr_stats.items():
    #    print(f"{x}")
    #    for k, n in v.items():
    #        print(f"\t{k}: {n:.2f}%")

    with open(os.path.join(RESULTS_PATH, "memory_overhead.pickle"), "wb") as f:
        pickle.dump(aggr_stats, f)

    # print("Absolute values:")
    # for x, v in stats.items():
    #     print(f"{x}")
    #     for k, n in v.items():
    #         if n[2] == "kB":
    #             print(f"\t{k} avg: {(n[0]/1000):,.2f} mB / max: {(n[1]/1000):,.2f} mB")
    #         else:
    #             print(f"\t{k} avg: {n[0]:,.2f} {n[2]} / max: {n[1]:,.2f} {n[2]}")
    # # print(stats)
    
    if(len(incomplete_info) > 0):
        print("incomplete info:")
        print(incomplete_info)

if __name__ == "__main__":
    get_mem_stats()
