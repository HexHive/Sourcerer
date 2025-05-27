#!/usr/bin/env python3

import os, sys, io, glob, math, pickle
from subprocess import Popen, PIPE
from tabulate import tabulate
from termcolor import colored
from prettytable import PrettyTable
from dotenv import load_dotenv

from infra import overhead, get_avg, millify, prog_names

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


TARGET = ["bsl", "bsl_typepp", "cfi", "typepp", "srcer" ]
ABLATION_TARGET = ["ablation_baseline", "ablation_sourcerer", "ablation_sourcerer_no_check", "ablation_sourcerer_abi_only"]
CAST_TARGET = TARGET[2:]
RUNTIME_PERFORMANCE = "runtime_performance.csv"
CASTING_STATS = "total_result_*"


CAST_CATEGORIES = [
    "numCastTot",
    "numCastUnrl",
    "numCastUnrlMiss",
    "numCastUnrlBad",
    "numCastUnrlTot",
    "numCastUnrlHandled",
    "numCastDrvd",
    "numCastDrvdMiss",
    "numCastDrvdBad",
    "numCastDrvdTot",
    "numCastDrvdHandled",
]



class AnalysisRecord:
    def __init__(self):
        self.name_benchmark = ""
        self.name_program = ""
        
        self.targets = {}
        self.avgs = {}
        for trg in TARGET:
            self.targets[trg] = []
            self.avgs[trg] = 0
        for trg in ABLATION_TARGET:
            self.targets[trg] = []
            self.avgs[trg] = 0

        self.casts = {}
        self.calls = {'srcer': {"constructor": 0, "insertor": 0}}

        self.ablation_nocheck = {}
        self.ablation_rtti_only = {}

        for trg in CAST_TARGET:
            self.casts[trg] = {}
            for x in CAST_CATEGORIES:
                self.casts[trg][x] = 0

    def has_cast(self):
        tot_cast = 0
        for trg in CAST_TARGET:
            for x in CAST_CATEGORIES:
                tot_cast += self.casts[trg][x]
        return tot_cast != 0
    
    def cast_diff(self, top, bototm):
        ret = []
        for i, cast_type in enumerate(["numCastDrvd", "numCastUnrl"]):
            diff = self.casts[top][cast_type] - self.casts[bototm][cast_type]
            ret.append(millify(diff) if diff >= 0 else colored(millify(diff), "red"))
        return tuple(ret)
    
    def did_typexx_work(self):
        if len(self.targets["srcer"]) == 0:
            self.targets["srcer"] = [-1]
            return False
        if not min(self.targets["srcer"]) > 10:
            self.targets["srcer"] = [-1]
            return False
        return True
    
    def avg(self):
        self.avgs = {}
        for trg in TARGET:
            self.avgs[trg] = get_avg(self.targets[trg])
        for trg in ABLATION_TARGET:
            self.avgs[trg] = get_avg(self.targets[trg])
        return self.avgs


    def to_array_per(self):
        r = {}

        self.avgs = self.avg()


        for trg in TARGET:
            r[trg + " [s]"] = colored("ERR", "red") if self.targets[trg] == [] else sum(self.targets[trg]) / len(self.targets[trg])
            if trg != "bsl" and trg != "bsl_typepp":
                r[trg + " %"] = overhead(self.avgs[trg], self.avgs["bsl"])

        perc = 0
        if self.targets["cfi"] != [] and self.targets["srcer"] != [] and "ERR" not in self.targets["srcer"]:
            perc = overhead(self.avgs["srcer"], self.avgs["cfi"])

        r["srcer over cfi %"] = perc

        return r

    def to_array_cov(self):
        r = {}

        r["program"] = self.name_program

        for trg in CAST_TARGET:
            for x in CAST_CATEGORIES:
                n = self.casts[trg][x]
                r[trg[0] + x.replace("numCast", "")] = millify(n)

        return r

    def to_array_paper(self):
        # ["program", "(%)", "#cast", "#miss", "#cast", "#miss", "(%)", "#cast", "#miss", "#cast", "#miss", "X #cast", "X #miss"]
        r = {}

        self.avgs = self.avg()

        r[" "] =""
        r["program"] = prog_names[self.name_program]

        for trg in TARGET:
            # include raw numbers
            #r[trg + " [s]"] = colored("ERR", "red") if self.targets[trg] == [] else "{:.2f}".format(sum(self.targets[trg]) / len(self.targets[trg]))
            if trg != "bsl" and trg != "bsl_typepp":
                if trg == "typepp":
                    # different baseline
                    r[trg + " %"] = overhead(self.avgs[trg], self.avgs["bsl_typepp"])
                else:
                    r[trg + " %"] = overhead(self.avgs[trg], self.avgs["bsl"])
            if trg in CAST_TARGET:
                #r["#" + trg[0] + "drvd"] = millify(self.casts[trg]["numCastDrvd"])
                #r["#" + trg[0] + "unrl"] = millify(self.casts[trg]["numCastUnrl"])

                if trg == "srcer":
                    r["#" + trg[0]] = millify(self.casts[trg]["numCastUnrlTot"])
                else:
                    r["#" + trg[0]] = millify(self.casts[trg]["numCastUnrl"])

        perc = colored("ERR", "red")
        #if self.targets["cfi"] != [] and self.targets["srcer"] != [] and "ERR" not in self.targets["srcer"]:
        #    perc = overhead(self.avgs["srcer"], self.avgs["cfi"])

        #r["srcer/cfi %"] = perc

        delta_unrl, delta_drvd = self.cast_diff("srcer", "typepp")
        r["#diff cfi"] = millify(self.casts["srcer"]["numCastUnrlTot"] - self.casts["cfi"]["numCastUnrl"])
        r["#diff"] = millify(self.casts["srcer"]["numCastUnrlTot"] - self.casts["typepp"]["numCastUnrl"])

        try:
            with open(os.path.join(RESULT_FOLDER, "memory_overhead.pickle"), "rb") as mem_file:
                mem = pickle.load(mem_file)
                r["mem avg"] = mem[self.name_program]["avg_srcer_overhead"]
                r["mem max"] = mem[self.name_program]["max_srcer_overhead"]
                r["mem avg"] = r["mem avg"] if r["mem avg"] < 15 else colored(r["mem avg"], "red")
                r["mem max"] = r["mem max"] if r["mem max"] < 15 else colored(r["mem max"], "red")
        except (FileNotFoundError, KeyError):
            r["mem avg"] = colored("Na", "red")
            r["mem max"] = colored("Na", "red")

        return r

    def pickleCalls(self):
        init = self.calls["srcer"]["constructor"] + self.calls["srcer"]["insertor"]
        initializerCalls = {}
        initializerCalls["#init"] = init
        initializerCalls["#insrt"]  = self.calls["srcer"]["insertor"]
        #initializerCalls["#insrt"]  = "-" if init == 0 else round(self.calls["srcer"]["insertor"]/init * 100, 2)
        return initializerCalls

    def table3(self):
        r = {}

        self.avgs = self.avg()

        r[" "] =""
        r["program"] = self.name_program

        r["program"] = prog_names[self.name_program]

        for trg in ABLATION_TARGET:
            # include raw numbers
            #r[trg + " [s]"] = colored("ERR", "red") if self.targets[trg] == [] else "{:.2f}".format(sum(self.targets[trg]) / len(self.targets[trg]))
            if trg != "ablation_baseline":
                r[trg + " %"] = overhead(self.avgs[trg], self.avgs["ablation_baseline"])
        return r

    def __str__(self):
        r = self.to_array_per()

        return "\t".join(r)


