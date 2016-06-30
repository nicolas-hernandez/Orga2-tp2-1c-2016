#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import subprocess
import csv
from settings import TestSizeParams as Tsp, Filtro, ImageDetails as ImgDet, prunedMeanAndSampleVariance


def test(filtro, version, cacheMode):
	cwd = os.getcwd()  # get current directory

	print "filtro " + filtro
	print "version " + version

	versions = []

	if version == Filtro.allV:
		versions.append("asm")
		versions.append("c")
	else:
		versions.append(version)
		
	for v in versions:	
		os.chdir(Tsp.buildDir)

		# print "dir actual " + os.getcwd()

		data = []
		ids = []

		decrement = ImgDet.decrement
		width = ImgDet.width
		height = ImgDet.height
	
		for n in reversed(range(0, Tsp.cantImg)):

			size = width*height

			clocks = []

			for i in xrange(Tsp.nInst):
				
				cmd = ['./tp2', '-v', filtro, '-i', v, Tsp.pathSW + Tsp.imgName + str(n) + ".bmp"]

				if filtro == Filtro.cropflip:
					# cortamos por el tamaño de la imagen total.
					cmd.append(str(width-decrement))
					cmd.append(str(height-decrement))
					cmd.append(str(decrement))
					cmd.append(str(decrement))
				elif filtro == Filtro.ldr:
					cmd.append(str(Filtro.alpha))

				# print cmd
				cmd.append('-t')
				cmd.append(str(Tsp.indInst))
				output = subprocess.check_output(cmd)
				
				output = output.strip(' \n\t')

				# tics/pixel
				clocks.append(long(output)/float(size))
				#clocks.append(long(output))

			width += decrement
			height += decrement

			mean = prunedMeanAndSampleVariance(clocks)
			print "average is " + str(mean) + " for img " + str(n)
			data.append(mean)

			ids.append(n + 1)

		os.chdir(cwd)

		ids = list(reversed(ids)) # la imagen mas chica sera la 1 y no la de mayor indice como esta en los archivos
		#data = list(reversed(data))

		if not os.path.isdir(Tsp.tablesPath):
			os.makedirs(Tsp.tablesPath)

		with open(Tsp.tablesPath + filtro + v + cacheMode + ".csv", 'wb') as csvfile:
			writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
			writer.writerow(["img"] + ["mean"] + ["variance"])
			for id, val in zip(ids, data):
				writer.writerow([str(id)] + [str(float(val[0]))] + [str(float(val[1]))])

if __name__ == "__main__":
	test()
else:
	print("test_sizes_performance.py is being imported into another module")
