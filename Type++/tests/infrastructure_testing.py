
from typing import Set
import os
import subprocess
import re
import logging
from dotenv import load_dotenv
import shutil
import settings

logger = logging.getLogger(__name__)

class Coverage:
    def __init__(self, total_cast: int = 0, missed_cast: int = 0, type_confusion: int = 0, handled_cast: int = 0):
        self.total_cast = total_cast
        self.missed_cast = missed_cast
        self.type_confusion = type_confusion
        self.handled_cast = handled_cast
    
    def __eq__(self, other):
        """Overrides the default implementation"""
        if isinstance(other, Coverage):
            return self.total_cast == other.total_cast and self.type_confusion + self.missed_cast == other.missed_cast + other.type_confusion and self.handled_cast == other.handled_cast
        return NotImplemented
    
    def __str__(self):
        return "Total: {}, Missed: {}, Type confusion: {}, Handled: {}".format(self.total_cast, self.missed_cast, self.type_confusion, self.handled_cast)

class CoverageResults:
    def __init__(self, unrelated_total_cast: int = 0, unrelated_missed_cast: int = 0, unrelated_type_confusion: int = 0, unrelated_handled_cast: int = 0, derived_total_cast: int = 0, derived_missed_cast: int = 0, derived_type_confusion: int = 0, derived_handled_cast: int = 0):
        assert unrelated_total_cast == unrelated_missed_cast + unrelated_type_confusion + unrelated_handled_cast, "Total number of unrelated cast don't match"
        assert derived_total_cast == derived_missed_cast + derived_type_confusion + derived_handled_cast, "Total number of derived cast don't match"
        self.derived = Coverage(derived_total_cast, derived_missed_cast, derived_type_confusion, derived_handled_cast)
        self.unrelated = Coverage(unrelated_total_cast, unrelated_missed_cast, unrelated_type_confusion, unrelated_handled_cast)

    def has_missed_cast(self):
        return self.unrelated.missed_cast > 0 or self.derived.missed_cast > 0
    
    def __eq__(self, other):
        """Overrides the default implementation"""
        if isinstance(other, CoverageResults):
            return self.unrelated == other.unrelated and self.derived == other.derived 
        return NotImplemented
    
    def __str__(self):
        return "UNRELATED: {}\nDERIVED: {}".format(self.unrelated, self.derived)

class CoverageResultsWithoutTotal(CoverageResults):
    def __init__(self, unrelated_missed_cast: int = 0, unrelated_type_confusion: int = 0, unrelated_handled_cast: int = 0, derived_missed_cast: int = 0, derived_type_confusion: int = 0, derived_handled_cast: int = 0):
        unrelated_total_cast = unrelated_missed_cast + unrelated_type_confusion + unrelated_handled_cast
        derived_total_cast = derived_missed_cast + derived_type_confusion + derived_handled_cast
        super().__init__(unrelated_total_cast, unrelated_missed_cast, unrelated_type_confusion, unrelated_handled_cast, derived_total_cast, derived_missed_cast, derived_type_confusion, derived_handled_cast)
        

class ClassCollectionResults:
    unrelated_collected_classes = set()
    derived_collected_classes = set()
    from_void_collected_classes = set()
    to_void_collected_classes = set()
    unrelated_total_classes = 0
    derived_total_classes = 0
    from_void_total_classes = 0
    to_void_total_classes = 0
    total_classes = 0

    def __init__(self, total_classes: int):
        self.total_classes = total_classes

    def __eq__(self, other) -> bool:
        """Overrides the default implementation"""
        if isinstance(other, ClassCollectionResults):
            if self.total_classes != other.total_classes:
                return False
            if (self.unrelated_total_classes != 0 and other.unrelated_total_classes != 0) or (self.derived_collected_classes != 0 and other.derived_collected_classes != 0):
                if self.unrelated_total_classes != other.unrelated_total_classes or self.derived_total_classes != other.derived_total_classes:
                    return False
            if (len(self.unrelated_collected_classes) != 0 and len(other.unrelated_collected_classes) != 0) or (len(self.derived_collected_classes) != 0 and len(other.derived_collected_classes) != 0):
                if self.unrelated_collected_classes != other.unrelated_collected_classes or self.derived_collected_classes != other.derived_collected_classes:
                    return False
            return True
        return NotImplemented
    
    def __str__(self):
        return "Total classes: {}, Unrelated collected classes: {}, Derived collected classes: {}".format(self.total_classes, self.unrelated_collected_classes, self.derived_collected_classes)

