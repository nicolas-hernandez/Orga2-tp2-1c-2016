#!/usr/bin/python

import os
import getopt
import sys
import scripts.test_sizes_performance as test_sizes
import scripts.graph_sizes_performance as graph_sizes
import scripts.graph_cache_performance as graph_cache
import scripts.test_performance_a as test_a
import scripts.graph_performance_a as graph_a
import scripts.test_performance_b as test_b
import scripts.graph_performance_b as graph_b
import scripts.test_clocks_performance as test_clocks
import scripts.graph_clocks_performance as graph_clocks
from settings import Options, Tests, Filtro, TestExtraParams as Tep, TestSizeParams as Tsp

codeDir = "codigo/"


def build(option, test, change):
    cwd = os.getcwd()  # get current directory
    os.chdir(codeDir)

    if test == Tests.compareLdrA:
        os.system("mv filtros/ldr_asm.asm filtros/" + Tep.ldr_asm_name_o)
        os.system("mv filtros/" + Tep.ldr_asm_name_a + " filtros/ldr_asm.asm")
    elif test == Tests.compareLdrB:
        if change:
            os.system("mv filtros/ldr_asm.asm filtros/" + Tep.ldr_asm_name_o)
            os.system("mv filtros/" + Tep.ldr_asm_name_b + " filtros/ldr_asm.asm")
    elif test == Tests.compareSepiaB:
        if change:
            os.system("mv filtros/sepia_asm.asm filtros/" + Tep.sepia_asm_name_o)
            os.system("mv filtros/" + Tep.sepia_asm_name_b + " filtros/sepia_asm.asm")

    flags = ""
    
    if option == Options.o:
        flags = ' -e CFLAGS64="-O0 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'
    elif option == Options.o1:
        flags = ' -e CFLAGS64="-O1 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'
    elif option == Options.o2:
        flags = ' -e CFLAGS64="-O2 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'
    elif option == Options.o3:
        flags = ' -e CFLAGS64="-O3 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'

    command = "make" + flags
    os.system(command)

    if test == Tests.compareLdrA:
        os.system("mv filtros/ldr_asm.asm filtros/" + Tep.ldr_asm_name_a)
        os.system("mv filtros/" + Tep.ldr_asm_name_o + " filtros/ldr_asm.asm")
    elif test == Tests.compareLdrB:
        if change:
            os.system("mv filtros/ldr_asm.asm filtros/" + Tep.ldr_asm_name_b)
            os.system("mv filtros/" + Tep.ldr_asm_name_o + " filtros/ldr_asm.asm")
    elif test == Tests.compareSepiaB:
        if change:
            os.system("mv filtros/sepia_asm.asm filtros/" + Tep.sepia_asm_name_b)
            os.system("mv filtros/" + Tep.sepia_asm_name_o + " filtros/sepia_asm.asm")

    os.chdir(cwd)

def clean():
    cwd = os.getcwd()  # get current directory
    os.chdir(codeDir)
    os.system("make clean")
    os.chdir(cwd)

def callBuild(flag, test, change):
    if flag != Options.none:
        clean()
        build(flag, test, change)

