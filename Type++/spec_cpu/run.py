#!/usr/bin/env python3
import argparse, glob, os, time
from os import path
from pprint import pprint
from dotenv import load_dotenv
import subprocess, shutil
from pathlib import Path
from distutils.dir_util import copy_tree
import logging
import time

logging.basicConfig(
    level=logging.WARN, format="%(asctime)s: %(levelname)s: %(message)s"
)
logging.getLogger("spec_run").setLevel(logging.DEBUG)
my_logger = logging.getLogger("spec_run")

CUSTOM_HEADERS={"453.povray": 0x38, "511.povray_r": 0x20, "523.xalancbmk_r": 0x0, "526.blender_r": 0x8}

def choose_benchmark(benchmark: str, program: str):
  """ Given the benchmark and the program(s) to run, set the necessary 
  variables

  Args:
      benchmark (str): _description_
      program (str): _description_

  Returns:
      (str, str, list(str)): the benchmark installed directory, the command to launch it, a list of programs to run
  """
  if benchmark == "cpu2006": 
    benchmark_home=path.expanduser(CPU2006_FOLDER)
    run_cmd = "runspec --config=SPECCPU.cfg"
    programs="444.namd 447.dealII 450.soplex 453.povray 471.omnetpp 473.astar 483.xalancbmk".split(" ") 
    if program and sublist(programs, program):
      programs = program
    elif program:
      my_logger.error("Wrong value for program: %s", " ".join(program))
      exit(1)
  elif benchmark == "cpu2017":
    benchmark_home=path.expanduser(CPU2017_FOLDER)
    run_cmd = "runcpu --config=SPECCPU.cfg"
    programs="507.cactuBSSN_r 508.namd_r 510.parest_r 511.povray_r 520.omnetpp_r 523.xalancbmk_r 526.blender_r 531.deepsjeng_r 541.leela_r".split(" ")  
    if program and sublist(programs, program):
      programs = program
    elif program:
      my_logger.error("Wrong value for program: %s", " ".join(program))
      exit(1)
  else:
    my_logger.error("Wrong value for benchmark: %s", benchmark)
    exit(1)
  if benchmark.startswith("cpu") and not path.exists(path.join(benchmark_home, "shrc")):
    my_logger.error("Benchmark not installed at the correct location. Expect: %s", benchmark_home)
    exit(1)
  return benchmark_home, run_cmd, programs


def choose_target(target, mode=None):
    """ Further specify variables for a specific mode of SPEC_CPU

    Args:
        target (str): the configuration to specialize for
        mode (str, optional): the mode of execution. Defaults to None.

    Returns:
        (str, str): the build directory of Type++ and the CXXFLAGS flags for
                    this specific configuration
    """

    build_dir = os.environ.get("BUILD_FOLDER", "")
    if args.clang_debug:
        build_dir = os.environ.get("DEBUG_BUILD_FOLDER", "")
    head, tail = os.path.split(build_dir)

    if target == "baseline":
        build_dir = path.join(*[head,  tail])
        additional_CXXOPTIMIZE = " "
    elif target == "cfi":
        if not args.stats:
            build_dir = path.join(*[head, tail])
        additional_CXXOPTIMIZE = (
            " -fsanitize=cfi-derived-cast "
            + " -fsanitize=cfi-unrelated-cast "
            + " -fno-sanitize-trap=cfi-derived-cast "
            + " -fno-sanitize-trap=cfi-unrelated-cast "
            + " -fsanitize-recover=all "
        )
    elif target == "sourcerer":
        additional_CXXOPTIMIZE = (" -fsanitize=typeplus")
        if mode == "collect":
            additional_CXXOPTIMIZE += (
                " -mllvm -create-derived-cast-type-list"
                + " -mllvm -create-unrelated-cast-type-list"
                + " -mllvm -create-void-star-type-list"
            )

        elif mode == "optimize":
            additional_CXXOPTIMIZE += (
                (" -mllvm -check-unrelated-casting" if not args.no_check else "")
                + (" -mllvm -check-base-to-derived-casting" if not args.no_check else "")
                + (" -mllvm -no-set-sourcerer-rtti" if args.no_insertor else "")
                + " -mllvm -apply-vtable-standard" 
                + " -mllvm -poly-classes "
                + " -mllvm -cast-obj-opt "
            )
    else:
        my_logger.error("Unsupported run configuration. Target: %s, version: %s", target, mode)
        exit(1)
    return build_dir, additional_CXXOPTIMIZE

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

