#!/usr/bin/env python3
import math
from termcolor import colored

prog_names = {
    "444.namd": "NAMD",
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
}


def overhead(value, base):
    if value == -1:
        return colored("ERR", "red")
    if base != 0:

        overhead = round(((value / base) * 100) - 100, 2)
        if overhead >= 15:
            return colored("{:.2f}".format(overhead), "red")
        else:
            return "{:.2f}".format(overhead)
    else:
        return "-"


def get_avg(values):
    if -1 in values:
        return -1
    if values is None:
        return 0
    if len(values) == 0:
        return 0
    return sum(values) / len(values)

UNITS = ["", "K", "M"]

def millify(n, unit=UNITS):
    n = float(n)
    millidx = max(
        0,
        min(len(unit) - 1, int(math.floor(0 if n == 0 else math.log10(abs(n)) / 3))),
    )

    return "{:,.0f}{}".format(n / 10 ** (3 * millidx), UNITS[millidx])