def tester(test, version):
    #testear
    
    if test == Tests.sizesLdrCold:
        callBuild(Options.o1, test, False)
        test_sizes.test(Filtro.ldr, version, Tsp.coldCache)
    elif test == Tests.sizesSepCold:
        callBuild(Options.o1, test, False)
        test_sizes.test(Filtro.sepia, version, Tsp.coldCache)
    elif test == Tests.sizesCfCold:
        callBuild(Options.o1, test, False)
        test_sizes.test(Filtro.cropflip, version, Tsp.coldCache)

    if test == Tests.sizesLdrHot:
        callBuild(Options.o1, test, False)
        test_sizes.test(Filtro.ldr, version, Tsp.hotCache)
    elif test == Tests.sizesSepHot:
        callBuild(Options.o1, test, False)
        test_sizes.test(Filtro.sepia, version, Tsp.hotCache)
    elif test == Tests.sizesCfHot:
        callBuild(Options.o1, test, False)
        test_sizes.test(Filtro.cropflip, version, Tsp.hotCache)

    if test == Tests.clocksLdr:
        callBuild(Options.o1, test, False)
        test_clocks.test(Filtro.ldr, "c_o1")
        test_clocks.test(Filtro.ldr, "asm")
        callBuild(Options.o3, test, False)
        test_clocks.test(Filtro.ldr, "c_o3")
    elif test == Tests.clocksSep:
        callBuild(Options.o1, test, False)
        test_clocks.test(Filtro.sepia, "c_o1")
        test_clocks.test(Filtro.sepia, "asm")
        callBuild(Options.o3, test, False)
        test_clocks.test(Filtro.sepia, "c_o3")
    elif test == Tests.clocksCf:
        callBuild(Options.o1, test, False)
        test_clocks.test(Filtro.cropflip, "c_o1")
        test_clocks.test(Filtro.cropflip, "asm")
        callBuild(Options.o3, test, False)
        test_clocks.test(Filtro.cropflip, "c_o3")

    letter = "A"
    if test == Tests.compareLdrA:
        callBuild(Options.o1, test, False)
        test_a.test(Filtro.ldr, letter)
    elif test == Tests.compareLdrB:
        callBuild(Options.o1, test, False)
        letter = "B_o"
        test_b.test(Filtro.ldr, letter)
        
        callBuild(Options.o1, test, True)
        letter = "B_2"
        test_b.test(Filtro.ldr, letter)
    elif test == Tests.compareSepiaB:
        callBuild(Options.o1, test, False)
        letter = "B_o"
        test_b.test(Filtro.sepia, letter)
        
        callBuild(Options.o1, test, True)
        letter = "B_2"
        test_b.test(Filtro.sepia, letter)

    #graficar letter = 'A'
    if test == Tests.sizesLdrCold:
        graph_sizes.graph(Filtro.ldr, version)
    elif test == Tests.sizesSepCold:
        graph_sizes.graph(Filtro.sepia, version)
    elif test == Tests.sizesCfCold:
        graph_sizes.graph(Filtro.cropflip, version)

    if test == Tests.sizesLdrHot:
        graph_cache.graph(Filtro.ldr, 'asm')
        #graph_cache.graph(Filtro.ldr, 'c')\t\t\t
    elif test == Tests.sizesSepHot:
        graph_cache.graph(Filtro.sepia, 'asm')
        #graph_cache.graph(Filtro.sepia, 'c')
    elif test == Tests.sizesCfHot:
        graph_cache.graph(Filtro.cropflip, 'asm')
        #graph_cache.graph(Filtro.cropflip, 'c')

    if test == Tests.compareLdrA:
        graph_a.graph(Filtro.ldr, letter)
    elif test == Tests.compareLdrB:
        letter = "B"
        graph_b.graph(Filtro.ldr, letter)
    elif test == Tests.compareSepiaB:
        letter = "B"
        graph_b.graph(Filtro.sepia, letter) 
    elif test == Tests.clocksLdr:
        graph_clocks.graph(Filtro.ldr, "asm", "c_o1", "c_o3")
    elif test == Tests.clocksSep:
        graph_clocks.graph(Filtro.sepia, "asm", "c_o1", "c_o3")
    elif test == Tests.clocksCf:
        graph_clocks.graph(Filtro.cropflip, "asm", "c_o1", "c_o3")

def printAllInfo():
    print "tp2.py -h <help> -t <test> -v <version> \n"


def main(argv):
    inputfile = ""
    outputfile = ""
    flag = ""
    test = ""
    version = ""
    graficar = False

    try:
        opts, args = getopt.getopt(argv, "ht:v:", ["help=", "test=", "version="])
    except getopt.GetoptError:
        printAllInfo()
        sys.exit(2)
    if len(opts) == 0:
        printAllInfo()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            printAllInfo()
            Options.printAllInfo()
            Tests.printAllInfo()
            print "version must be asm, c or all"
            print "-g for plot"
            sys.exit()
        elif opt in ("-t", "--test"):
            if int(arg) not in (Tests.nothing, Tests.clocksLdr, Tests.clocksCf, Tests.clocksSep, Tests.sizesLdrCold,
                           Tests.sizesCfCold, Tests.sizesSepCold, Tests.compareLdrA, Tests.compareLdrB, Tests.compareSepiaB, Tests.sizesLdrHot, Tests.sizesCfHot, Tests.sizesSepHot):
                Tests.printAllInfo()
                sys.exit(2)
            test = int(arg)
        elif opt in ("-v", "--version"):
            if arg not in ("asm", "c", "all"):
                print "version must be asm, c or all"
                sys.exit(2)
            version = arg
        else:
            printAllInfo()
            Options.printAllInfo()
            Tests.printAllInfo()
            print "version must be asm, c or all"
            sys.exit(2)

    tester(test, version)

if __name__ == "__main__":
    main(sys.argv[1:])
else:
    print("tp2.py is being imported into another module")