def get_default_CXXOPTIMIZE(benchmark: str) -> str:
    """ Default CXXFLAGS used across all configuration

    Args:
        benchmark (str): benchmark it case it changes, for now cpu

    Returns:
        str: the CXXFLAGS
    """
    default_CXXOPTIMIZE = ""

    if benchmark.startswith("cpu"):
        default_CXXOPTIMIZE = ('"'
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
            + " -Wno-uninitialized"
            + " -Wno-return-type-c-linkage"
            + " -Wno-string-plus-int"
            + " -Wno-delete-non-abstract-non-virtual-dtor"
            + " -fdelayed-template-parsing" #https://github.com/llvm/llvm-project/issues/109966
            + " -flto"
            + " -fvisibility=hidden"
            + " -lunwind"
            + " -fno-sanitize-trap=all"
            + " -fno-inline-functions"
            + " -fno-strict-aliasing"
            + " -Wno-everything"
            + " -fuse-ld=lld"
            + " -std=c++03 "
            #+ " -fplugin=" + llvm_home + "build/lib/TypeXXCodeChecker.so" 
        )
    return default_CXXOPTIMIZE

def expected_deepsjeng_result(patch=False):
    if(args.benchmark != "cpu2017" and PROGRAM != "531.deepsjeng_r"):
        return

    deepsjeng_reuslt_file = path.join(benchmark_home, "benchspec", "CPU", "531.deepsjeng_r", "data", "refrate", "output", "ref.out")
    with open(deepsjeng_reuslt_file, "r") as f:
        lines = f.readlines()
    if patch:
        lines[1] = "Allocated 15000000 hash entries, totalling 840000000 bytes.\n"
    else: # original
        lines[1] = "Allocated 15000000 hash entries, totalling 720000000 bytes.\n"
    with open(deepsjeng_reuslt_file, "w") as f:
        f.writelines(lines)

    
def sublist(test_list, sub_list):
    return all(x in test_list for x in sub_list)


def copy_configs():
    """ Place the correct config files
    """
    config_home = path.join(*[typeplusplus_home, "spec_cpu", "config"])
    copy_tree(config_home, path.join(benchmark_home, "config"))

def is_exe(fpath):
    return os.path.isfile(fpath) and os.access(fpath, os.X_OK) and "imagevalidate" not in fpath

