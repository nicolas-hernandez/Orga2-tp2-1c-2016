import os

class Options:
    none = "none"
    o = "o"
    o1 = "o1"
    o2 = "o2"
    o3 = "o3"
    @staticmethod
    def printAllInfo():
        print "possible flags: none (no compile), o (only make), o1, o2, o3 \n"

class Tests:
    cacheCropflip = "ccf"
    clocksLdr = "cldr"
    clocksCf = "cc"
    clocksSep = "cs"
    tamaniosLdr = "sldr"
    tamaniosCf = "sc"
    tamaniosSep = "ss"
    compareLdrA = "cmpLdrA"
    compareLdrB = "cmpLdrB"
    @staticmethod
    def printAllInfo():
        print "possible test are: \n"
        print "ccf: cache cropflip test \n"
        print "cldr: clocks ldr test \n"
        print "cc: clocks cropflip test \n"
        print "cs: clocks sepia test \n"
        print "sldr: size ldr test \n"
        print "sc: size cropflip test \n"
        print "ss: size sepia test \n"
        print "cmpLdrA: compare ldr asm with c with same nums of read and write ops\n"
        print "cmpLdrB: compare ldr asm integer operations with fp operations\n"


alpha = 0.5

nInst = 500 

indInst = 1