class ClassCollectionResultsFull(ClassCollectionResults):
    def __init__(self, unrelated_collected_classes: Set[str], derived_collected_classes: Set[str], from_void_collected_classes: Set[str] = set(), to_void_collected_classes: Set[str] = set()):
        self.unrelated_collected_classes = unrelated_collected_classes
        self.derived_collected_classes = derived_collected_classes
        self.from_void_collected_classes = from_void_collected_classes
        self.to_void_collected_classes = to_void_collected_classes
        self.unrelated_total_classes = len(unrelated_collected_classes)
        self.derived_total_classes = len(derived_collected_classes)
        self.from_void_total_classes = len(from_void_collected_classes)
        self.to_void_total_classes = len(to_void_collected_classes)
        if len(from_void_collected_classes) != 0 or len(to_void_collected_classes) != 0:
            print("From void collected classes: ", from_void_collected_classes)
            print("To void collected classes: ", to_void_collected_classes)
            self.unrelated_collected_classes.update(from_void_collected_classes)
            self.unrelated_collected_classes.update(to_void_collected_classes)
            self.unrelated_total_classes = len(unrelated_collected_classes)
        self.total_classes = self.unrelated_total_classes + self.derived_total_classes #+ self.from_void_total_classes + self.to_void_total_classes

class ClassCollectionResultsPartial(ClassCollectionResults):
    def __init__(self, unrelated_total_classes: int, derived_total_classes: int):
        self.unrelated_total_classes = unrelated_total_classes
        self.derived_total_classes = derived_total_classes
        self.total_classes = unrelated_total_classes + derived_total_classes



def parse_coverage_results(log_path: str) -> CoverageResults:
    if not os.path.exists(os.path.join(log_path, "total_result.txt")):
        return CoverageResults()
    with open(os.path.join(log_path, "total_result.txt"), "r") as f:
        lines = [line.rstrip() for line in f]

        assert "== Casting verification status ==" in lines, "Missing header lines"
        for i, l in enumerate(lines):
            m = re.search(r"Unrelated Casting: (\d+), Type_Confusion: (\d+), Missed: (\d+), Handled: (\d+)", l)
            if m is not None:
                unrelated_total_cast = int(m.group(1))
                unrelated_type_confusion = int(m.group(2))
                unrelated_missed_cast = int(m.group(3))
                unrelated_handled_cast = int(m.group(4))
        
                m = re.search(r"Derived Casting: (\d+), Type_Confusion: (\d+), Missed: (\d+), Handled: (\d+)", lines[i+2])
                derived_total_cast = int(m.group(1))
                derived_type_confusion = int(m.group(2))
                derived_missed_cast = int(m.group(3))
                derived_handled_cast = int(m.group(4))

                logger.info("Derived Casting: (%i), Type_Confusion: (%i), Missed: (%i), Handled: (%i)".format(derived_total_cast, derived_type_confusion, derived_missed_cast, derived_handled_cast))
                logger.info("Unrelated Casting: (%i), Type_Confusion: (%i), Missed: (%i), Handled: (%i)".format(unrelated_total_cast, unrelated_type_confusion, unrelated_missed_cast, unrelated_handled_cast))

                return CoverageResults(unrelated_total_cast, unrelated_missed_cast, unrelated_type_confusion, unrelated_handled_cast, derived_total_cast, derived_missed_cast, derived_type_confusion, derived_handled_cast)
    

