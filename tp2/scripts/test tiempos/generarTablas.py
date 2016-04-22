import csv
import settings

class Data:
    dim = 0
    time_eg = 0
    time_lu = 0

dataList = []
with open('promedios/dimVariable_EG.csv', 'rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=",")
    d = Data()
    for row in reader:
        if(row[0] != 'Dim'):
            d.dim = int(row[0])
            d.time_eg = float(row[1])
            dataList.append(d)
            d = Data()

with open('promedios/dimVariable_LU.csv', 'rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=",")
    d = Data()
    lineaActual = 0
    for row in reader:
        if(row[0] != 'Dim'):
            dataList[lineaActual].time_lu = float(row[1])
            lineaActual += 1

with open('tablas/dimVariable.csv', 'wb') as csvfile:
    writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
    writer.writerow(["Dim"] + ["EG"] + ["LU"] + ["EG/LU"]);
    for data in dataList:
        tiempo_eg = data.time_eg
        tiempo_lu = data.time_lu
        division = data.time_eg / data.time_lu
        writer.writerow([data.dim] + [tiempo_eg] + [tiempo_lu] + [division])
        
dataList = []
with open('promedios/ninstVariable_EG.csv', 'rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=",")
    d = Data()
    for row in reader:
        if(row[0] != 'Ninst'):
            d.dim = int(row[0])
            d.time_eg = float(row[1])
            dataList.append(d)
            d = Data()

with open('promedios/ninstVariable_LU.csv', 'rb') as csvfile:
    reader = csv.reader(csvfile, delimiter=",")
    d = Data()
    lineaActual = 0
    for row in reader:
        if(row[0] != 'Ninst'):
            dataList[lineaActual].time_lu = float(row[1])
            lineaActual += 1

with open('tablas/ninstVariable.csv', 'wb') as csvfile:
    writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
    writer.writerow(["Ninst"] + ["EG"] + ["LU"] + ["EG/LU"]);
    for data in dataList:
        tiempo_eg = data.time_eg
        tiempo_lu = data.time_lu
        division = data.time_eg / data.time_lu
        writer.writerow([data.dim] + [tiempo_eg] + [tiempo_lu] + [division])