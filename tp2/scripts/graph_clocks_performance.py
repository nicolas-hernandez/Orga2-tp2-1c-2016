#!/usr/bin/python
# coding=utf-8
# plt.xkcd()

import os
import subprocess
import csv
from settings import TestClocksParams as Tcp, Filtro, prunedMean
import matplotlib.pyplot as plt
import numpy as np
import math


def graph(test, file1, file2, file3):
    meanAsm = 0
    meanC_o0 = 0
    meanC_o3 = 0

    with open(Tcp.tablesPath + test + '/' + file1 + ".csv", 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            if row[0] != 'type code':      
               if row[0] == file1:
                  meanAsm = float(row[1])
    with open(Tcp.tablesPath + test + '/' + file2 + ".csv", 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            if row[0] != 'type code':      
               if row[0] == file2:
                  meanC_o0 = float(row[1])
    with open(Tcp.tablesPath + test + '/' + file3 + ".csv", 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            if row[0] != 'type code':      
               if row[0] == file3:
                  meanC_o3 = float(row[1])

    objects = ('Asm', 'C', 'C flag O3')
    x_pos = np.arange(len(objects))
    performance = [meanAsm, meanC_o0, meanC_o3]
    
    fig = plt.figure()
    sub = fig.add_subplot(1, 1, 1)
     
    sub.bar(x_pos, performance, align='center', color='r', alpha=0.5)
    plt.xticks(x_pos, objects)
    plt.ylabel('$Clocks$ $insumidos$')
    plt.title('Performance ' + test + ' Asm vs. C vs. C flag O3')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0))
     
    if not os.path.isdir(Tcp.graphsPath + test):
        os.makedirs(Tcp.graphsPath + test)

    fig.savefig(Tcp.graphsPath + test + "/" + test + ".pdf")
    plt.close(fig)
