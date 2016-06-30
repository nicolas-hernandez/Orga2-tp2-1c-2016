#!/usr/bin/python
# coding=utf-8
# plt.xkcd()

import os
import subprocess
import csv
from settings import TestClocksParams as Tcp, Filtro
import matplotlib.pyplot as plt
import numpy as np
import math


def graph(filtro, file1, file2, file3):
	meanAsm = 0
	meanC_oi = 0
	meanC_o3 = 0
	errorAsm = 0
	errorC_oi = 0
	errorC_o3 = 0

	with open(Tcp.tablesPath + filtro + file1 + ".csv", 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		for row in reader:		
			if row[0] == 'asm':
				meanAsm = float(row[1])
				errorAsm = float(row[2])
	with open(Tcp.tablesPath + filtro + file2 + ".csv", 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		for row in reader:		
			if row[0] == 'c':
				meanC_oi = float(row[1])
				errorC_oi = float(row[2]) 
	with open(Tcp.tablesPath + filtro + file3 + ".csv", 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		for row in reader:	
			if row[0] == 'c':
				meanC_o3 = float(row[1])
				errorC_o3 = float(row[2])	

	avgAsm = int((meanC_oi / float(meanAsm))*100)
	avgO3 = int((meanC_oi / float(meanC_o3))*100)

	objects = ('Asm: ' + str(avgAsm) + '%' , 'C flag O3: ' + str(avgO3) + '%', 'C flag O1')
	x_pos = np.arange(len(objects))
	performance = [meanAsm, meanC_o3, meanC_oi]
	errors = [errorAsm, errorC_o3, errorC_oi]
	
	fig = plt.figure()
	sub = fig.add_subplot(1, 1, 1)
	 
	sub.bar(x_pos, performance, align='center', color='r', alpha=0.5, yerr=errors)
	#sub.errorbar(x_pos, performance, yerr=errors, fmt='o')	
	plt.xticks(x_pos, objects)
	plt.ylabel('$Clocks/Pixel$ $insumidos$')
	plt.title(filtro + ' Asm vs. C flag O3 vs. C flag O1')
	plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0))
	 
	if not os.path.isdir(Tcp.graphsPath):
		os.makedirs(Tcp.graphsPath)

	fig.savefig(Tcp.graphsPath + filtro + 'Clocks' + ".pdf")
	plt.close(fig)