PROGRAMS = {}
PROGRAMS["cpu2006"] = {
    k: AnalysisRecord()
    for k in "444.namd 447.dealII 450.soplex 453.povray 471.omnetpp 473.astar 483.xalancbmk".split(
        " "
    )
}
PROGRAMS["cpu2017"] = {
    k: AnalysisRecord()
    for k in "507.cactuBSSN_r 508.namd_r 510.parest_r 511.povray_r 526.blender_r 520.omnetpp_r 523.xalancbmk_r 531.deepsjeng_r 541.leela_r".split(
        " "
    )
}

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



def parseResult():
    RUNTIME_PERFORMANCE = "runtime_performance.csv"
    file_runtime_performance = os.path.join(RESULT_FOLDER, RUNTIME_PERFORMANCE)
    
    with open(file_runtime_performance, "r") as f:
        for l in f:
            l_arr = l.split("|")
            bnc = l_arr[0]
            prg = l_arr[1]
            trg = l_arr[2]
            if trg == "baseline":
                trg = "bsl"
            if trg == "sourcerer":
                trg = "srcer"
            if bnc not in PROGRAMS.keys():
                continue
            PROGRAMS[bnc][prg].name_benchmark = bnc
            PROGRAMS[bnc][prg].name_program = prg

            # cpu2017|508.namd_r|srcer|0|231.761718

            PROGRAMS[bnc][prg].targets[trg] += [float(l_arr[4])]
    
    RUNTIME_PERFORMANCE = "ablation_performance.csv"
    file_ablation_performance = os.path.join(RESULT_FOLDER, RUNTIME_PERFORMANCE)
    with open(file_ablation_performance, "r") as f:
        for l in f:
            l_arr = l.split("|")
            bnc = l_arr[0]
            prg = l_arr[1]
            trg = l_arr[2]
            if trg == "baseline":
                trg = "bsl"
            if trg == "sourcerer":
                trg = "srcer"
            if bnc not in PROGRAMS.keys():
                continue
            PROGRAMS[bnc][prg].name_benchmark = bnc
            PROGRAMS[bnc][prg].name_program = prg

            # cpu2017|508.namd_r|srcer|0|231.761718

            PROGRAMS[bnc][prg].targets[trg] += [float(l_arr[4])]
    
    

    for trg in CAST_TARGET:
        for bnc, programs in PROGRAMS.items():
            for prg, stats in programs.items():
                real_trg = trg
                if trg == "srcer":
                    real_trg = "sourcerer"
                total_result = os.path.join(RESULT_FOLDER, f"total_result_{real_trg}_{prg}.txt")

                # total_result_srcer_450.soplex.txt
                # == Casting verification status ==
                # Unrelated Casting: 0, Type_Confusion: 0, Missed: 0. Handled: 0
                # Derived Casting: 425454625, Type_Confusion: 9193, Missed: 80017. Handled: 425365415

                if os.path.isfile(total_result):
                    with open(total_result, "r") as f2:
                        for l2 in f2:
                            l2_arr = l2.split(", ")
                            if l2.startswith("Unrelated Casting:"):
                                PROGRAMS[bnc][prg].casts[trg]["numCastUnrlTot"] += int(
                                    l2_arr[0].replace("Unrelated Casting: ", "").strip()
                                )
                                PROGRAMS[bnc][prg].casts[trg]["numCastUnrlBad"] += int(
                                    l2_arr[1].replace("Type_Confusion: ", "").strip()
                                )
                                PROGRAMS[bnc][prg].casts[trg]["numCastUnrlMiss"] += int(
                                    l2_arr[2].replace("Missed: ", "").strip()
                                )
                                PROGRAMS[bnc][prg].casts[trg]["numCastUnrlHandled"] += int(
                                    l2_arr[3].replace("Handled: ", "").strip()
                                )
                                PROGRAMS[bnc][prg].casts[trg]["numCastUnrl"] = PROGRAMS[bnc][prg].casts[trg]["numCastUnrlHandled"] + PROGRAMS[bnc][prg].casts[trg]["numCastUnrlBad"] 
                                if trg == "srcer":
                                    PROGRAMS[bnc][prg].casts[trg]["numCastUnrl"] += PROGRAMS[bnc][prg].casts[trg]["numCastUnrlMiss"]
                            elif l2.startswith("Derived Casting:"):
                                PROGRAMS[bnc][prg].casts[trg]["numCastDrvdTot"] += int(
                                    l2_arr[0].replace("Derived Casting:", "").strip()
                                )
                                PROGRAMS[bnc][prg].casts[trg]["numCastDrvdBad"] += int(
                                    l2_arr[1].replace("Type_Confusion: ", "").strip()
                                )
                                PROGRAMS[bnc][prg].casts[trg]["numCastDrvdMiss"] += int(
                                    l2_arr[2].replace("Missed: ", "").strip()
                                )
                                PROGRAMS[bnc][prg].casts[trg]["numCastDrvdHandled"] += int(
                                    l2_arr[3].replace("Handled: ", "").strip()
                                )
                                PROGRAMS[bnc][prg].casts[trg]["numCastDrvd"] = PROGRAMS[bnc][prg].casts[trg]["numCastDrvdHandled"] + PROGRAMS[bnc][prg].casts[trg]["numCastDrvdBad"]
                                if trg == "srcer":
                                    PROGRAMS[bnc][prg].casts[trg]["numCastDrvd"] += PROGRAMS[bnc][prg].casts[trg]["numCastDrvdMiss"]
                            elif l2.startswith("VPTR through constructor:") and trg == "srcer":
                                PROGRAMS[bnc][prg].calls[trg]["constructor"] += int(
                                    l2_arr[0].replace("VPTR through constructor:", "").strip()
                                )
                            elif l2.startswith("Vptr Insertor Call:") and trg == "srcer":
                                PROGRAMS[bnc][prg].calls[trg]["insertor"] += int(
                                    l2_arr[0].replace("Vptr Insertor Call:", "").strip()
                                )
                        PROGRAMS[bnc][prg].casts[trg]["numCastTot"] += PROGRAMS[bnc][prg].casts[trg]["numCastDrvdTot"] + PROGRAMS[bnc][prg].casts[trg]["numCastUnrlTot"]
    

    table_per = []
    table_cov = []
    table_paper = []
    table3 = []

    avg_total = {}
    for trg in TARGET:
        avg_total[trg] = 0
    total_cast = {}
    for trg in CAST_TARGET:
        total_cast[trg] = 0


    pickleCalls = {}
    for benchmark, programs in PROGRAMS.items():
        # print(f"benchmark: {benchmark}")
        avg_benchmark = {}
        for trg in TARGET:
            avg_benchmark[trg] = 0

        for program, stats in programs.items():
            stats.did_typexx_work()

            if stats.name_program != "":
                stats.avg()
                for trg in TARGET:
                    avg_benchmark[trg] = stats.avgs[trg]
                table_per += [stats.to_array_per()]
                table_paper += [stats.to_array_paper()]
                table3 += [stats.table3()]

            if stats.has_cast():
                table_cov += [stats.to_array_cov()]
                for trg in CAST_TARGET:
                    total_cast[trg] +=  stats.casts[trg]["numCastUnrl"] #+ stats.casts[trg]["numCastDrvd"]
                
            
            pickleCalls[stats.name_program] = stats.pickleCalls()
            for trg in TARGET:
                avg_total[trg] += avg_benchmark[trg]


    pickle.dump(pickleCalls, open(os.path.join(RESULT_FOLDER, "initializer_calls.pickle"), "wb"))
    print("Avg accross all")
    print("cfi", overhead(avg_total["cfi"], avg_total["bsl"]))
    print("srcer", overhead(avg_total["srcer"], avg_total["bsl"]))
    print("Total cast")
    print("cfi", millify(total_cast["cfi"]))
    print("typepp", millify(total_cast["typepp"]))
    print("srcer", millify(total_cast["srcer"]))
    table_paper+=[
        {
            ' ': "",
            "program": "Avg./Total", 
            "cfi %": overhead(avg_total["cfi"], avg_total["bsl"]),
            "#c":millify(total_cast["cfi"]),
            "srcer %": overhead(avg_total["srcer"], avg_total["bsl"]),
            "#s":millify(total_cast["srcer"]),
            "typepp %": overhead(avg_total["typepp"], avg_total["bsl_typepp"]),
            "#t":millify(total_cast["typepp"]),
            "#diff cfi":millify(total_cast["srcer"] - total_cast["cfi"]),
            "#diff":millify(total_cast["srcer"] - total_cast["typepp"]),

            }
        ]
    print(table_paper[-1])
    print(tabulate(table_per, headers="keys", stralign="right", tablefmt="plain"))
    #print(tabulate(table_cov, headers="keys", stralign="right", tablefmt="plain"))

    print(
        tabulate(
            table_paper,
            headers="keys",
            stralign="right",
            tablefmt="latex",
            floatfmt=".2f",
        )
    )
    print(
        tabulate(
            table_paper,
            headers="keys",
            tablefmt="plain",
            floatfmt=".2f",
        )
    )
    print(
        tabulate(
            table3,
            headers="keys",
            stralign="right",
            tablefmt="latex",
            floatfmt=".2f",
        )
    )
if __name__ == "__main__":
    # createNewAnalysisFile()
    parseResult()
    # emitRecord(FINALY_SUM)
