#!/usr/bin/python
# coding=utf-8
# plt.xkcd()

import os
import subprocess
import csv
from settings import TestCacheParams as Tcp, Filtro, prunedMean
import matplotlib.pyplot as plt
import matplotlib as mp
import math


def graph(version):
    sizeX = []
    means = []
    means2 = []
    maxX = 0
    maxY = 0

    typeCode = version

    if version == Filtro.allV:
        typeCode = Filtro.c

    with open(Tcp.tablesPath + "cropflip" + typeCode + ".csv", 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            if row[0] != 'tamX/tamY':
                if float(row[0]) > maxX:
                    maxX = float(row[0])

                if float(row[1]) > maxY:
                    maxY = float(row[1])

                sizeX.append(float(row[0]))
                means.append(float(row[1]))

    if version == Filtro.allV:
        with open(Tcp.tablesPath + "cropflip" + Filtro.asm + ".csv", 'rb') as csvfile:
            reader = csv.reader(csvfile, delimiter=',')
            for row in reader:
                if row[0] != 'tamX/tamY':
                    if float(row[1]) > maxY:
                        maxY = float(row[1])

                    means2.append(float(row[1]))

    fig = plt.figure()
    sub = fig.add_subplot(1, 1, 1)
    if len(means) > 0:
        sub.scatter(sizeX, means, color='blue', edgecolor='black', label=typeCode)
    if version == Filtro.allV and len(means2) > 0:
        sub.scatter(sizeX, means2, color='red', edgecolor='black', label=Filtro.asm)
        plt.legend(loc='upper right', scatterpoints=1)
        
    plt.axis([Tcp.tamX, maxX+100.0, 0.0, maxY+100000.0])
    plt.xlabel("$Relacion$ $ancho$ x $" + str(Tcp.tamY) + "$ - $ancho$ $/$ $x_{0}$ = $" + str(Tcp.tamX) + "$")
    plt.ylabel("$Cantidad$ $de$ $clocks$ $insumidos$")
    plt.title("Cantidad de clocks insumidos " + "cropflip" + " " + version)
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0)) # for both axis use both
    if not os.path.isdir(Tcp.graphsPath):
        os.makedirs(Tcp.graphsPath)

    fig.savefig(Tcp.graphsPath + "cropflip" + version + ".pdf")
    plt.close(fig)
