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
    meanAsm = 0
    meanC = 0

    with open(Tlp.tablesPath + test + '/ldr' + ".csv", 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            if row[0] != 'type code':      
               if row[0] == "c":
                  meanC = float(row[1])
               elif row[0] == "asm":
                  meanAsm = float(row[1])

    ind = np.arange(3)  # the x locations for the groups
    width = 0.40 # the width of the bars

    fig, ax = plt.subplots()
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 0)) # for both axis use both
    rects1 = ax.bar(ind, [0, meanAsm, 0], width, color='r')
    rects2 = ax.bar(ind + width, [0, meanC, 0], width, color='b')

    # add some text for labels, title and axes ticks
    ax.set_ylabel('Clocks por insumidos')
    ax.set_title('Implementacion')
    ax.set_xticks(ind + width)
    ax.ticklabel_format(style='sci', axis='y', scilimits=(0, 0)) # for both axis use both
    # ax.set_xticklabels(('G1', 'G2')) if you have groups

    ax.legend((rects1[0], rects2[0]), ('Asm', 'C'))

    def autolabel(rects):
        # attach some text labels
        for rect in rects:
            height = rect.get_height()
            ax.text(rect.get_x() + rect.get_width()/2., 1.05*height,
                    '%d' % int(height),
                    ha='center', va='bottom')

    autolabel(rects1)
    autolabel(rects2)

    if not os.path.isdir(Tlp.graphsPath + test):
        os.makedirs(Tlp.graphsPath + test)

    fig.savefig(Tlp.graphsPath + test + "/ldr" + ".pdf")
    plt.close(fig)