def process_result(benchmark, program, target, duration=0, libc_duration=0):
    """ Aggregate the results nicely in a single folder

    Args:
        benchmark (str): benchmark to process
        program (str): program(s) to process
        target (str): configuration that was run
    """
    # I may start this without result folder
    if not RESULT_FOLDER or not os.path.isdir(RESULT_FOLDER):
        my_logger.error("RESULT FOLDER DOES NOT EXIST OR NOT SET")
        exit(-1)

    token_base_to_derive = "== Detect type confusion from base-to-derived cast =="
    token_unrelated_type = "== Detect type confusion from cast to unrelated type =="

    num_unrelated_cast = 0
    num_base_to_derive = 0

    has_compiled = False
    has_run = False
    has_error = False
    size = 0
    list_reported_time = {}

    if benchmark == "cpu2006" or benchmark == "cpu2017":

        log_file_found = False
        list_of_files = filter(os.path.isfile, glob.glob(os.path.join(benchmark_home, "result", "*")))
        list_of_files = sorted(list_of_files, key=os.path.getmtime, reverse=True)
        file_path = ""
        for file in list_of_files:
            file_path = file
            if os.path.getmtime(file_path) < TIME_START_RUN:
                continue
            if file_path.endswith(".rsf"):
                # check if the file contains the target program info
                with open(file_path) as f:
                    p = program.replace(".", "_").replace("named", "namd")
                    my_logger.info("Seeking results for %s", p)
                    if f"results.{p}" in f.read():
                        log_file_found = True
                        break

        # If I don't find a log file, I assume the program did not compile neither run
        has_compiled = False
        if not log_file_found:
            my_logger.info("Log file for %s not found!", program)
        else:
            has_compiled = True
        
        my_logger.info("Processing file: %s", file_path)

        # what to parse:
        # spec.cpu2006.results.473_astar.base.000.reported_time: 458.94228
        i = 0
        with open(file_path) as fr:
            for l in fr:
                if "reported_time" in l:
                    reported_time_str = l.split(":")[-1].strip()

                    try:
                        reported_time = float(reported_time_str)
                    except ValueError:
                        reported_time = None

                    if reported_time is not None:
                        list_reported_time[i] = reported_time
                        i += 1
                if "had invalid runs" in l:
                    has_error = True

                if "Error with make!" in l:
                    has_compiled = False

        has_run = len(list_reported_time) > 0

        exe_list = list(filter(is_exe, glob.glob(os.path.join(benchmark_home, "benchspec", "CPU*", PROGRAM, "run", "run_base*0000/*"))))
        if not len(exe_list) > 0:
            my_logger.error("We should have only one executable. " + " ".join(exe_list))
        else:
            size = os.path.getsize(exe_list[0])
    else:
        my_logger.error("Unknown benchmark: %s or program: %s", benchmark, program)
        exit(1)

    if has_compiled:
        compiled_programs = os.path.join(RESULT_FOLDER, "compile.txt")
        with open(compiled_programs, "a") as fout:
            fout.write(f"{benchmark}|{program}|{target}\n")
        size_programs = os.path.join(RESULT_FOLDER, "size.txt")
        with open(size_programs, "a") as fout:
            fout.write(f"{benchmark}|{program}|{target}|{size}\n")
        compilation_duration_programs = os.path.join(RESULT_FOLDER, "compilation_duration.txt")
        with open(compilation_duration_programs, "a") as fout:
            fout.write(f"{benchmark}|{program}|{target}|{duration}\n")
        libc_compilation_duration_programs = os.path.join(RESULT_FOLDER, "libc_compilation_duration.txt")
        if libc_duration > 0:
            with open(libc_compilation_duration_programs, "a") as fout:
                fout.write(f"{benchmark}|{program}|{target}|{libc_duration}\n")
        
    else:
        has_error = True

    if has_run and not has_error:
        run_programs = os.path.join(RESULT_FOLDER, "run.txt")
        with open(run_programs, "a") as fout:
            fout.write(f"{benchmark}|{program}|{target}\n")

        performance_file = os.path.join(RESULT_FOLDER, "runtime_performance.csv")
        with open(performance_file, "a") as fout:
            for i, reported_time in list_reported_time.items():
                fout.write(f"{benchmark}|{program}|{target}|{i}|{reported_time}\n")

    if has_error:
        error_file = os.path.join(RESULT_FOLDER, "errors.csv")
        with open(error_file, "a") as fout:
            fout.write(f"{benchmark}|{program}|{target}\n")

    # type_confusion_file = os.path.join(TYPEPLUS_LOG_PATH, "type_confusion.txt")
    # if os.path.isfile(type_confusion_file):
    #   with open(type_confusion_file) as tcf:
    #     for l in tcf:
    #       if token_base_to_derive in l:
    #         num_base_to_derive += 1
    #       if token_unrelated_type in l:
    #         num_unrelated_cast += 1

    # type_confusion_stats = os.path.join(RESULT_FOLDER, "type_confusion_stats.csv")
    # with open(type_confusion_stats, "a") as ftcs:
    #   ftcs.write(f"{benchmark}|{program}|{target}|base_to_derive|{num_base_to_derive}\n")
    #   ftcs.write(f"{benchmark}|{program}|{target}|unrelated_cast|{num_unrelated_cast}\n")

    total_result = os.path.join(TYPEPLUS_LOG_PATH, "total_result.txt")
    if os.path.isfile(total_result):
        if args.typepp_classes:
            total_result_dest = os.path.join(RESULT_FOLDER, f"total_result_{target}_typepp_{program}.txt")
        else:
            total_result_dest = os.path.join(RESULT_FOLDER, f"total_result_{target}_{program}.txt")
        shutil.copy(total_result, total_result_dest)
    merge_log = os.path.join(TYPEPLUS_LOG_PATH, "merge_log.txt")
    if os.path.isfile(merge_log):
        result_dest = os.path.join(RESULT_FOLDER, f"merge_log_{target}_{program}.txt")
        shutil.copy(merge_log, result_dest)


