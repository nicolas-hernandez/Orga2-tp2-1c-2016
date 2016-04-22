import csv
import settings
import matplotlib.pyplot as plt
import math

#plt.xkcd()

dataDim = []
dataTimeEGDivLU = []
with open('tablas/dimVariable.csv','rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if(row[0] != 'Dim'):
            lastline = row
            dataDim.append(int(row[0]))
            dataTimeEGDivLU.append(float(row[3]))
            
fig = plt.figure()
sub = fig.add_subplot(1,1,1)
sub.scatter(dataDim, dataTimeEGDivLU, color='blue', edgecolor='black', label='EG/LU')
# plt.legend(loc='upper right', scatterpoints=1)
plt.axis([0.0, float(lastline[0])+ 10.0, 0.0, 1.5])
plt.xlabel('Dimension')
plt.ylabel('Tiempo de ejecucion de EG sobre LU')
plt.title('Tiempo de ejecucion segun dimension')
plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
fig.savefig('graficos/dimVariable_ratio.pdf')
plt.close(fig)

dataNinst = []
dataTimeEGDivLU = []
with open('tablas/ninstVariable.csv','rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if(row[0] != 'Ninst'):
            lastline = row
            dataNinst.append(int(row[0]))
            dataTimeEGDivLU.append(float(row[3]))
            
fig = plt.figure()
sub = fig.add_subplot(1,1,1)
sub.scatter(dataNinst, dataTimeEGDivLU, color='blue', edgecolor='black', label='EG/LU')
# plt.legend(loc='upper right', scatterpoints=1)
plt.axis([0.0, float(lastline[0]) + 2.0, 0.0, 15.0])
plt.xlabel('Cantidad de instancias')
plt.ylabel('Tiempo de ejecucion de EG sobre LU')
plt.title('Tiempo de ejecucion segun cantidad de instancias')
plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
fig.savefig('graficos/ninstVariable_ratio.pdf')
plt.close(fig)