#!/usr/bin/env python3
import sys
import os
import logging

filepath = sys.argv[1]
files = []

logging.basicConfig(level=logging.INFO)
log = logging.getLogger()
log.name = "merge class files"
log.setLevel(logging.INFO)

classes = {
   "unrelated_casting_obj": set(),
   "derived_casting_obj": set(),
   "cast_from_void": set(),
   "cast_to_void": set(),
   "casting_obj_init": set(),
}

at_least_one_file = False
# filepath is a program folder with the different files containing the classes
for i in os.listdir(filepath):
    # opening all files containing class names to instrument
    if os.path.isfile(os.path.join(filepath, i)):
        if any(key in i for key in classes.keys()):
            at_least_one_file = True
            for key in classes.keys():
                if key in i:
                    with open(os.path.join(sys.argv[1], i), "r") as f:
                        data = f.readlines()
                        for line in data:
                            words = line.split()
                            assert len(words) == 1, "Error: more than one class in a line"
                            # iterate over the possible file names and add the 
                            # class in the corresponding set
                            classes[key].add(words[0])

if not at_least_one_file:
    log.warning(" no file containing class names to instrument found")

with open(os.path.join(filepath, "from_void_merged.txt"), "w") as f:
    f.write("\n".join(sorted(classes["cast_from_void"])))

with open(os.path.join(filepath, "to_void_merged.txt"), "w") as f:
    f.write("\n".join(sorted(classes["cast_to_void"])))

with open(os.path.join(filepath, "classes_to_instrument_unrelated.txt"), "w") as f:
    f.write("\n".join(sorted(classes["unrelated_casting_obj"])))

with open(os.path.join(filepath, "classes_to_instrument_derived.txt"), "w") as f:
    f.write("\n".join(sorted(classes["derived_casting_obj"])))

merged = sorted(classes["derived_casting_obj"].union(classes["unrelated_casting_obj"]).union(classes["casting_obj_init"].union(classes["cast_from_void"])))
with open(os.path.join(filepath, "merged.txt"), "w") as f:
    f.write("\n".join(merged))

log.info("Classes to instrument: %i", len(merged))
log.info("Unique classes in from_void: %i ", len(classes["cast_from_void"].difference(classes["derived_casting_obj"].union(classes["unrelated_casting_obj"]))))
log.info("Unique classes in to_void: %i", len(classes["cast_to_void"].difference(merged)))
log.info("Classes in from_void: %i ", len(classes["cast_from_void"]))
log.info("Classes in to_void: %i", len(classes["cast_to_void"]))
log.info("Classes in derived: %i", len(classes["derived_casting_obj"]))
log.info("Classes in unrelated: %i", len(classes["unrelated_casting_obj"]))
log.info("Unique classes in unrelated: %i", len(classes["unrelated_casting_obj"].difference(classes["derived_casting_obj"])))


[print(x) for x in merged]
