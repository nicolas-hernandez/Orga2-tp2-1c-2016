#!/usr/bin/env python

from libtest import *
import subprocess
import sys

# Este script crea las multiples imagenes de prueba a partir de unas
# pocas imagenes base.


IMAGENES=["starWars.bmp"]

assure_dirs()

sizes=['3740x2060', '3640x1960', '3540x1860', '3440x1760', '3340x1660', '3240x1560', '3140x1460', '3040x1360', '2940x1260', '2840x1160', '2740x1060', '2640x960', '2540x860', '2440x760', '2340x660', '2240x560', '2140x460', '2040x360', '1940x260', '1840x160', '1740x60']

i = 0

for filename in IMAGENES:
	print(filename)
    
	for size in sizes:
		sys.stdout.write("  " + size)
		name = filename.split('.')
		file_in  = DATADIR + "/" + filename
		file_out = TESTINDIR + "/" + name[0] + "." + str(i) + "." + name[1]
		resize = "convert -resize " + size + "! " + file_in + " " + file_out
		subprocess.call(resize, shell=True)
        i+=1

print("")
