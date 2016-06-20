#!/usr/bin/python
# coding=utf-8
# plt.xkcd()

import os
import subprocess
import csv
from settings import TestSizeParams as Tsp, Filtro
import matplotlib.pyplot as plt
import math


def graph(filtro, version):
	ids = []
	means = []
	errors = []
	means2 = []
	errors2 = []
	max = 0

	with open(Tsp.tablesPath + filtro + version + 'Cold' + ".csv", 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		for row in reader:
			if row[0] != 'img':
				if float(row[1]) > max:
					max = float(row[1])

				ids.append(int(row[0]))
				means.append(float(row[1]))
				errors.append(float(row[2]))

	with open(Tsp.tablesPath + filtro + version + 'Hot' + ".csv", 'rb') as csvfile:
		reader = csv.reader(csvfile, delimiter=',')
		for row in reader:
			if row[0] != 'img':
				if float(row[1]) > max:
					max = float(row[1])

				means2.append(float(row[1]))
				errors2.append(float(row[2]))
	'''
	means = [math.log(e) for e in means]
	
	means2 = [math.log(e) for e in means2]
	'''
	fig = plt.figure()
	sub = fig.add_subplot(1, 1, 1)

	#sub.scatter(ids, means, color='blue', edgecolor='black', label='Cold Cache')
	cold_cache, = sub.plot(ids, means, '.', linewidth=2, color='blue', label='Cold Cache')
	sub.errorbar(ids, means, yerr=errors, fmt='.')

	#sub.scatter(ids, means2, color='red', edgecolor='black', label='Hot Cache')
	hot_cache, = sub.plot(ids, means2, 'x', linewidth=2, color='red', label='Hot Cache')
	sub.errorbar(ids, means2, yerr=errors2, fmt='x')
	#plt.legend(loc='upper left', scatterpoints=1)
	plt.legend(handles=[cold_cache, hot_cache], loc='upper left')

	offset = 20.0
	if filtro == Filtro.sepia:
		offset = 2.0

	totalY = max+offset
		
	plt.axis([0.0, Tsp.cantImg + 5.0, 0.0, totalY])
	plt.xlabel("$Tama\~{n}o$ $imagen$")
	plt.ylabel("$Clocks/Pixel$ $insumidos$")
	if version == Filtro.allV:
		plt.title("$Clocks/Pixel$ insumidos " + filtro + " por imagen")
	else:
		plt.title("$Clocks/Pixel$ insumidos " + filtro + " " + version + " por imagen")
	plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0)) # for both axis use both

	if not os.path.isdir(Tsp.graphsPath):
		os.makedirs(Tsp.graphsPath)

	fig.savefig(Tsp.graphsPath + filtro + version + 'HotVsCold' + ".pdf")
	plt.close(fig)
