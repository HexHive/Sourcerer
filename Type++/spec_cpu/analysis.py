#!/usr/bin/env python3
import argparse
import os
from os import path
from pprint import pprint
from dotenv import load_dotenv
import subprocess
import shutil
from pathlib import Path
from distutils.dir_util import copy_tree


def choose_benchmark(benchmark, program):
    if benchmark == "cpu2006":
        benchmark_home = path.expanduser(CPU2006_FOLDER)
        run_cmd = "runspec --config=SPECCPU.cfg"
        programs = "444.named 447.dealII 450.soplex 453.povray 471.omnetpp 473.astar 483.xalancbmk".split(" ")
        if program and sublist(programs, program):
            programs = program
        elif program:
            print("Wrong value for program")
            exit(1)
    elif benchmark == "cpu2017":
        benchmark_home = path.expanduser(CPU2017_FOLDER)
        run_cmd = "runcpu --config=SPECCPU.cfg"
        programs = "507.cactuBSSN_r 508.namd_r 510.parest_r 511.povray_r 526.blender_r 520.omnetpp_r 523.xalancbmk_r 531.deepsjeng_r 541.leela_r".split(
            " "
        )  # # -s 502.gcc_r  505.mcf_r 525.x264_r 548.exchange2_r 557.xz_r 503.bwaves_r 519.lbm_r 521.wrf_r 527.cam4_r 538.imagick_r 544.nab_r 549.fotonik3d_r 554.roms_r
        if program and sublist(programs, program):
            programs = program
        elif program:
            print("Wrong value for program")
            exit(1)
    else:
        print("Wrong value for benchmark")
        exit(1)
    return benchmark_home, run_cmd, programs


def anal_flag(build_dir):
    plugin_path = path.join(*[build_dir, "lib", "TypeXXCodeChecker.so"])
    # plugin_path = path.join(*[llvm_home, "build", "lib", "SampleAnalyzerPlugin.so"])
    return (
        " -Xclang -load"
        + " -Xclang "
        + plugin_path
        + " -Xclang -plugin -Xclang typexx-codecheck"
        + " -fsyntax-only"
        + " -Wuninitialized "
    )


def choose_target(llvm_home):

    build_dir = path.join(*[llvm_home, "build"])
    additional_CXXOPTIMIZE = (
        " -Wno-uninitialized"
        + " -Wno-return-type-c-linkage"
        + " -Wno-string-plus-int"
        + " -Wno-delete-non-abstract-non-virtual-dtor"
        + " -fsanitize=typeplus"
        + " -mllvm -create-derived-cast-type-list"
        + " -mllvm -create-unrelated-cast-type-list"
        + " -mllvm -collect-profiling-data "
        # + " -mllvm -check-unrelated-casting"
        # + " -mllvm -check-base-to-derived-casting"
        # + " -mllvm -apply-vtable-standard"
        # + " -mllvm -cast-obj-opt "
    )
    build_dir = os.environ.get("BUILD_FOLDER", "")

    return build_dir, additional_CXXOPTIMIZE


def get_default_CXXOPTIMIZE(benchmark):

    default_CXXOPTIMIZE = None

    if benchmark.startswith("cpu"):
        default_CXXOPTIMIZE = (
            '"'
            + " -O2"
            + " -stdlib=libc++"
            + " -nostdinc++"
            + " -Wno-c++11-narrowing"
            + " -Wno-unused-command-line-argument"
            + " -Wno-shift-negative-value"
            + " -Wno-c++11-narrowing"
            + " -Wno-return-stack-address"
            + " -Wno-null-dereference"
            + " -Wno-dangling-else"
            + " -Wno-unused-comparison"
            + " -Wno-empty-body"
            + " -Wno-deprecated"
            + " -Wno-deprecated-register"
            + " -Wno-deprecated-declarations"
            + " -flto"
            + " -fvisibility=hidden"
            + " -fno-inline-functions"
            + " -fno-strict-aliasing"
            + " -std=c++03 "
        )

    return default_CXXOPTIMIZE


def sublist(test_list, sub_list):
    return all(x in test_list for x in sub_list)


def copy_configs():
    # copy config files
    config_home = path.join(*[typeplusplus_home, "spec_cpu", "config"])
    copy_tree(config_home, path.join(benchmark_home, "config"))


