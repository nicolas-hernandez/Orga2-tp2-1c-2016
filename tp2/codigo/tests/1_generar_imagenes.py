#!/usr/bin/env python

from libtest import *
import subprocess
import sys

# Este script crea las multiples imagenes de prueba a partir de unas
# pocas imagenes base.


IMAGENES=["lena32.bmp"]

assure_dirs()

size = '1224x1224'

i = 0

for filename in IMAGENES:
	print(filename)

	name = filename.split('.')

	decrement = 16

	widthAndHeight = size.split('x')
	width = int(widthAndHeight[0])
	height = int(widthAndHeight[1])

	while width > 16:
		sys.stdout.write("  " + size)
		file_in  = DATADIR + "/" + filename
		file_out = TESTINDIR + "/" + name[0] + str(i) + "." + name[1]
		resize = "convert -resize " + str(width) + 'x' + str(height) + "! " + file_in + " " + file_out
		subprocess.call(resize, shell=True)
		width -= decrement
		if height - decrement > 5:
			height -= decrement
		i+=1

print("")