def run_command(command):
    """ Run one of the command to build/run Type++ programs

    Args:
        command (str): the shell command to pass to subprocess.Popen

    Returns:
        boolean: depending on the error status of the command
    """
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
    error_msg = ""
    while True:
        line = proc.stdout.readline()
        if not line:
            break
        decoded = line.decode("utf-8")
        if "*** Error building " in decoded:
            error = True
            if args.verbose:
                print(decoded , end="")
            error_msg += decoded
    proc.communicate()
    if error:
        print(error_msg)
    return error


def set_environ(log_path):
    my_logger.info(f"{log_path=}")
    if not args.skip:
        try:
            shutil.rmtree(log_path)
        except FileNotFoundError:
            pass
    else:
        try:
            os.remove(path.join(log_path, "typeinfo.txt"))
            os.remove(path.join(log_path, "profiling_out.txt"))
            os.remove(path.join(log_path, "merged.txt"))
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
    """ Expand environment variabel to be understandable by SPEC CPU

    Args:
        vars (dictionary): environment variable in a ditionarry str:str

    Returns:
        str: the environment variable as a long define string
    """
    defines = ""
    for k, v in vars.items():
        defines += " --define " + k + "=" + v
    return defines


def merge_target_classes(log_path, target_path, libc_inclusive=True):
    """ Generate the file containing all the classes used for the optimized 
    version of Type++. In particular aggregate all the classes in the 
    casting_obj_init* files and the one from depending libraries 
    (libcx/libcxxabi/libunwind)

    Args:
        log_path (str): path to the log folder where the casting_obj_init* 
                        files are stored.
        target_path (str): the file in which all classes should be populated
    """
    if libc_inclusive:
        shutil.copyfile(
            path.join(TEMP_FOLDER, "libc/classes_to_instrument_derived.txt"), path.join(log_path, "derived_casting_obj_libcxx.txt")
        )
        shutil.copyfile(
            path.join(TEMP_FOLDER, "libc/classes_to_instrument_unrelated.txt"), path.join(log_path, "unrelated_casting_obj_libcxx.txt")
        )
        shutil.copyfile(
            path.join(TEMP_FOLDER, "libc/from_void_merged.txt"), path.join(log_path, "cast_from_void_libcxx.txt")
        )
        shutil.copyfile(
            path.join(TEMP_FOLDER, "libc/to_void_merged.txt"), path.join(log_path, "cast_to_void_libcxx.txt")
        )
    merge_script = path.join(typeplusplus_home, "script/merge_typecasting_related_type.py")
    output = subprocess.run(merge_script + " " + log_path + " > " + target_path, capture_output=True,  shell=True)
    with open(os.path.join(log_path, "merge_log.txt"), "w") as f:
        f.write(output.stderr.decode("utf-8"))
    with open(target_path, "r") as f:
        lines = f.readlines()
    with open(target_path, "w") as f:
        for line in lines:
            # disallow list for BOOST FUNCTION. When instrumented, it creates 
            # missed cast  due to *copy of vtable from original*. 
            if line.strip("\n").startswith("basic_vtable"): 
                for i in range(0, 0):
                    if line.strip("\n").endswith(str(i)):
                        f.write(line)
            elif line.strip("\n").startswith("_Unwind"):
                # Issue appear in parest_r SPEC CPU 2017 if enabled with 
                # libcxxabi checking.
                # In particular, while the _Unwind_Exception does include a vptr
                # and gdb report the correct size for __cxa_exception 
                # in __cxa_allocate_exception. When the exception goes trough a 
                # catch the field exception_class (see unwind.h : 141) does not 
                # seem to be read at the correct location. When printing an 
                # _Unwind_Exception object there is no vptr and 
                # __setExceptionClass set one field to low (as it there was a 
                # vptr) but no way to see this vptr in gdb.
                # The unsuccessful catch could come from libc that is not 
                # compiled/adapted to Type++. TODO NICOLAS FIX
                pass
            else: 
                f.write(line)

