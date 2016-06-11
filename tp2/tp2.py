#!/usr/bin/python

import os
import getopt
import sys
import scripts.test_sizes_performance as test_sizes
import scripts.graph_sizes_performance as graph_sizes
import scripts.test_cache_cf_performance as test_cache
import scripts.graph_cache_cf_performance as graph_cache
import scripts.test_ldr_performance_a as test_ldr_a
import scripts.graph_ldr_performance_a as graph_ldr_a
import scripts.test_ldr_performance_b as test_ldr_b
import scripts.graph_ldr_performance_b as graph_ldr_b
import scripts.test_clocks_performance as test_clocks
import scripts.graph_clocks_performance as graph_clocks
from settings import Options, Tests, Filtro, TestLdrParams as Tlp

codeDir = "codigo/"


def build(option, test, change):
    cwd = os.getcwd()  # get current directory
    os.chdir(codeDir)

    if test == Tests.compareLdrA:
        os.system("mv filtros/ldr_asm.asm filtros/" + Tlp.asm_name_o)
        os.system("mv filtros/" + Tlp.asm_name_a + " filtros/ldr_asm.asm")
    elif test == Tests.compareLdrB:
        if change:
            os.system("mv filtros/ldr_asm.asm filtros/" + Tlp.asm_name_o)
            os.system("mv filtros/" + Tlp.asm_name_b + " filtros/ldr_asm.asm")

    flags = ""

    if option == Options.o1:
        flags = ' -e CFLAGS64="-O1 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'
    elif option == Options.o2:
        flags = ' -e CFLAGS64="-O2 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'
    elif option == Options.o3:
        flags = ' -e CFLAGS64="-O3 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'

    command = "make" + flags
    os.system(command)

    if test == Tests.compareLdrA:
        os.system("mv filtros/ldr_asm.asm filtros/" + Tlp.asm_name_a)
        os.system("mv filtros/" + Tlp.asm_name_o + " filtros/ldr_asm.asm")
    elif test == Tests.compareLdrB:
        if change:
            os.system("mv filtros/ldr_asm.asm filtros/" + Tlp.asm_name_b)
            os.system("mv filtros/" + Tlp.asm_name_o + " filtros/ldr_asm.asm")

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

def tester(test, version, graficar, flag):
    if test == Tests.sizesLdr:
        callBuild(flag, test, False)
        test_sizes.test(Filtro.ldr, version)
    elif test == Tests.sizesSep:
        callBuild(flag, test, False)
        test_sizes.test(Filtro.sepia, version)
    elif test == Tests.sizesCf:
        callBuild(flag, test, False)
        test_sizes.test(Filtro.cropflip, version)

    if test == Tests.clocksLdr:
        callBuild(Options.o, test, False)
        test_clocks.test(Filtro.ldr, "asm")
        test_clocks.test(Filtro.ldr, "c_o0")
        callBuild(Options.o3, test, False)
        test_clocks.test(Filtro.ldr, "c_o3")
    elif test == Tests.clocksSep:
        callBuild(Options.o, test, False)
        test_clocks.test(Filtro.sepia, "asm")
        test_clocks.test(Filtro.sepia, "c_o0")
        callBuild(Options.o3, test, False)
        test_clocks.test(Filtro.sepia, "c_o3")
    elif test == Tests.clocksCf:
        callBuild(Options.o, test, False)
        test_clocks.test(Filtro.cropflip, "asm")
        test_clocks.test(Filtro.cropflip, "c_o0")
        callBuild(Options.o3, test, False)
        test_clocks.test(Filtro.cropflip, "c_o3")

    if test == Tests.cacheCropflip:
        callBuild(test, flag, False)
        test_cache.test(version)

    letter = "A"
    if test == Tests.compareLdrA:
        callBuild(flag, test, False)
        test_ldr_a.test(letter)
    elif test == Tests.compareLdrB:
        callBuild(flag, test, False)
        letter = "B_o"
        test_ldr_b.test(letter)
        
        callBuild(flag, test, True)
        letter = "B_2"
        test_ldr_b.test(letter)
        
    if graficar:
        if test == Tests.sizesLdr:
            graph_sizes.graph(Filtro.ldr, version)
        elif test == Tests.sizesSep:
            graph_sizes.graph(Filtro.sepia, version)
        elif test == Tests.sizesCf:
            graph_sizes.graph(Filtro.cropflip, version)
        elif test == Tests.cacheCropflip:
            graph_cache.graph(version)
        elif test == Tests.compareLdrA:
            graph_ldr_a.graph(letter)
        elif test == Tests.compareLdrB:
            letter = "B"
            graph_ldr_b.graph(letter)
        elif test == Tests.clocksLdr:
            graph_clocks.graph(Filtro.ldr, "asm", "c_o0", "c_o3")
        elif test == Tests.clocksSep:
            graph_clocks.graph(Filtro.sepia, "asm", "c_o0", "c_o3")
        elif test == Tests.clocksCf:
            graph_clocks.graph(Filtro.cropflip, "asm", "c_o0", "c_o3")

def printAllInfo():
    print "tp2.py -h <help> -f <flag> -i <inputfile> -o <outputfile> -t <test> -v <version> -g <graficar> \n"


def main(argv):
    inputfile = ""
    outputfile = ""
    flag = ""
    test = ""
    version = ""
    graficar = False

    try:
        opts, args = getopt.getopt(argv, "hf:i:o:t:v:ga", ["help=", "flag=", "ifile=", "ofile=", "test=", "version="])
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
        elif opt in ("-i", "--ifile"):
            if arg == "":
                arg = "in.txt"
            inputfile = arg
        elif opt in ("-o", "--ofile"):
            if arg == "":
                arg = "out.txt"
            outputfile = arg
        elif opt in ("-f", "--flag"):
            if arg not in (Options.none, Options.o, Options.o1, Options.o2, Options.o3):
                Options.printAllInfo()
                sys.exit(2)
            flag = arg
        elif opt in ("-t", "--test"):
            if int(arg) not in (Tests.nothing, Tests.cacheCropflip, Tests.clocksLdr, Tests.clocksCf, Tests.clocksSep, Tests.sizesLdr,
                           Tests.sizesCf, Tests.sizesSep, Tests.compareLdrA, Tests.compareLdrB):
                Tests.printAllInfo()
                sys.exit(2)
            test = int(arg)
        elif opt in ("-v", "--version"):
            if arg not in ("asm", "c", "all"):
                print "version must be asm, c or all"
                sys.exit(2)
            version = arg
        elif opt in "-g":
            graficar = True
        else:
            printAllInfo()
            Options.printAllInfo()
            Tests.printAllInfo()
            print "version must be asm, c or all"
            print "-g for plot"
            sys.exit(2)

    print "Input file is ", inputfile
    print "Output file is ", outputfile
    print "Flag is ", flag

    tester(test, version, graficar, flag)

if __name__ == "__main__":
    main(sys.argv[1:])
else:
    print("tp2.py is being imported into another module")
