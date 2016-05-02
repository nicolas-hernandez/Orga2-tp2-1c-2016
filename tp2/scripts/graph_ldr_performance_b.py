#!/usr/bin/python
# coding=utf-8
# plt.xkcd()

import os
import subprocess
import csv
from settings import TestLdrParams as Tlp, Filtro, prunedMean
import matplotlib.pyplot as plt
import numpy as np
import math


def graph(test):
    meanAsm_o = 0
    meanAsm_2 = 0

    with open(Tlp.tablesPath + test + "_o" + '/ldr' + ".csv", 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            if row[0] != 'type code':      
               if row[0] == "asm":
                  meanAsm_o = float(row[1])
    with open(Tlp.tablesPath + test + "_2" + '/ldr' + ".csv", 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            if row[0] != 'type code':      
               if row[0] == "asm":
                  meanAsm_2 = float(row[1])

    objects = ('Asm float point ops', 'Asm integer ops')
    x_pos = np.arange(len(objects))
    performance = [meanAsm_o, meanAsm_2]
    
    fig = plt.figure()
    sub = fig.add_subplot(1, 1, 1)
     
    sub.bar(x_pos, performance, align='center', color='r', alpha=0.5)
    plt.xticks(x_pos, objects)
    plt.ylabel('$Clocks$ $insumidos$')
    plt.title('Performance Asm float point ops vs. Asm integer ops')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0))
     
    if not os.path.isdir(Tlp.graphsPath + test):
        os.makedirs(Tlp.graphsPath + test)

    fig.savefig(Tlp.graphsPath + test + "/ldr" + ".pdf")
    plt.close(fig)
