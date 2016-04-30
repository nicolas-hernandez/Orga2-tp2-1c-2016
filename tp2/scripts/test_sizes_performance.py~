#!/usr/bin/python

import os
import subprocess
import getopt
import sys
import csv
from settings import TestSizeParams as Tsp, Filtro

def test(filtro, version): 
    cwd = os.getcwd()  # get current directory
 
    os.chdir(Tsp.buildDir)
    
    #print "dir actual " + os.getcwd()
    
    for i in xrange(Tsp.nInst):       
        for n in range(0, Tsp.cantImg):
            cmd = ['./tp2', '-v', filtro, '-i' , version,  Tsp.pathSW + Tsp.imgName + str(n) + ".bmp"]
             
            if filtro == Filtro.cropflip:
                cmd.append(str(Filtro.tamX))
                cmd.append(str(Filtro.tamY))
                cmd.append(str(Filtro.offsetX))
                cmd.append(str(Filtro.offsetY)) 
            elif filtro == Filtro.ldr:
                cmd.append(str(Filtro.alpha))
            
            #print cmd
            cmd.append('-t')
            cmd.append(str(Tsp.indInst))
            output = subprocess.check_output(cmd)
          
            print output
           
    os.chdir(cwd)
    
if __name__ == "__main__":
    test()
else:
    print("test_sizes_performance.py is being imported into another module")
