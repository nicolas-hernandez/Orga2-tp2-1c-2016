#!/usr/bin/env python

from libtest import *
import subprocess
import sys

# Este script crea las multiples imagenes de prueba a partir de unas
# pocas imagenes base.


IMAGENES=["starWars.bmp"]

assure_dirs()

sizes=['3740x2160', '3640x2160', '3540x2160', '3440x2160', '3340x2160', '3240x2160', '3140x2160', '3040x2160', '2940x2160', '2840x2160', '2740x2160', '2640x2160', '2540x2160', '2440x2160', '2340x2160', '2240x2160', '2140x2160', '2040x2160', '1940x2160', '1840x2160', '1740x2160', '1640x2160', '1540x2160', '1440x2160', '1340x2160', '1240x2160', '1140x2160', '1040x2160', '940x2160', '840x2160', '740x2160', '640x2160', '540x2160', '440x2160', '340x2160', '240x2160', '140x2160', '40x2160']

i = len(sizes)-1

for filename in IMAGENES:
	print(filename)

	for size in sizes:
		sys.stdout.write("  " + size)
		name = filename.split('.')
		file_in  = DATADIR + "/" + filename
		file_out = TESTINDIR + "/" + name[0] + str(i) + "." + name[1]
		i-=1
		resize = "convert -resize " + size + "! " + file_in + " " + file_out
		subprocess.call(resize, shell=True)

print("")
