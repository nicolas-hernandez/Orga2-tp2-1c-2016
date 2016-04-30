#!/usr/bin/python

import os
import getopt
import sys
import csv
from settings import TestSizeParams as Tsp, Filtro

def test(filtro, version): 

    cwd = os.getcwd()  # get current directory

    for i in xrange(Tsp.nInst):

        os.chdir(Tsp.buildDir)
        
        command = "./tp2 -v" + filtro + "-i" + asm
        
        if filtro == Filtro.ldr:
            command = command + str(Filtro.tamX) + str(Filtro.tamY) + str(Filtro.offsetX) + str(Filtro.offsetY)
        elif filtro == Filtro.cropflip:
            command = command + str(Filtro.alpha)
        
        command = command + "-t " + str(Filtro.indInst)
                
        os.system(command)
        
    
    os.chdir(cwd)
    
