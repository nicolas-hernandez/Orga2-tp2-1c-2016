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
	meanAsm_o = 0
	errorAsm_o = 0
	meanAsm_2 = 0
	errorAsm_o = 0

	with open(Tep.tablesPath + filtro + letter + "_o" + ".csv", 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		for row in reader:  
			if row[0] == "asm":
				meanAsm_o = float(row[1])
				errorAsm_o = float(row[2]) 
	with open(Tep.tablesPath + filtro + letter + "_2" + ".csv", 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		for row in reader:	  
			if row[0] == "asm":
				meanAsm_2 = float(row[1])
				errorAsm_2 = float(row[2])

	objects = ('Asm float point ops', 'Asm integer ops')
	x_pos = np.arange(len(objects))
	performance = [meanAsm_o, meanAsm_2]
	errors = [errorAsm_o, errorAsm_2]
	
	fig = plt.figure()
	sub = fig.add_subplot(1, 1, 1)
	 
	sub.bar(x_pos, performance, align='center', color='r', alpha=0.5, yerr=errors)
	plt.xticks(x_pos, objects)
	plt.ylabel('$Clocks/Pixel$ $insumidos$')
	plt.title('Asm float point ops vs. Asm integer ops')
	plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0))
	 
	if not os.path.isdir(Tep.graphsPath):
		os.makedirs(Tep.graphsPath)

	fig.savefig(Tep.graphsPath + filtro + letter + ".pdf")
	plt.close(fig)
