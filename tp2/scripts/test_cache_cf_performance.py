#!/usr/bin/python

import os
import subprocess
import csv
from settings import TestCacheParams as Tcp, Filtro, prunedMean


def test(version):
    cwd = os.getcwd()  # get current directory

    os.chdir(Tcp.buildDir)

    # print "dir actual " + os.getcwd()

    print "version " + version

    means = []
    sizeX = []

    tamX = Tcp.tamX
    tamY = Tcp.tamY
    offsetX = Tcp.offsetX
    offsetY = Tcp.offsetY
    endSize = Tcp.tamY
    step = Tcp.stepSize

    while tamX <= endSize:

        clocks = []
        coords = []

        for i in xrange(Tcp.nInst):
            # when program ends, cache data that could exists from the stack are invalidated.
            cmd = ['./tp2', '-v', "cropflip", '-i', version, Tcp.pathSW + Tcp.imgName + ".bmp"]

            cmd.append(str(Filtro.tamX))
            cmd.append(str(Filtro.tamY))
            cmd.append(str(Filtro.offsetX))
            cmd.append(str(Filtro.offsetY))

            # print cmd
            cmd.append('-t')
            cmd.append(str(Tcp.indInst))
            output = subprocess.check_output(cmd)

            output = output.strip(' \n\t')

            clocks.append(long(output))
            coords.append(i + 1)

        print "img " + Tcp.imgName + " " + str(tamY) + " " + str(tamX) + " has been successfully processed"

        means.append(float(prunedMean(coords, clocks)))
        # sizeX.append(tamX/float(tamY))
        sizeX.append(tamX)

        tamY-=step
        tamX+=step

    os.chdir(cwd)

    if not os.path.isdir(Tcp.tablesPath):
        os.makedirs(Tcp.tablesPath)

    with open(Tcp.tablesPath + "cropflip" + version + ".csv", 'wb') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(["tamX/tamY"] + ["mean"])
        for id, mean in zip(sizeX, means):
            writer.writerow([str(id)] + [str(mean)])

if __name__ == "__main__":
    test()
else:
    print("test_sizes_performance.py is being imported into another module")
