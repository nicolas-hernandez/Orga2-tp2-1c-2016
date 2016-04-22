import csv
import settings
import matplotlib.pyplot as plt
import math

#plt.xkcd()

for variante in settings.variantes:
    dataDim = []
    dataTime = []
    dataTimeDiv = []
    with open('promedios/dimVariable_' + variante + '.csv','rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            if(row[0] != 'Dim'):
                lastline = row
                dataDim.append(int(row[0]))
                dataTime.append(float(row[1]))
                dataTimeDiv.append(float(row[1]) / (float(row[0]))**3)
                
    fig = plt.figure()
    sub = fig.add_subplot(1,1,1)
    sub.scatter(dataDim, dataTime)
    plt.axis([0.0, float(lastline[0]) + 100.0, 0.0, 18000000.0])
    plt.xlabel('Dimension')
    plt.ylabel('T(us)')
    plt.title('Tiempo de ejecucion segun dimension (' + variante + ')')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
    fig.savefig('graficos/dimVariable_' + variante + '.pdf')
    plt.close(fig)

    fig = plt.figure()
    sub = fig.add_subplot(1,1,1)
    sub.scatter(dataDim, dataTimeDiv)
    plt.axis([0.0, float(lastline[0]) + 100.0, 0.0, 0.1]) # Ajustar el eje Y a mano
    plt.xlabel('Dimension')
    plt.ylabel('T(us)/dim$^3$')
    plt.title('Tiempo de ejecucion segun dimension (' + variante + ')')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
    fig.savefig('graficos/dimVariableDiv_' + variante + '.pdf')
    plt.close(fig)
    
    dataNinst = []
    dataTime = []
    with open('promedios/ninstVariable_' + variante + '.csv','rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            if(row[0] != 'Ninst'):
                lastline = row
                dataNinst.append(int(row[0]))
                dataTime.append(float(row[1]))
                
    fig = plt.figure()
    sub = fig.add_subplot(1,1,1)
    sub.scatter(dataNinst, dataTime)
    plt.axis([0.0, float(lastline[0]), 0.0, 5300000.0])
    plt.xlabel('Nro. de instacias')
    plt.ylabel('T(us)')
    plt.title('Tiempo de ejecucion segun Nro. de instacias (' + variante + ')')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
    fig.savefig('graficos/ninstVariable_' + variante + '.pdf')
    plt.close(fig)
    
dataDim = []
dataTimeEG = []
dataTimeLU = []
with open('promedios/dimVariable_EG.csv','rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if(row[0] != 'Dim'):
            dataDim.append(int(row[0]))
            dataTimeEG.append(float(row[1]))

with open('promedios/dimVariable_LU.csv','rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if(row[0] != 'Dim'):
            lastline = row
            dataTimeLU.append(float(row[1]))
            
fig = plt.figure()
sub = fig.add_subplot(1,1,1)
sub.scatter(dataDim, dataTimeEG, color='blue', edgecolor='black', label='EG')
sub.scatter(dataDim, dataTimeLU, color='red', edgecolor='black', label='LU')
plt.legend(loc='upper right', scatterpoints=1)
plt.axis([0.0, float(lastline[0]) + 200.0, 0.0, 18000000.0])
plt.xlabel('Dimension')
plt.ylabel('T(us)')
plt.title('Tiempo de ejecucion segun dimension')
plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
fig.savefig('graficos/dimVariable.pdf')
plt.close(fig)

dataNinst = []
dataTimeEG = []
dataTimeLU = []
with open('promedios/ninstVariable_EG.csv','rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if(row[0] != 'Ninst'):
            dataNinst.append(int(row[0]))
            dataTimeEG.append(float(row[1]))

with open('promedios/ninstVariable_LU.csv','rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if(row[0] != 'Ninst'):
            lastline = row
            dataTimeLU.append(float(row[1]))
            
fig = plt.figure()
sub = fig.add_subplot(1,1,1)
sub.scatter(dataNinst, dataTimeEG, color='blue', edgecolor='black', label='EG')
sub.scatter(dataNinst, dataTimeLU, color='red', edgecolor='black', label='LU')
plt.legend(loc='upper right', scatterpoints=1)
plt.axis([0.0, float(lastline[0]) + 60.0, 0.0, 5300000.0])
plt.xlabel('Numero de Instancias')
plt.ylabel('T(us)')
plt.title('Tiempo de ejecucion segun dimension')
plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
fig.savefig('graficos/ninstVariable.pdf')
plt.close(fig)