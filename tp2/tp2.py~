#!/usr/bin/python

import os
import getopt
import sys
import scripts.test_sizes_performance as TestSizes 
from settings import Options, Tests, Filtro

codeDir = "codigo/"

def build(option):
    cwd = os.getcwd()  # get current directory
    os.chdir(codeDir)

    flags = ""

    if option == Options.o1:
        flags = '-e CFLAGS64="-O1 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'
    elif option == Options.o2:
        flags = '-e CFLAGS64="-O2 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'
    elif option == Options.o3:
        flags = '-e CFLAGS64="-O3 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64"'

    command = "make" + flags
    os.system(command)  
    os.chdir(cwd)


def clean():
    cwd = os.getcwd()  # get current directory
    os.chdir(codeDir)
    os.system("make clean")
    os.chdir(cwd)

def tester(test, version, graficar):
    if test == Tests.sizesLdr or test == Tests.sizesSep or Tests.sizesSep:
        if test == Tests.sizesLdr:
            TestSizes.test(Filtro.ldr, version)
        elif test == Tests.sizesSep:
            TestSizes.test(Filtro.sepia, version)
        else:
            TestSizes.test(Filtro.cropflip, version)


def printAllInfo():
    print "tp2.py -h <help> -f <flag> -i <inputfile> -o <outputfile> -t <test> -g <graficar> \n"

def main(argv):
    inputfile = ""
    outputfile = ""
    flag = ""
    test = ""
    version = ""
    graficar = False

    try:
        opts, args = getopt.getopt(argv, "hf:i:o:t:v:g", ["help=", "flag=", "ifile=", "ofile=", "test=", "version="])
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
            print "version must be asm or c"
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
            if arg not in (Tests.cacheCropflip, Tests.clocksCf, Tests.clocksLdr, Tests.clocksSep, Tests.sizesCf,
                           Tests.sizesLdr, Tests.sizesSep, Tests.compareLdrA, Tests.compareLdrB):
                Tests.printAllInfo()
                sys.exit(2)
            test = arg
        elif opt in ("-v", "--version"):
            if arg not in ("asm", "c"):
                print "version must be asm or c"
                sys.exit(2)
            version = arg
        elif opt in ("-g"):
            graficar = True
        else:
            printAllInfo()
            Options.printAllInfo()
            Tests.printAllInfo()
            sys.exit(2)

    print "Input file is ", inputfile
    print "Output file is ", outputfile
    print "Flag is ", flag

    if flag != Options.none:
        clean()
        build(flag)

    tester(test, version, graficar)

if __name__ == "__main__":
    main(sys.argv[1:])
else:
    print("tp2.py is being imported into another module")
