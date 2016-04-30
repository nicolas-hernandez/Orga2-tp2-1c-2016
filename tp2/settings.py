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
    cacheCropflip = "cfcache"
    clocksLdr = "ldrclk"
    clocksCf = "cfclk"
    clocksSep = "sepclk"
    sizesLdr = "ldrsz"
    sizesCf = "cfsz"
    sizesSep = "sepsz"
    compareLdrA = "cmpLdrA"
    compareLdrB = "cmpLdrB"
    @staticmethod
    def printAllInfo():
        print "possible performance test are: \n"
        print "cfcache: cache cropflip test \n"
        print "ldrclk: clocks ldr test \n"
        print "cfclk: clocks cropflip test \n"
        print "sepclk: clocks sepia test \n"
        print "ldrsz: size ldr test \n"
        print "cfsz: size cropflip test \n"
        print "sepsz: size sepia test \n"
        print "cmpLdrA: compare ldr asm with c with same nums of read and write ops\n"
        print "cmpLdrB: compare ldr asm integer operations with fp operations\n"
        
class Filtro:
    cropflip = "cropflip"
    ldr = "ldr"
    sepia = "sepia"

class Params:
    alpha = 0.5
    nInst = 500 
    indInst = 1
    
