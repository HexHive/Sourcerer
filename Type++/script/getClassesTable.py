#!/usr/bin/env python3
from infra import overhead, get_avg, millify, prog_names

import os
from dotenv import load_dotenv
import re
import tabulate
import pickle

if not os.environ.get("RESULT_FOLDER"):
    if (not ENVIRONMENT_FOLDER or not os.path.isfile(
           os.path.join(ENVIRONMENT_FOLDER, env_patch_str)
                        )):
        print(
             f"ENVIRONMENT_FOLDER is not set or incorrect. Aborting.\n{ENVIRONMENT_FOLDER=}"
        )
        exit(255)
    TYPESAFETY_FOLDER = os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir)

    load_dotenv(os.path.join(ENVIRONMENT_FOLDER, env_patch_str))

RESULT_FOLDER = os.environ.get("RESULT_FOLDER")
OUTPUT_FILE = os.path.join(RESULT_FOLDER, "aggregated_results.csv")
prg_re = re.compile("merge_log_sourcerer_(.*).txt")

results = {}


prog_size = {
    "444.namd": 3887,
    "447.dealII": 94832,
    "450.soplex": 28277,
    "453.povray": 78679,
    "471.omnetpp": 26647,
    "473.astar": 4280,
    "483.xalancbmk": 264389,
    "507.cactuBSSN_r": 63307,
    "508.namd_r": 6396,
    "510.parest_r": 359012,
    "511.povray_r": 80079,
    "526.blender_r": 615895,
    "520.omnetpp_r": 85732,
    "523.xalancbmk_r": 291160,
    "531.deepsjeng_r": 7284,
    "541.leela_r": 30524,
}

prog = list(prog_names.keys())

CATEGORY = {"Classes to instrument:" : "Total",
            "Classes in derived:" : "DRVD",
            "Unique classes in unrelated:" : "UNRL",
            "Unique classes in from_void:" : "from void",
#            "Classes in from_void:" : "from_void",
#            "Classes in unrelated:" : "unrelated",
#            "Classes in to_void:" : "to_void",
            "Unique classes in to_void:" : "# to void",
}
    
results[""] = [prog_names[p] for p in prog]
results["LoC"] = [prog_size[p] for p in prog]
for c in CATEGORY.values():
    results[c] = ['-'] * len(prog_names)

def read_merge_log_files():
    for filename in os.listdir(RESULT_FOLDER):
        if filename.startswith("merge_log"):
            with open(os.path.join(RESULT_FOLDER, filename), 'r') as file:
                print(f"Reading {filename}")
                prg = re.match(prg_re, filename).group(1)
                i = prog.index(prg)
                for line in file.readlines():
                    line = line.strip("INFO:merge class files:")
                    for c in CATEGORY.keys():
                        if line.startswith(c):
                            results[CATEGORY[c]][i] = int(line.split(":")[1].strip())
                            break



if __name__ == "__main__":
    read_merge_log_files()
    x = []

    initCalls = pickle.load(open(os.path.join(RESULT_FOLDER, "initializer_calls.pickle"), "rb"))
    for stri in ("#init", "#insrt"):
        results[stri] = [initCalls[p][stri] for p in prog]

    for k in results.keys():
        if k == "":
            results[k].append("Total")
            continue
        results[k].append(sum([results[k][i] for i in range(len(prog))])) 
    
    #for i in range(len(prog)+1):
    #    try:
    #        x.append(f"{int(results[CATEGORY['Unique classes in to_void:']][i]) / int(results['Total'][i]) * 100:.2f}%")
    #    except ValueError:
    #        x.append("-")
    #results["additional % to void"] = x

    for i in range(len(prog)+1):
        for val in ("#init", "#insrt"):
            results[val][i] = millify(results[val][i])

    UNITS = ["", "K"]
    for i in range(len(prog)+1):
        results["LoC"][i] = millify(results["LoC"][i], UNITS)

    latex = tabulate.tabulate(results, headers='keys', tablefmt="latex")
    with open(os.path.join(RESULT_FOLDER, "classes_table.tex"), "w") as f:
        f.write(latex)
    print(latex)
    results = tabulate.tabulate(results, headers='keys', tablefmt="pretty")
    print(results)
    
