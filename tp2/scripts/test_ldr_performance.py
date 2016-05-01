#!/usr/bin/python

import os
import subprocess
import csv
from settings import TestLdrParams as Tlp, Filtro, Tests, prunedMean


def test(test): # test would be A or B.
    cwd = os.getcwd()  # get current directory

    os.chdir(Tlp.buildDir)

    # print "dir actual " + os.getcwd()

    typeCodes = ["asm", "c"]

    means = []

    for tc in typeCodes:

        clocks = []
        coords = []

        for i in xrange(Tlp.nInst):
            # when program ends, cache data that could exists from the stack are invalidated.
            cmd = ['./tp2', '-v', 'ldr', '-i', tc, Tlp.pathSW + Tlp.imgName + ".bmp"]

            cmd.append(str(Filtro.alpha))

            # print cmd
            cmd.append('-t')
            cmd.append(str(Tlp.indInst))
            output = subprocess.check_output(cmd)

            output = output.strip(' \n\t')

            clocks.append(long(output))
            coords.append(i + 1)

        print "img " + Tlp.imgName + " has been successfully processed"

        means.append(float(prunedMean(coords, clocks)))

    os.chdir(cwd)

    if not os.path.isdir(Tlp.tablesPath + test):
        os.makedirs(Tlp.tablesPath + test)

    with open(Tlp.tablesPath + test + '/ldr' + '.csv', 'wb') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(["type code"] + ["mean"])
        for tc, mean in zip(typeCodes, means):
            writer.writerow([tc] + [str(mean)])

if __name__ == "__main__":
    test()
else:
    print("test_sizes_performance.py is being imported into another module")
