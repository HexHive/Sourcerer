#!/usr/bin/env python3

import os
import pytest 
import argparse
from infrastructure_testing import ConfigTestCase, CoverageResults, CoverageResultsWithoutTotal, ClassCollectionResults, ClassCollectionResultsFull, ClassCollectionResultsPartial

import settings

@pytest.fixture(autouse=True, scope="session")
def set_up_compiler():
    settings.initializeGlobalValue(os.getenv("HEXTYPE", "0") == "1")

def test_1(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_handled_cast=1, derived_type_confusion=1)
    class_collection_results = ClassCollectionResultsFull(set(), set("A"))
    test = ConfigTestCase("./basic_derived_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_2(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=3, unrelated_type_confusion=3)
    class_collection_results = ClassCollectionResultsFull(set(["C", "D"]), set())
    test = ConfigTestCase("./basic_reinterpret_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_3(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=1, unrelated_type_confusion=1)
    class_collection_results = ClassCollectionResultsFull(set(["C", "D"]), set())
    test = ConfigTestCase("./unrelated_int_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_4(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=1, unrelated_type_confusion=1)
    class_collection_results = ClassCollectionResultsFull(set(["D", "C"]), set())
    test = ConfigTestCase("./unrelated_int_poly_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_5(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_handled_cast=1, derived_type_confusion=1)
    class_collection_results = ClassCollectionResultsFull(set(), set(["A"]))
    test = ConfigTestCase("./derived_poly_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_6(debug):
    coverage_results = CoverageResultsWithoutTotal()
    class_collection_results = ClassCollectionResultsFull(set(), set())
    test = ConfigTestCase("./self_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_7(debug):
    coverage_results = CoverageResultsWithoutTotal()
    class_collection_results = ClassCollectionResultsFull(set(), set())
    test = ConfigTestCase("./non_pointer_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_8(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=1, unrelated_type_confusion=1, derived_handled_cast=1, derived_type_confusion=1)
    class_collection_results = ClassCollectionResultsFull(set(["E", "Unrelated"]), set(["Child1", "Base1", "Child2"]))
    test = ConfigTestCase("./reference_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_9(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=3) 
    class_collection_results = ClassCollectionResultsFull(set(["cat", "basic_streambuf"]), set(["ctype", "facet"]))
    test = ConfigTestCase("./constructor", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_10(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_type_confusion=1, unrelated_handled_cast=1) 
    class_collection_results = ClassCollectionResultsFull(set(["C", "E", "B", "D"]), set())
    test = ConfigTestCase("./only_child_inst", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_11(debug):
    coverage_results = CoverageResultsWithoutTotal() 
    class_collection_results = ClassCollectionResultsFull(set(["basic_string", "basic_streambuf"]), set(["ctype", "facet"]))
    test = ConfigTestCase("./template", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=False)
    test.inspect_results()

def test_12(debug):
    coverage_results = CoverageResultsWithoutTotal() 
    class_collection_results = ClassCollectionResultsFull(set(["basic_string"]), set([]))
    test = ConfigTestCase("./template_min", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=False)
    test.inspect_results()

def test_13(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=1) 
    class_collection_results = ClassCollectionResultsFull(set(["atomic", "basic_streambuf"]), set(["ctype","facet"]))
    test = ConfigTestCase("./atomic_number_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_14(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=2, unrelated_type_confusion=2) 
    class_collection_results = ClassCollectionResultsFull(set(["A", "B"]), set([]))
    test = ConfigTestCase("./union_casting", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_15(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=10, unrelated_handled_cast=1) 
    class_collection_results = ClassCollectionResultsFull(set(["Base"]), set(["Base", "Derived"]))
    test = ConfigTestCase("./custom_calloc", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_16(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=2, derived_type_confusion=6) 
    class_collection_results = ClassCollectionResultsFull(set(["Base"]), set(["Base", "Derived"]))
    test = ConfigTestCase("./malloc_with_reinterpret_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_17(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=4, derived_type_confusion=4) 
    class_collection_results = ClassCollectionResultsFull(set(["Base", "Base2", "Base3", "Base4"]), set(["Base", "Base2", "Base3", "Base4"]))
    test = ConfigTestCase("./malloc_with_complex_constructor", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_18(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=1, derived_handled_cast=2) 
    class_collection_results = ClassCollectionResultsFull(set(["pair", "__tree_node", "OtherClass"]), set(["__tree_node_base", "__tree_end_node"]))
    test = ConfigTestCase("./use_of_libc", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_19(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=1) 
    class_collection_results = ClassCollectionResultsFull(set(), set(["a"]))
    test = ConfigTestCase("./simple", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_20(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=1) 
    class_collection_results = ClassCollectionResultsFull(set(["basic_streambuf"]), set(["ctype", "facet"]))
    test = ConfigTestCase("./already_poly", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_21(debug):
    coverage_results = CoverageResultsWithoutTotal() 
    class_collection_results = ClassCollectionResultsFull(set(["pair"]), set([]))
    test = ConfigTestCase("./unused_template", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_22(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=1, unrelated_handled_cast=1) 
    class_collection_results = ClassCollectionResultsFull(set(["basic_streambuf","vector"]), set(["ctype", "facet", "A"]))
    test = ConfigTestCase("./vector_and_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_23(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=1, unrelated_type_confusion=3) 
    class_collection_results = ClassCollectionResultsFull(set(["A", "C", "D", "B"]), set([]))
    test = ConfigTestCase("./malloc_and_member", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_24(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_handled_cast=0, unrelated_type_confusion=0) 
    class_collection_results = ClassCollectionResultsFull(set([]), set([]))
    test = ConfigTestCase("./function_cast", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()

def test_25(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=10, unrelated_handled_cast=1) 
    class_collection_results = ClassCollectionResultsFull(set(["Base"]), set(["Base", "Derived"]))
    test = ConfigTestCase("./custom_malloc", coverage_results, class_collection_results)
    test.run(debug=debug, no_lib=True)
    test.inspect_results()



# Initialization 
    
def test_53(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=4, derived_handled_cast=4) 
    class_collection_results = ClassCollectionResultsFull(set(), set(["A", "B"]))
    test = ConfigTestCase("./simple_derived_cast", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_54(debug):
    # missed cast: should be derived type confusion
    coverage_results = CoverageResultsWithoutTotal(derived_handled_cast=2,derived_type_confusion=2, unrelated_type_confusion=1) 
    class_collection_results = ClassCollectionResultsFull(set(["OtherParent", "basic_streambuf", "Parent"]), set(["Parent", "OtherParent", "ctype", "facet"]))
    test = ConfigTestCase("./multiple_parent", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_55(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_handled_cast=1,derived_type_confusion=1, unrelated_type_confusion=1) 
    class_collection_results = ClassCollectionResultsFull(set(["Bike", "Car"]), set(["Vehicle"]))
    test = ConfigTestCase("./direct_list_initialization", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_56(debug):
    # missed cast: should be derived type confusion
    coverage_results = CoverageResultsWithoutTotal(unrelated_type_confusion=1, derived_handled_cast=3, derived_type_confusion=2) 
    class_collection_results = ClassCollectionResultsFull(set(["Structure", "ParentClass"]), set(["Structure", "AnotherStructure", "ParentClass"]))
    test = ConfigTestCase("./direct_initialization", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_57(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=1, derived_handled_cast=1) 
    class_collection_results = ClassCollectionResultsFull(set([]), set(["D"]))
    test = ConfigTestCase("./reused_after_delete", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_58(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_handled_cast=2,derived_type_confusion=2) 
    class_collection_results = ClassCollectionResultsFull(set(["basic_streambuf", ]), set(["ctype", "facet", "Base"]))
    test = ConfigTestCase("./copy_list_initialization", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_59(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=1) 
    class_collection_results = ClassCollectionResultsFull(set([]), set(["Structure"]))
    test = ConfigTestCase("./direct_initialization_bis", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_60(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=2) 
    class_collection_results = ClassCollectionResultsFull(set([]), set(["D"]))
    test = ConfigTestCase("./union_of_ptrs", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()
    
def test_61(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=2, unrelated_handled_cast=1, unrelated_type_confusion=1) 
    class_collection_results = ClassCollectionResultsFull(set(["E", "G"]), set(["D"]))
    test = ConfigTestCase("./aggregate_initialization", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()
    
def test_62(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=2, derived_handled_cast=1, unrelated_type_confusion=3, unrelated_handled_cast=1)
    class_collection_results = ClassCollectionResultsFull(set(["E","F","G","D"]), set(["D"]))
    test = ConfigTestCase("./array_of_ptrs", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()
    
def test_64(debug):
    coverage_results = CoverageResultsWithoutTotal(unrelated_type_confusion=0, derived_type_confusion=0) 
    class_collection_results = ClassCollectionResultsFull(set(["basic_streambuf"]), set(["ctype", "facet"]))
    test = ConfigTestCase("./basic_placement_new", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()
    
def test_65(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=1, unrelated_type_confusion=1) 
    class_collection_results = ClassCollectionResultsFull(set(["A", "basic_streambuf", "D"]), set(["D","ctype", "facet"]))
    test = ConfigTestCase("./placement_new", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_66(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=3, unrelated_handled_cast=3, unrelated_type_confusion=2) 
    class_collection_results = ClassCollectionResultsFull(set(["D","E","F", "G", "basic_streambuf"]), set(["D","ctype", "facet"]))
    test = ConfigTestCase("./placement_new_bis", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()

def test_67(debug):
    coverage_results = CoverageResultsWithoutTotal(derived_type_confusion=4, unrelated_type_confusion=2, derived_handled_cast=2) 
    class_collection_results = ClassCollectionResultsFull(set(["A", "D", "C"]), set(["A"]))
    test = ConfigTestCase("./copy_initialization", coverage_results, class_collection_results)
    test.run(debug=debug)
    test.inspect_results()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-debug", "-d", help="Use debug clang", action="store_true", default=False)
    parser.add_argument("-hextype", help="Use Typepp or Hextype", action="store_true", default=False)
    args = parser.parse_args() 

    os.environ["HEXTYPE"] = "1" if args.hextype else "0"

    pytest.main(["-n", "auto", "--clang_debug" if args.debug else ""])