def clean_warning_putput(warning_new_name, hide_merged=False):

    Path(f"{TYPEPLUS_LOG_PATH}/warning_logfile.txt").touch()
    subprocess.call(f"mv {TYPEPLUS_LOG_PATH}/warning_logfile.txt {RESULT_FOLDER}/{warning_new_name}", shell=True)

    #if hide_merged:
    #    subprocess.call(f"mv {TYPEPLUS_LOG_PATH}/merged.txt {TYPEPLUS_LOG_PATH}/merged_deleted.txt", shell=True)
    #else:
    #    subprocess.call(f"mv {TYPEPLUS_LOG_PATH}/merged_deleted.txt {TYPEPLUS_LOG_PATH}/merged.txt", shell=True)


def set_base_config(vars):
    vars["COPTIMIZE"] = ""
    if args.benchmark == "cpu2006":
        vars["BASE_CFG"] = "base_2006.cfg"
    else:
        vars["BASE_CFG"] = "base_2017.cfg"


def sourcerer_lib(log_path, normal_libs=True):
    """ Reutrn the library specific CXXFLAGS for a Type++ build.

    Args:
        for_program (bool, optional): Is it a build for a specific program. Defaults to False.

    Returns:
        str: CXXFLAGS
    """
    version = "-13.0.0" if args.libcxx == "13.0.0" else ""
    library_path = os.path.join(log_path, "lib", "x86_64-unknown-linux-gnu")
    if not normal_libs:
        library_path = path.join(log_path, "lib")
    return (" -Wl,-rpath," + library_path 
        + " -L" + library_path
        + "          -I"
        + path.join(log_path,  "include/c++/v1")
        + "          -I"
        + path.join(log_path,  "include/x86_64-unknown-linux-gnu/c++/v1/")
        + (anal_flag(build_dir) if args.warning_analysis and not normal_libs else "")
        + '"'
    )


def get_clean_cmd(run_cmd: str, program: str, comp_vars):
    """ Provide the shell command for the cleaning the build folder of spec

    Args:
        run_cmd (str): current shell command to run
        program (str): program to clean
        comp_vars (dictionary): str:str of environment variables to be passes to
                                SPEC CPU 

    Returns:
        str: the command to pass to subprocess
    """

    clean = None
    if args.benchmark.startswith("cpu"):
        defines = set_spec_defines(comp_vars)
        clean = run_cmd + " --action=clean " + program + defines
    else:
        my_logger.error("Unkown benchmark: %s", args.benchmark)
        exit(1)

    return clean


def get_build_cmd(run_cmd: str, program: str, comp_vars):
    """ Provide the shell command for the initial build iteration of Type++

    Args:
        run_cmd (str): current shell command to run
        program (str): program to build
        comp_vars (dictionary): str:str of environment variables to be passes to
                                SPEC CPU 

    Returns:
        str: the command to pass to subprocess
    """

    build = None
    if args.benchmark.startswith("cpu"):
        defines = set_spec_defines(comp_vars)
        build = run_cmd + " --action=build " + program + defines
    else:
        my_logger.error("Unkown benchmark: %s", args.benchmark)
        exit(1)

    return build


def get_rebuild_cmd(run_cmd: str, program: str, comp_vars):
    """ Provide the shell command for the second build iteration of Type++

    Args:
        run_cmd (str): current shell command to run
        program (str): program to build
        comp_vars (dictionary): str:str of environment variables to be passes to
                                SPEC CPU 

    Returns:
        str: the command to pass to subprocess
    """

    rebuild = None
    if args.benchmark.startswith("cpu"):
        defines = set_spec_defines(comp_vars)
        rebuild = run_cmd + " --action=build --rebuild " + program + defines
    else:
        my_logger.error("Unkown benchmark: %s", args.benchmark)
        exit(1)

    return rebuild


def get_run_cmd(run_cmd: str, program: str, comp_vars):
    """ Provide the shell command for running the program compiled with Type++

    Args:
        run_cmd (str): current shell command to run
        program (str): program to run
        comp_vars (dictionary): str:str of environment variables to be passes to
                                SPEC CPU 

    Returns:
        str: the command to pass to subprocess
    """

    run = None
    if args.benchmark.startswith("cpu"):
        defines = set_spec_defines(comp_vars)
        run = "LD_LIBRARY_PATH=" + TYPEPLUS_LOG_PATH + "/lib " + run_cmd + " --size=ref --noreportable --iterations=" + str(args.iterations) + " " + program + defines
    else:
        my_logger.error("Unkown benchmark: %s", args.benchmark)
        exit(1)

    return run


