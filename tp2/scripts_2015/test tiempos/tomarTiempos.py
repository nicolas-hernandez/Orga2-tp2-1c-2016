import settings
import subprocess as sp
import time
import csv

def runSystem(input, output, method):
    sp.check_call([settings.executable, input, output, method], stdin=None, stdout=None, stderr=None)

def getTime():
    return 1000000 * time.time()

for solver in xrange(2):
    variante = settings.variantes[solver]
    # valorMN = settings.inicioDim
    # with open('resultados/dimVariable_' + variante + '.csv', 'wb') as csvfile:
        # writer = csv.writer(csvfile, delimiter=',')
        # writer.writerow(['Dim'] + ['Time'])
        # for j in xrange(settings.cantDimVariable):
            # dim = valorMN**2
            # valorMN += settings.aumentoDim
            
            # for i in xrange(settings.muestras):
                # writer = csv.writer(csvfile, delimiter=',')
                # start_time = getTime()
                # fName = 'instancias/dimVariable_' + str(j+1)
                # runSystem(fName + '.in', fName + '.out', str(solver))
                # end_time = getTime() - start_time
                # writer.writerow([str(dim)] + [str(end_time)])
    
    valorInst = settings.inicioInst
    with open('resultados/ninstVariable_' + variante + '.csv', 'wb') as csvfile:
        writer = csv.writer(csvfile, delimiter=',')
        writer.writerow(['Ninst'] + ['Time'])
        for j in xrange(settings.cantInstVariable):
            ninst = valorInst
            valorInst += settings.aumentoInst
            
            for i in xrange(settings.muestras):
                writer = csv.writer(csvfile, delimiter=',')
                start_time = getTime()
                fName = 'instancias/ninstVariable_' + str(j+1)
                runSystem(fName + '.in', fName + '.out', str(solver))
                end_time = getTime() - start_time
                writer.writerow([str(ninst)] + [str(end_time)])