#!/usr/bin/env python3

import os, sys, io, glob
from subprocess import Popen, PIPE
from dotenv import load_dotenv

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

# path to ignore

LOC_STATS = "loc_stats.txt"
WARNING = "warning_logfile"

OUTPUT_FILE = os.path.join(RESULT_PATH, "analysis_result_test.tex")

PROG_STRING={
    "444.named": "NAMD", 
    "447.dealII": "deal.II", 
    "450.soplex": "SoPlex", 
    "453.povray": "POV-Ray", 
    "471.omnetpp": "OMNeT++", 
    "473.astar": "Astar", 
    "483.xalancbmk": "Xalan-C++", 
    "507.cactuBSSN_r": "CactuBSSN", 
    "508.namd_r": "NAMD", 
    "510.parest_r": "Parest", 
    "511.povray_r": "POV-Ray", 
    "526.blender_r": "Blender", 
    "520.omnetpp_r": "OMNeT++", 
    "523.xalancbmk_r": "Xalan-C++", 
    "531.deepsjeng_r": "Deep Sjeng", 
    "541.leela_r": "Leela",
    "sum": "Sum",
}

class AnalysisRecord:
    def __init__(self):
        self.name_benchmark = ""
        self.name_program = ""

        self.tot_loc = 0

        self.tot_charcast_p1 = 0
        self.tot_phantomcast_p1 = 0
        self.tot_sizeof_p1 = 0
        self.tot_uninit_p1 = 0

        self.tot_charcast_p2 = 0
        self.tot_phantomcast_p2 = 0
        self.tot_sizeof_p2 = 0
        self.tot_uninit_p2 = 0

    def __str__(self):
        r = []
        r += ["{: >10,}".format(self.tot_loc)]

        r += ["{: >6,}".format(self.tot_charcast_p1)    + "/" + "{: <3,}".format(self.tot_charcast_p2)]
        r += ["{: >6,}".format(self.tot_phantomcast_p1) + "/" + "{: <3,}".format(self.tot_phantomcast_p2)]
        r += ["{: >6,}".format(self.tot_sizeof_p1)      + "/" + "{: <3,}".format(self.tot_sizeof_p2)]
        r += ["{: >6,}".format(self.tot_uninit_p1)      + "/" + "{: <3,}".format(self.tot_uninit_p2)]

        my_strings = self.name_benchmark.replace("SPEC_", "").rjust(11, " ") + "& " + PROG_STRING[self.name_program].rjust(10, " ")

        # numbers = "|".join([str(x) for x in r])
        # print(r)
        # exit()
        numbers = " & ".join(r)

        return my_strings + " & " + numbers

    def get_header():
        # a = AnalysisRecord()
        # rec = "|".join(list(a.__dict__.keys()))
        return " & ".join([x.rjust(10, " ") for x in ["bench", "program", "lines", "char cast", "phant.cast", "sizeof", "uninit"]])


FINALY_SUM = AnalysisRecord()


def emitRecord(rec):
    global OUTPUT_FILE

    with open(OUTPUT_FILE, "a") as f:
        f.write(str(rec) + "\n")


def createNewAnalysisFile():
    global FINALY_SUM

    rec = AnalysisRecord.get_header()
    with open(OUTPUT_FILE, "w") as f:
        f.write(rec + "\n")

    FINALY_SUM.name_benchmark = "-"
    FINALY_SUM.name_program = "sum"


def getLocFiles(program):
    global LOC_STATS

    loc = 0
    files = 0
    try:
        with open(os.path.join(RESULT_PATH, program, LOC_STATS), "r") as f:
            for l in f:
                l = l.strip()
                if "LoC" in l:
                    loc = int(l.split("|")[-1])
                if "files" in l:
                    files = int(l.split("|")[-1])
    except FileNotFoundError:
        return -1, -1

    return loc, files


def getWarningStats(program, cpu, postfix):
    global LOC_STATS
    global TYPESAFETY_FOLDER

    charcast = set()
    phantomcast = set()
    sizeof = set()
    uninit = set()
    
    warning_file = os.path.join(RESULT_PATH, f"{WARNING}_{cpu}_{program}.txt")
    try:
        with open(warning_file, "r") as f:
            for l in f:

                # do not count warnings from libc++ libc++abi
                if os.environ.get("BUILD_FOLDER") in l:
                    continue

                l = l.strip().split("|")

                if l[1] == "sizeof":
                    s = "|".join(l)
                    sizeof.add(s)

                if l[1] == "phantomcast":
                    s = "|".join(l)
                    phantomcast.add(s)

                if l[1] == "reinterpret_cast":
                    s = "|".join(l)
                    charcast.add(s)

                if l[1] == "uninitobj":
                    s = "|".join(l)
                    uninit.add(s)
    except FileNotFoundError:
        print(f"Warning file not found for {program} {cpu}: {warning_file}")
        raise

    return len(charcast), len(phantomcast), len(sizeof), len(uninit)


def findLocSpecCPU(programs, benchmark):
    for prg in programs:
        rec = AnalysisRecord()

        # program info
        rec.name_benchmark =  "SPEC_" + str.upper(benchmark)
        rec.name_program = prg

        # get loc stats
        try:
            loc, files = getLocFiles(prg)
            rec.tot_loc = loc
        except:
            print(f"Loc file not found for {prg} {benchmark}")

        # get warning p1 stat
        try:
            tot_charcast_p1, tot_phantomcast_p1, tot_sizeof_p1, tot_uninit_p1 = getWarningStats(prg, benchmark, "p1")
            rec.tot_charcast_p1 = tot_charcast_p1
            rec.tot_phantomcast_p1 = tot_phantomcast_p1
            rec.tot_sizeof_p1 = tot_sizeof_p1
            rec.tot_uninit_p1 = tot_uninit_p1
        except FileNotFoundError:
            pass

        emitRecord(rec)
        updateSum(rec)


def updateSum(rec):
    global FINALY_SUM

    FINALY_SUM.tot_loc += rec.tot_loc

    FINALY_SUM.tot_charcast_p1 += rec.tot_charcast_p1
    FINALY_SUM.tot_phantomcast_p1 += rec.tot_phantomcast_p1
    FINALY_SUM.tot_sizeof_p1 += rec.tot_sizeof_p1
    FINALY_SUM.tot_uninit_p1 += rec.tot_uninit_p1

    FINALY_SUM.tot_charcast_p2 += rec.tot_charcast_p2
    FINALY_SUM.tot_phantomcast_p2 += rec.tot_phantomcast_p2
    FINALY_SUM.tot_sizeof_p2 += rec.tot_sizeof_p2
    FINALY_SUM.tot_uninit_p2 += rec.tot_uninit_p2


if __name__ == "__main__":
    createNewAnalysisFile()
    findLocSpecCPU(SPECCPU2006_PROGRAMS, "cpu2006")
    findLocSpecCPU(SPECCPU2017_PROGRAMS, "cpu2017")
    emitRecord(FINALY_SUM)
