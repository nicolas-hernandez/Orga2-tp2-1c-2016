#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import subprocess
import csv
from settings import TestExtraParams as Tep, Filtro, ImageDetails as ImgDet, prunedMeanAndSampleVariance


def test(filtro, letter):
	cwd = os.getcwd()  # get current directory

	os.chdir(Tep.buildDir)

	# print "dir actual " + os.getcwd()

	typeCodes = ["asm"]

	data = []
	
	size = 512*512

	for tc in typeCodes:

		clocks = []

		for i in xrange(Tep.nInst):

			cmd = ['./tp2', '-v', filtro, '-i', tc, Tep.pathSW + Tep.imgName + ".bmp"]

			if filtro == Filtro.ldr:
				cmd.append(str(Filtro.alpha))

			# print cmd
			cmd.append('-t')
			cmd.append(str(Tep.indInst))
			output = subprocess.check_output(cmd)

			output = output.strip(' \n\t')

			clocks.append(long(output)/float(size))

		print "img " + Tep.imgName + " has been successfully processed"

		data.append(prunedMeanAndSampleVariance(clocks))

	os.chdir(cwd)

	if not os.path.isdir(Tep.tablesPath):
		os.makedirs(Tep.tablesPath)

	with open(Tep.tablesPath + filtro + letter + '.csv', 'wb') as csvfile:
		writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
		writer.writerow(["type code"] + ["mean"] + ["variance"])
		for tc, val in zip(typeCodes, data):
			writer.writerow([tc] + [str(float(val[0]))] + [str(float(val[1]))])

if __name__ == "__main__":
	test()
else:
	print("test_performance_b.py is being imported into another module")