def get_env_dir(name: str):
    dir = os.environ.get(name, "")
    if not path.isdir(dir):
        my_logger.error(f"{name} is not set or incorrect. Aborting.\n{dir=}")
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
parser.add_argument(
    "-target",
    "-t",
    help="Evaluation target: baseline, cfi, sourcerer",
    type=str,
    choices=["baseline", "cfi", "sourcerer"],
    required=True,
)
parser.add_argument("-stats", "-s", help="Profiling sourcerer", action="store_true", default=False)
parser.add_argument("-program", "-p", help="Sub-benchmarking", nargs="*")
parser.add_argument("-debug", "-d", help="Benchmark Debug build", action="store_true", default=False)
parser.add_argument("-clang_debug", "-cd", help="Clang Debug build", action="store_true", default=False)
parser.add_argument("-verbose", "-v", help="Print SPEC info", default=False, action="store_true")
parser.add_argument("--skip", help="Skip initial build", default=False, action="store_true")
parser.add_argument("-iterations", "-i", help="Number of iterations", default=10, type=int)
parser.add_argument("--memory_overhead", "-m", help="Measure memory overhead", action="store_true", default=False)
parser.add_argument("--without-libc-casts", "-wlc", help="Do not count libc casts", action="store_true", default=False)
parser.add_argument("--typepp_classes", "-tc", help="typepp classes", action="store_true", default=False)
parser.add_argument("--libcxx", "-lc", help="use non default libcxx version", default="19.0.0", type=str)
parser.add_argument("--no-check", help="Do not check casts", action="store_true", default=False)
parser.add_argument("--no-insertor", help="Do not set the RTTI values", action="store_true", default=False)
parser.add_argument("--warning-analysis", help="Run warning analysis instead", action="store_true", default=False)
args = parser.parse_args()

ENVIRONMENT_FOLDER = os.environ.get("ENVIRONMENT_FOLDER")
env_patch_str = "environment_patched.sh"
if not ENVIRONMENT_FOLDER or not os.path.isfile(os.path.join(ENVIRONMENT_FOLDER, env_patch_str)):
    my_logger.error(f"ENVIRONMENT_FOLDER is not set or incorrect. Aborting.\n{ENVIRONMENT_FOLDER=}")
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

SPEC_VARS = {}
SPEC_VARS["build_ncpus"] = str(os.cpu_count())


CXXOPTIMIZE = get_default_CXXOPTIMIZE(args.benchmark)
if args.debug:
  CXXOPTIMIZE += " -g -O0"
  SPEC_VARS["COPTIMIZE"] = "-g -O0"

if args.stats:
    if args.target == "sourcerer":
        CXXOPTIMIZE += " -mllvm -collect-profiling-data "
    elif args.target == "cfi":
        CXXOPTIMIZE += (
            " -fsanitize=typeplus "
            + " -mllvm -collect-profiling-data "
        )

    else:
        my_logger.info("Baseline is incompatible with --stats. Ignoring")


copy_configs()
set_base_config(SPEC_VARS)

