import sys
import os
import collections

class AllocationInfo:
    objName = ""

filepath = sys.argv[1]
normal_set = set([""])
allocation = []
poly = 0
nonpoly = 0
stand = 0
nonstand = 0

with open(filepath, 'r') as f:
    data = f.readlines()
    for line in data:
        words = line.split()
        if (len(words) > 0):
            allocation.append(words[0])
            normal_set.add(words[0])
            if (words[1] == "1"):
                poly = poly+1
            else:
                nonpoly = nonpoly+1
                if (words[2] == "1"):
                    stand = stand+1
                else:
                    nonstand = nonstand+1
            
print str(len(allocation)) + " " + str(len(normal_set)) + " " + str(poly) + " " + str(nonpoly) + " " + str(stand) + " " + str(nonstand)
