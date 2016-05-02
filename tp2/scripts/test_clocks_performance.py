#!/usr/bin/python

import os
import subprocess
import csv
from settings import TestClocksParams as Tcp, Filtro, Tests, prunedMean


def test(test, version): # test would be A or B.
    cwd = os.getcwd()  # get current directory

    os.chdir(Tcp.buildDir)

    # print "dir actual " + os.getcwd()

    typeCodes = []

    if version == "c_o0" or version == "c_o3":
        typeCodes.append("c")
    else:
        typeCodes.append("asm")

    means = []

    for tc in typeCodes:

        clocks = []
        coords = []

        for i in xrange(Tcp.nInst):
            # when program ends, cache data that could exists from the stack are invalidated.
            cmd = ['./tp2', '-v', 'ldr', '-i', tc, Tcp.pathSW + Tcp.imgName + ".bmp"]

            cmd.append(str(Filtro.alpha))

            # print cmd
            cmd.append('-t')
            cmd.append(str(Tcp.indInst))
            output = subprocess.check_output(cmd)

            output = output.strip(' \n\t')

            clocks.append(long(output))
            coords.append(i + 1)

        print "img " + Tcp.imgName + " has been successfully processed"

        means.append(float(prunedMean(coords, clocks)))

    os.chdir(cwd)

    if not os.path.isdir(Tcp.tablesPath + test):
        os.makedirs(Tcp.tablesPath + test)

    with open(Tcp.tablesPath + test + '/' + version + '.csv', 'wb') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(["type code"] + ["mean"])
        for v, mean in zip([version], means):
            writer.writerow([v] + [str(mean)])

if __name__ == "__main__":
    test()
else:
    print("test_sizes_performance.py is being imported into another module")
