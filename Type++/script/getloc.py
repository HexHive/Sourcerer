#!/usr/bin/env python3

import os, io, glob
from subprocess import Popen, PIPE
from dotenv import load_dotenv
from multiprocessing import Pool

ENVIRONMENT_FOLDER = os.environ.get("ENVIRONMENT_FOLDER")
env_patch_str = "environment_patched.sh"
if not ENVIRONMENT_FOLDER or not os.path.isfile(os.path.join(ENVIRONMENT_FOLDER, env_patch_str)):
    print(f"ENVIRONMENT_FOLDER is not set or incorrect. Aborting.\n{ENVIRONMENT_FOLDER=}")
    exit(255)
TYPESAFETY_FOLDER = os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir)

load_dotenv(os.path.join(ENVIRONMENT_FOLDER, env_patch_str))
CPU2006_FOLDER = os.environ.get("CPU2006_FOLDER")
CPU2017_FOLDER = os.environ.get("CPU2017_FOLDER")
TEMP_FOLDER = os.environ.get("TEMP_FOLDER")
RESULT_PATH =  os.environ.get("RESULT_FOLDER") #os.path.join(TEMP_FOLDER, "cpu2006/")

# some ugly global consts for configuration

# SPEC CPU 2006 PATHS
SPECCPU2006_PATH = os.path.join(CPU2006_FOLDER, "benchspec/CPU2006/")
SPECCPU2006_PROGRAMS = "444.named 447.dealII 450.soplex 453.povray 471.omnetpp 473.astar 483.xalancbmk".split()

# SPEC CPU 2017 PATHS
SPECCPU2017_PATH = os.path.join(CPU2017_FOLDER, "benchspec/CPU/")
SPECCPU2017_PROGRAMS = "507.cactuBSSN_r 508.namd_r 510.parest_r 511.povray_r 526.blender_r 520.omnetpp_r 523.xalancbmk_r 531.deepsjeng_r 541.leela_r".split()


def getCloc(program_folder):
    proc = Popen(["cloc", program_folder], stdout=PIPE, stderr=PIPE)

    outs, errs = proc.communicate()
    rc = proc.returncode

    outs_str = None

    if rc == 0:
        outs_str = outs.decode("utf-8")
        # print(outs_str)
    else:
        print(f"Errors: {errs}")
        print(f"Program folder: {program_folder}")
        exit(-1)

    if outs_str is None:
        print("Error, outs_str is None but cloc didn't return an error")
        print(f"Program folder: {program_folder}")
        exit(-1)

    # print("my parser!")

    loc = 0
    files = 0

    stri = io.StringIO(outs_str)
    nl = stri.readline()
    while nl:
        this_one = False
        nl = stri.readline()
        nl_clean = nl.strip()

        if nl_clean.startswith("C/C++ Header"):
            nl_clean = nl_clean.replace("Header", "")
            this_one = True

        if nl_clean.startswith("C++"):
            this_one = True

        if this_one:
            loc += int(nl_clean.split()[-1])
            files += int(nl_clean.split()[1])

        # print(nl_clean)

    return loc, files


def dumpLocs(cloc_output, loc, files):
    os.makedirs(os.path.dirname(cloc_output), exist_ok=True)
    with open(cloc_output, "w+") as f:
        f.write(f"LoC|{loc}\n")
        f.write(f"files|{files}\n")


def findLocSpecCPU2006(prg):
    global SPECCPU2006_PROGRAMS
    global SPECCPU2006_PATH
    global CLOC2006_OUTPUT_PATH

    program_path = os.path.join(SPECCPU2006_PATH, prg)
    cloc_output = os.path.join(RESULT_PATH, prg, "loc_stats.txt")

    print(f"doing: {program_path}")

    loc, files = getCloc(program_path.replace("named", "namd"))
    dumpLocs(cloc_output, loc, files)

    with open(cloc_output, "w") as f:
        f.write(f"LoC|{loc}\n")
        f.write(f"files|{files}\n")


def findLocSpecCPU2017(prg):
    global SPECCPU2017_PROGRAMS
    global SPECCPU2017_PATH
    global CLOC2017_OUTPUT_PATH

    program_path = os.path.join(SPECCPU2017_PATH, prg)
    cloc_output = os.path.join(RESULT_PATH, prg, "loc_stats.txt")

    print(f"doing: {program_path}")

    loc, files = getCloc(program_path)
    dumpLocs(cloc_output, loc, files)

    with open(cloc_output, "w") as f:
        f.write(f"LoC|{loc}\n")
        f.write(f"files|{files}\n")


if __name__ == "__main__":
    pool = Pool()
    pool.map(findLocSpecCPU2006, SPECCPU2006_PROGRAMS)
    pool.map(findLocSpecCPU2017, SPECCPU2017_PROGRAMS)
