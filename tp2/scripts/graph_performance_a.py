#!/usr/bin/python
# coding=utf-8
# plt.xkcd()

import os
import subprocess
import csv
from settings import TestExtraParams as Tep, Filtro
import matplotlib.pyplot as plt
import numpy as np
import math

def graph(filtro, letter):
	meanAsm = 0
	errorAsm = 0
	meanC = 0
	errorC = 0

	with open(Tep.tablesPath + filtro + letter + ".csv", 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		for row in reader:		
			if row[0] == "c":
				meanC = float(row[1])
				errorC = float(row[2])
			elif row[0] == "asm":
				meanAsm = float(row[1])
				errorAsm = float(row[2])

	avgAsm = int((meanC / float(meanAsm))*100)

	objects = ('Asm: ' + str(avgAsm) + '%', 'C flag O0')
	x_pos = np.arange(len(objects))
	performance = [meanAsm, meanC]
	errors = [errorAsm, errorC]
	
	fig = plt.figure()
	sub = fig.add_subplot(1, 1, 1)
	 
	sub.bar(x_pos, performance, align='center', color='r', alpha=0.5, yerr=errors)
	plt.xticks(x_pos, objects)
	plt.ylabel('$Clocks/Pixel$ $insumidos$')
	plt.title('Asm vs. C flag O0')
	plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0))
	 
	if not os.path.isdir(Tep.graphsPath):
		os.makedirs(Tep.graphsPath)

	fig.savefig(Tep.graphsPath + filtro + letter + ".pdf")
	plt.close(fig)
