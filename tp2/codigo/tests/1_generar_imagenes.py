#!/usr/bin/env python

from libtest import *
import subprocess
import sys

# Este script crea las multiples imagenes de prueba a partir de unas
# pocas imagenes base.


IMAGENES=["starWars.bmp"]

assure_dirs()

sizes=['3640x2060', '3440x1960', '3240x1860', '3040x1760', '2840x1660', '2640x1560', '2440x1460', '2240x1360', '2040x1260', '1840x1160', '1640x1060', '1440x960', '1240x860', '1040x760', '840x660', '640x560', '440x360', '240x160', '140x60']


for filename in IMAGENES:
	print(filename)

	for size in sizes:
		sys.stdout.write("  " + size)
		name = filename.split('.')
		file_in  = DATADIR + "/" + filename
		file_out = TESTINDIR + "/" + name[0] + "." + size + "." + name[1]
		resize = "convert -resize " + size + "! " + file_in + " " + file_out
		subprocess.call(resize, shell=True)

print("")
