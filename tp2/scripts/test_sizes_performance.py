#!/usr/bin/python

import os
import subprocess
import csv
from settings import TestSizeParams as Tsp, Filtro, prunedMean


def test(filtro, version):
    cwd = os.getcwd()  # get current directory

    os.chdir(Tsp.buildDir)

    # print "dir actual " + os.getcwd()

    print "filtro " + filtro
    print "version " + version

    means = []
    ids = []

    for n in range(0, Tsp.cantImg):

        clocks = []
        coords = []

        for i in xrange(Tsp.nInst):
            # when program ends, cache data that could exists from the stack are invalidated.
            cmd = ['./tp2', '-v', filtro, '-i', version, Tsp.pathSW + Tsp.imgName + str(n) + ".bmp"]

            if filtro == Filtro.cropflip:
                cmd.append(str(Filtro.tamX))
                cmd.append(str(Filtro.tamY))
                cmd.append(str(Filtro.offsetX))
                cmd.append(str(Filtro.offsetY))
            elif filtro == Filtro.ldr:
                cmd.append(str(Filtro.alpha))

            # print cmd
            cmd.append('-t')
            cmd.append(str(Tsp.indInst))
            output = subprocess.check_output(cmd)

            output = output.strip(' \n\t')

            clocks.append(long(output))
            coords.append(i + 1)

        print "img " + Tsp.imgName + str(n) + " has been successfully processed"

        means.append(float(prunedMean(coords, clocks)))
        ids.append(n + 1)

    os.chdir(cwd)

    if not os.path.isdir(Tsp.tablesPath):
        os.makedirs(Tsp.tablesPath)

    with open(Tsp.tablesPath + filtro + version + ".csv", 'wb') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(["img"] + ["mean"])
        for id, mean in zip(ids, means):
            writer.writerow([str(id)] + [str(mean)])

if __name__ == "__main__":
    test()
else:
    print("test_sizes_performance.py is being imported into another module")
