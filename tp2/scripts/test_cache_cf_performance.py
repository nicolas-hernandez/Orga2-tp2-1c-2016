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
            
            cmdCG = ['valgrind', '--tool={0}'.format('cachegrind'), './tp2', '-v', "cropflip", '-i', version, Tcp.pathSW + Tcp.imgName + ".bmp"]

            cmd.append(str(Filtro.tamX))
            cmd.append(str(Filtro.tamY))
            cmd.append(str(Filtro.offsetX))
            cmd.append(str(Filtro.offsetY))

            # print cmd
            cmd.append('-t')
            cmd.append(str(Tcp.indInst))
                    
            cmdCG.append(str(Filtro.tamX))
            cmdCG.append(str(Filtro.tamY))
            cmdCG.append(str(Filtro.offsetX))
            cmdCG.append(str(Filtro.offsetY))

            # print cmd
            cmdCG.append('-t')
            cmdCG.append(str(Tcp.indInst))

            output = subprocess.check_output(cmd)

            output = output.strip(' \n\t')
            
            print output
            
            f = open("cache.txt", "wb")
            outputCG = subprocess.call(cmdCG, stdout=f)
            
            # outputCG = outputCG.strip(' \n\t')
            
            # print "CON RUIDO " + outputCG
            
            clocks.append(long(output))
            coords.append(i + 1)
            
                
        print "img " + Tcp.imgName + " " + str(tamY) + " " + str(tamX) + " has been successfully processed"
        
        means.append(float(prunedMean(coords, clocks)))
        # sizeX.append(tamX/float(tamY))
        sizeX.append(tamX)
        
        tamY-=step
        tamX+=step

    # os.system("history | tee logfile.txt")

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