def process_result(benchmark, program):

    # I may start this without result folder
    if not RESULT_FOLDER or not os.path.isdir(RESULT_FOLDER):
        return

    warning_file_p2 = os.path.join(TYPEPLUS_LOG_PATH, "warning_logfile_p2.txt")
    if os.path.isfile(warning_file_p2):
        warning_file_p2_dest = os.path.join(RESULT_FOLDER, f"warning_logfile_{benchmark}_{program}_p2.txt")
        os.rename(warning_file_p2, warning_file_p2_dest)

    warning_file_p1 = os.path.join(TYPEPLUS_LOG_PATH, "warning_logfile_p1.txt")
    if os.path.isfile(warning_file_p1):
        warning_file_p1_dest = os.path.join(RESULT_FOLDER, f"warning_logfile_{benchmark}_{program}_p1.txt")
        os.rename(warning_file_p1, warning_file_p1_dest)


def run_command(command):

    # sometime command might be None if the benchmark does not consider that action
    if command is None:
        return

    bash = "/bin/bash -c '"
    # source SPEC CPU shrc
    load_spec = ""
    if "cpu" in args.benchmark:
        os.chdir(benchmark_home)
        load_spec = "source " + path.join(benchmark_home, "shrc") + " && "

    proc = subprocess.Popen(
        bash + load_spec + command + "'", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    error = False
    if args.verbose:
        while True:
            line = proc.stdout.readline()
            if not line:
                break
            decoded = line.decode("utf-8")
            if "*** Error building " in decoded:
                error = True
            print(decoded , end="")
            # print(line.decode(), end="")

    proc.wait()

    # if error:
    #     print("in run_command")
    #     from IPython import embed; embed(); exit(1)
    
    return error


def set_environ(log_path):
    print(f"{log_path=}")
    try:
        shutil.rmtree(log_path)
    except FileNotFoundError:
        pass
    os.makedirs(log_path, exist_ok=True)
    target_type_list_path = path.join(log_path, "merged.txt")
    warning_log_path = path.join(log_path, "warning_logfile.txt")
    Path(target_type_list_path).touch()
    Path(warning_log_path).touch()
    os.environ["TYPEPLUS_LOG_PATH"] = log_path
    os.environ["TARGET_TYPE_LIST_PATH"] = target_type_list_path
    os.environ["WARNING_LOG_PATH"] = warning_log_path

    return target_type_list_path


def set_spec_defines(vars):
    defines = ""
    for k, v in vars.items():
        defines += " --define " + k + "=" + v
    return defines


def merge_target_classes(log_path, target_path):

    shutil.copyfile(
        path.join(TEMP_FOLDER, "libc/libc++/merged.txt"), path.join(log_path, "casting_obj_init_libc++.txt")
    )
    shutil.copyfile(
        path.join(TEMP_FOLDER, "libc/libc++abi/merged.txt"), path.join(log_path, "casting_obj_init_libc++abi.txt")
    )
    merge_script = path.join(typeplusplus_home, "script/merge_typecasting_related_type.py")
    subprocess.call(merge_script + " " + log_path + " > " + target_path, shell=True)


def set_base_config(vars):
    if args.benchmark == "cpu2006":
        vars["BASE_CFG"] = "base_2006.cfg"
    else:
        vars["BASE_CFG"] = "base_2017.cfg"


def default_lib():
    return (
        " -Wl,-rpath,"
        + path.join(build_dir, "lib")
        + " -L"
        + path.join(build_dir, "lib")
        + " -I"
        + path.join(build_dir, "include/c++/v1")
        + '"'
    )


def vtype_lib(add_analysis=False):
    lib_build_folder = ""
    if(True):
        lib_build_folder = "-for-program"
    some_flags = (
        " -Wl,-rpath,"
        + path.join(build_dir, "..", "libcxxabi-build" + lib_build_folder + "/lib")
        + "          -L"
        + path.join(build_dir, "..", "libcxxabi-build" + lib_build_folder + "/lib")
        + " -Wl,-rpath,"
        + path.join(build_dir, "..", "libunwind-build" + lib_build_folder + "/lib")
        + "          -L"
        + path.join(build_dir, "..", "libunwind-build" + lib_build_folder + "/lib")
        + "          -I"
        + path.join(build_dir,  "include/c++/v1")
        + " -Wl,-rpath,"
           + path.join(build_dir, "..", "libcxx-build" + lib_build_folder + "/lib")
        + "          -L"
           + path.join(build_dir, "..", "libcxx-build" + lib_build_folder + "/lib")
    )

    if add_analysis:
        some_flags += anal_flag(build_dir)

    return some_flags + '"'


def get_clean_cmd(run_cmd, program, comp_vars):

    clean = None
    if args.benchmark.startswith("cpu"):
        defines = set_spec_defines(comp_vars)
        clean = run_cmd + " --action=clean " + program + defines
    else:
        print("benchmark not found, exit")
        exit(1)

    return clean


def get_build_cmd(run_cmd, program, comp_vars):

    build = None
    if args.benchmark.startswith("cpu"):
        defines = set_spec_defines(comp_vars)
        build = run_cmd + " --action=build " + program + defines
    else:
        print("benchmark not found, exit")
        exit(1)

    return build


def get_rebuild_cmd(run_cmd, program, comp_vars):

    rebuild = None
    if args.benchmark.startswith("cpu"):
        defines = set_spec_defines(comp_vars)
        rebuild = run_cmd + " --action=build --rebuild " + program + defines
    else:
        print("benchmark not found, exit")
        exit(1)

    return rebuild


def vtype_pre_build(program, comp_vars):
    build = get_build_cmd(run_cmd, program, comp_vars)
    # print("run build")
    # print(build)
    run_command(build)
    # print("run build")

    merge_target_classes(TYPEPLUS_LOG_PATH, target_type_list_path)

    # build libs
    os.chdir(llvm_home)
    subprocess.check_output(["./cxx_build_for_program.sh"] + [" debug" if args.debug else ""])


def clean_warning_putput(warning_new_name, hide_merged=False):

    Path(f"{TYPEPLUS_LOG_PATH}/warning_logfile.txt").touch()
    subprocess.call(f"mv {TYPEPLUS_LOG_PATH}/warning_logfile.txt {TYPEPLUS_LOG_PATH}/{warning_new_name}", shell=True)

    if hide_merged:
        subprocess.call(f"mv {TYPEPLUS_LOG_PATH}/merged.txt {TYPEPLUS_LOG_PATH}/merged_deleted.txt", shell=True)
    else:
        subprocess.call(f"mv {TYPEPLUS_LOG_PATH}/merged_deleted.txt {TYPEPLUS_LOG_PATH}/merged.txt", shell=True)

    # subprocess.call

def get_env_dir(name: str):
    dir = os.environ.get(name, "")
    if not path.isdir(dir):
        print(f"{name} is not set or incorrect. Aborting.\n{dir=}")
        exit(-1)
    return path.abspath(dir)


parser = argparse.ArgumentParser("simple_example")
parser.add_argument(
    "-benchmark",
    "-b",
    help="Benchmark name: cpu2006, cpu2017",
    type=str,
    choices=["cpu2006", "cpu2017"],
    required=True,
)
# parser.add_argument("-target", "-t", help="Evaluation target: baseline, cfi, vtype", type=str, choices=["baseline", "cfi", "vtype"], required=True)
parser.add_argument("-stats", "-s", help="Profiling vtype", action="store_true", default=False)
parser.add_argument("-program", "-p", help="Sub-benchmarking", nargs="*")
parser.add_argument("-debug", "-d", help="Debug build", action="store_true", default=False)
parser.add_argument("-verbose", "-v", help="Print SPEC info", default=False, action="store_true")
# parser.add_argument("-iterations", "-i", help="Number of iterations", default=10, type=int)
args = parser.parse_args()

ENVIRONMENT_FOLDER = os.environ.get("ENVIRONMENT_FOLDER")
env_patch_str = "environment_patched.sh"
if not ENVIRONMENT_FOLDER or not os.path.isfile(os.path.join(ENVIRONMENT_FOLDER, env_patch_str)):
    print(f"ENVIRONMENT_FOLDER is not set or incorrect. Aborting.\n{ENVIRONMENT_FOLDER=}")
    exit(255)
TYPESAFETY_FOLDER = path.join(path.dirname(os.path.realpath(__file__)), os.pardir)

load_dotenv(path.join(ENVIRONMENT_FOLDER, env_patch_str))
CPU2006_FOLDER = get_env_dir("CPU2006_FOLDER")
CPU2017_FOLDER = get_env_dir("CPU2017_FOLDER")
TEMP_FOLDER =   get_env_dir("TEMP_FOLDER")
RESULT_FOLDER = get_env_dir("RESULT_FOLDER")

benchmark_home, run_cmd, programs = choose_benchmark(args.benchmark, args.program)

typeplusplus_home = path.expanduser(TYPESAFETY_FOLDER)
llvm_home = path.join(typeplusplus_home, "..")
load_dotenv(path.join(ENVIRONMENT_FOLDER, env_patch_str))

CXXOPTIMIZE = get_default_CXXOPTIMIZE(args.benchmark)
if args.debug:
    CXXOPTIMIZE += " -g -O0 "

build_dir, target_CXXOPTIMIZE = choose_target(llvm_home)
CXXOPTIMIZE += target_CXXOPTIMIZE

# if args.stats:

SPEC_VARS = {}
SPEC_VARS["CLANG_BUILD_DIR"] = build_dir
SPEC_VARS["build_ncpus"] = str(os.cpu_count())

print(f'{SPEC_VARS["CLANG_BUILD_DIR"]=}')

copy_configs()
set_base_config(SPEC_VARS)


# Create the target list
for PROGRAM in programs:
    print(PROGRAM)

    TYPEPLUS_LOG_PATH = path.join(*[TEMP_FOLDER, args.benchmark, PROGRAM])

    target_type_list_path = set_environ(TYPEPLUS_LOG_PATH)
    SPEC_VARS["CXXOPTIMIZE"] = CXXOPTIMIZE + default_lib()

    SPEC_VARS["COPTIMIZE"] = '""' # needed by blender
    # clean = run_cmd + " --action=clean " + PROGRAM + defines
    clean = get_clean_cmd(run_cmd, PROGRAM, SPEC_VARS)
    run_command(clean)

    vtype_pre_build(PROGRAM, SPEC_VARS)

    SPEC_VARS["CXXOPTIMIZE"] = CXXOPTIMIZE + vtype_lib()
    SPEC_VARS["COPTIMIZE"] = "-DIS_TYPEXX" # needed by blender and cactuBSSN
    # update define
    # defines = set_spec_defines(SPEC_VARS)
    # rebuild = run_cmd + " --action=build --rebuild " + PROGRAM + defines
    rebuild = get_rebuild_cmd(run_cmd, PROGRAM, SPEC_VARS)
    run_command(rebuild)
    # print("ERROR")
    # from IPython import embed; embed(); exit(1)
    # exit(1)
    # print("BUILD WENT SMOOTH")
    # print(rebuild)
    # exit(1)

    ## ANALYSIS WITH P2
    SPEC_VARS["COPTIMIZE"] = '"-DIS_TYPEXX"' # needed by blender
    SPEC_VARS["CXXOPTIMIZE"] = CXXOPTIMIZE + vtype_lib(True)
    # defines = set_spec_defines(SPEC_VARS)
    # rebuild = run_cmd + " --action=build --rebuild " + PROGRAM + defines
    # print(rebuild)
    rebuild = get_rebuild_cmd(run_cmd, PROGRAM, SPEC_VARS)
    run_command(rebuild)
    # print("ANALYSIS DONE")
    # print(rebuild)
    # exit(1)
    

    # call log file for p2 (optimized)
    clean_warning_putput("warning_logfile_p2.txt", True)

    ## ANALYSIS WITH P1
    SPEC_VARS["COPTIMIZE"] = '"-DIS_TYPEXX"' # needed by blender
    SPEC_VARS["CXXOPTIMIZE"] = CXXOPTIMIZE + vtype_lib(True)
    # defines = set_spec_defines(SPEC_VARS)
    # rebuild = run_cmd + " --action=build --rebuild " + PROGRAM + defines
    rebuild = get_rebuild_cmd(run_cmd, PROGRAM, SPEC_VARS)
    run_command(rebuild)

    # call log file for p1 (non optimized)
    clean_warning_putput("warning_logfile_p1.txt", False)

    process_result(args.benchmark, PROGRAM)