class ConfigTestCase:
    env = {
        "PATH": os.environ["PATH"],
        "ENVIRONMENT_FOLDER": os.environ["HOME"],
        "HOME": os.environ["HOME"],
    }


    def __init__(self, path, expected_coverage_results: CoverageResults, expected_class_collection_results: ClassCollectionResults):
        if not os.path.isabs(path):
            path = os.path.join(os.path.dirname(__file__), path)
        assert os.path.isdir(path), "Path is not a directory"
        self.path = path
        self.coverage_results = expected_coverage_results
        self.class_collection_results = expected_class_collection_results
        log_path = "hextype_results" if settings.use_hextype else "log"
        self.log_path = os.path.join(self.path, log_path)
        if os.path.exists(self.log_path):
            shutil.rmtree(self.log_path)
        os.mkdir(self.log_path)
        shutil.copy(os.path.join(os.path.dirname(__file__), "Makefile"), self.path)
        
        if settings.use_hextype:
            print("I'm in __init__ of ConfigTestCase")
            print("File path: ", self.path)
            
            self.env["HEXTYPE_LOG_PATH"] = os.path.join(self.log_path)
            print("ConfigTestCase init done")
            
        else: 
            ENVIRONMENT_FOLDER = os.environ.get("ENVIRONMENT_FOLDER")
            env_patch_str = "environment_patched.sh"
            if not ENVIRONMENT_FOLDER or not os.path.isfile(os.path.join(ENVIRONMENT_FOLDER, env_patch_str)):
                exit(255)

            load_dotenv(os.path.join(ENVIRONMENT_FOLDER, env_patch_str))
            self.env.update(dict(os.environ))

            if "CUSTOM_HEADER_SIZE" in os.environ:
                cst_hdr = os.environ["CUSTOM_HEADER_SIZE"]
            else:
                cst_hdr = "0"
            self.env["CUSTOM_HEADER_SIZE"] = cst_hdr
            self.env["TYPEPLUS_LOG_PATH"] = self.log_path
            self.env["TARGET_TYPE_LIST_PATH"] = os.path.join(self.log_path, "classes_to_instrument_merged.txt")


    
    def inspect_results(self):
        if settings.use_hextype:
            if not os.path.exists(os.path.join(self.log_path, "total_result.txt")):
                assert self.coverage_results.derived.handled_cast == 0, "Hextype Derived Safe cast value is not as expected. \nExpected: {}\nRan: {}".format(self.coverage_results.derived.handled_cast, 0)
                assert self.coverage_results.derived.type_confusion == 0, "Hextype Derived Type confusion value is not as expected. \nExpected: {}\nRan: {}".format(self.coverage_results.derived.type_confusion, 0)
                return
            
            with open(os.path.join(self.log_path, "total_result.txt"), "r") as f:
                safe_cast_value = 0
                type_confusion_value = 0

                lines = [line.rstrip() for line in f]
                for line in lines:
                    if "Safe casting" in line:
                        parts = line.split(':')
                        if len(parts) > 1:
                            safe_cast_value += int(parts[0].strip())
                            
                    if "Type confusion cases" in line:
                        parts = line.split(':')
                        if len(parts) > 1:
                            type_confusion_value = parts[0].strip()
                            break
            
            is_error = False
            error_msg = ""
            if int(safe_cast_value) != self.coverage_results.derived.handled_cast:
                is_error = True
                error_msg = "Hextype Derived Safe cast is not as expected"
            
            if int(type_confusion_value) != self.coverage_results.derived.type_confusion:
                is_error = True
                error_msg = "Hextype Derived Type confusion is not as expected"

            if int(safe_cast_value) != self.coverage_results.derived.handled_cast and int(type_confusion_value) != self.coverage_results.derived.type_confusion:
                is_error = True
                error_msg = "Hextype Derived Safe cast and Type confusion are not as expected"

            if is_error:
                error_msg += "\nHextype Derived Safe - Expected: {} Ran: {}".format(self.coverage_results.derived.handled_cast, safe_cast_value)
                error_msg += "\nHextype Derived Type confusion - Expected: {} Ran: {}".format(self.coverage_results.derived.type_confusion, type_confusion_value)
                with open(os.path.join(self.log_path, "error_log.txt"), "w") as f:
                    f.write(error_msg)
                raise Exception(error_msg)
        else :
            unrelated_classes = []
            with open(os.path.join(self.log_path, "classes_to_instrument_unrelated.txt"), "r") as f:
                unrelated_classes = [line.rstrip() for line in f]
            with open(os.path.join(self.log_path, "from_void_merged.txt"), "r") as f:
                from_void_classes = [line.rstrip() for line in f]
            with open(os.path.join(self.log_path, "to_void_merged.txt"), "r") as f:
                to_void_classes = [line.rstrip() for line in f]
            with open(os.path.join(self.log_path, "classes_to_instrument_derived.txt"), "r") as f:
                derived_classes = [line.rstrip() for line in f]
            print("Unrelated classes: ", unrelated_classes)
            print("Derived classes: ", derived_classes)
            print("From void classes: ", from_void_classes)
            print("To void classes: ", to_void_classes)
            class_collection_results = ClassCollectionResultsFull(set(unrelated_classes), set(derived_classes), set(from_void_classes), set(to_void_classes)) 
            assert class_collection_results == self.class_collection_results, "Class collection results is not as expected\nExpected:{}\nRan:{}".format(self.class_collection_results, class_collection_results)

            coverage_results = parse_coverage_results(self.log_path)
            assert coverage_results == self.coverage_results, "Coverage results is not as expected\nUnrelated expected: {}\nUnrelated found:    {}\nDerived expected: {}\nDerived found:    {}".format(self.coverage_results.unrelated, coverage_results.unrelated, self.coverage_results.derived, coverage_results.derived)

    def run(self, debug=False, no_lib=False, cxx_version='c++11'):

        if not settings.use_hextype:
            self.env["LLVM_BUILD_DIR"] = self.env["DEBUG_BUILD_FOLDER"] if debug else self.env["BUILD_FOLDER"]
            print(self.env["LLVM_BUILD_DIR"])

        if settings.use_hextype and cxx_version in ["c++17", "c++20"]:
            raise Exception("Hextype does not support C++ version higher than c++14")
        
        subprocess.run(["make", 'clean'],  cwd=self.path, env=self.env)
        version = '-std=' + cxx_version

        print("Running make")
        print("Make target: ", "hextype" if settings.use_hextype else "libdebug" if debug else "fast" if no_lib else "all")
        run_result = subprocess.run(["make","hextype" if settings.use_hextype else "debug" if debug else "fast" if no_lib else "all", 'CXX_VERSION=' + version],  cwd=self.path, env=self.env)
        if run_result.returncode != 0:
            logger.error("Build or run failed")
            logger.error(run_result.stderr)
            raise Exception("Build or run failed")