# Create the target list
for PROGRAM in programs:
  my_logger.debug("Program: %s", PROGRAM)

  TIME_START_RUN = time.time()

  TYPEPLUS_LOG_PATH=path.join(*[TEMP_FOLDER, args.benchmark, PROGRAM])
    
  target_type_list_path = set_environ(TYPEPLUS_LOG_PATH)
  build_dir, target_CXXOPTIMIZE = choose_target(args.target, "collect")
  SPEC_VARS["CLANG_BUILD_DIR"] = build_dir
  my_logger.info(f'{SPEC_VARS["CLANG_BUILD_DIR"]=}')
  SPEC_VARS["CXXOPTIMIZE"] = CXXOPTIMIZE + target_CXXOPTIMIZE + sourcerer_lib(os.path.join(build_dir, "..", "normal_libs"))
  
  # if some structs has fake fields, we need to count them also in the first compilation step, e.g. Blender & CactusBSSN
  if args.target == "sourcerer":
    SPEC_VARS["COPTIMIZE"] += "-DIS_TYPEXX"

  clean = get_clean_cmd(run_cmd, PROGRAM, SPEC_VARS)
  run_command(clean)
  my_logger.info("Target: %s", args.target)
  duration = 0
  libc_duration = 0
  start = time.time()
  if args.target == "sourcerer":
    if PROGRAM in CUSTOM_HEADERS:
      # NOTE: I want CUSTOM_HEADER_SIZE in base 10 here
      os.environ["CUSTOM_HEADER_SIZE"] = f"{CUSTOM_HEADERS[PROGRAM]}" 
      my_logger.info("Custom header size: %s", CUSTOM_HEADERS[PROGRAM])
    else:
      if "CUSTOM_HEADER_SIZE" in os.environ:
        del os.environ["CUSTOM_HEADER_SIZE"]

    #shutil.copytree(build_dir + "/normal_libs/lib", os.path.join(TYPEPLUS_LOG_PATH, "lib"))
    try:
        if not args.skip:
            build = get_build_cmd(run_cmd, PROGRAM,  SPEC_VARS)
            my_logger.info("Build command:\n%s", build)
            if run_command(build):
                my_logger.error("Build returned an error!")
                process_result(args.benchmark, PROGRAM, args.target)
                continue
            duration += time.time() - start 

        build_dir, target_CXXOPTIMIZE = choose_target(args.target, "optimize")
        SPEC_VARS["CXXOPTIMIZE"] = CXXOPTIMIZE + target_CXXOPTIMIZE
        merge_target_classes(TYPEPLUS_LOG_PATH, target_type_list_path, not args.without_libc_casts)
        # build libs
        os.chdir(llvm_home)
        with open(target_type_list_path, "r") as f:
            lines = f.readlines()
        if args.libcxx == "13.0.0":
            with open(target_type_list_path, "w") as f:
                for line in lines:
                    if line.strip("\n") != "__basic_string_common" and line.strip("\n") != "basic_string":
                        if line.strip("\n") != "__vector_base_common" and line.strip("\n") != "__vector_base":
                            f.write(line)
        #shutil.copy("/tmp/merged.txt", "/tmp/cpu2006/471.omnetpp/merged.txt")
        env = os.environ
        env["TYPEPLUS_LOG_PATH"] =  TYPEPLUS_LOG_PATH
        env["INSTALL_DIR"] = TYPEPLUS_LOG_PATH
        start = time.time()
        lib_build_script = "build_instrument.sh" if not args.libcxx == "13.0.0" else "cxx_build_for_program.sh"
        if args.clang_debug:
            lib_build_out = subprocess.check_output([os.path.join(llvm_home, lib_build_script)] + ["debug"], env=env)
        else:
            lib_build_out = subprocess.check_output([os.path.join(llvm_home, lib_build_script)], env=env)
        libc_duration = time.time() - start
        #print(lib_build_out.decode("utf-8"))
        start = time.time()
    except subprocess.CalledProcessError as ce:
        print(ce.output.decode("utf-8"), end="")
        my_logger.error("sourcerer_pre_build got an error, skipping %s.", PROGRAM)
        exit(1)
        continue
    SPEC_VARS["CXXOPTIMIZE"] = CXXOPTIMIZE + target_CXXOPTIMIZE + sourcerer_lib(TYPEPLUS_LOG_PATH, False) 
    SPEC_VARS["COPTIMIZE"] = "-DIS_TYPEXX"
    my_logger.info("CXX_FLAGS: %s", SPEC_VARS["CXXOPTIMIZE"])


  #if args.target == "sourcerer" and args.typepp_classes:

  rebuild = get_rebuild_cmd(run_cmd, PROGRAM, SPEC_VARS)
  my_logger.info("Rebuild command:\n%s", rebuild)
  if not run_command(rebuild):
    expected_deepsjeng_result(args.target == "sourcerer")
    duration += time.time() - start 
    run = get_run_cmd(run_cmd, PROGRAM, SPEC_VARS)

    my_logger.info("Run command:\n%s", run)
    run_command(run)
    process_result(args.benchmark, PROGRAM, args.target, duration, libc_duration)

    if args.memory_overhead:
      run = run + " & " + TYPESAFETY_FOLDER + "/spec_cpu/memory_measurement.sh " + args.target + " " + PROGRAM
      my_logger.info("Run memory eval:\n%s", run)
      run_command(run)
  else: 
    my_logger.error("2nd Build returned an error!")
    if(args.warning_analysis):
        # run warning analysis
        clean_warning_putput(f"warning_logfile_{args.benchmark}_{PROGRAM}.txt", True)
