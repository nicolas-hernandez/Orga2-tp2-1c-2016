import random
import math
import io
import settings

PI = math.pi
YES = 'y'

class RandomParametersGenerator(object):
    def __init__(self, r_i=25, r_e=85, m=30, n=30, iso=500, ninst=1, innerTemp=1500, outerTemp=200):
        self.r_i = r_i
        self.r_e = r_e
        self.m = m
        self.n = n
        self.iso = iso
        self.ninst = ninst
        self.innerTemp = innerTemp
        self.outerTemp = outerTemp
        self.lastFile = 0
        
    def generateTest(self, name, m=30, n=30, ninst=1, subindex=0):
        
        self.m = m
        self.n = n
        self.ninst = ninst
        
        f = open("instancias/" +name + "_" + str(subindex) + ".in", 'w+')
        self.lastFile += 1
        # w+ == f.truncate() pero truncate no funciona..
        f.write(str(self.r_i) + " " + str(self.r_e) + " " + str(self.m) + " " + str(self.n) + " " + str(self.iso) + " " + str(self.ninst) + "\n")
            
        j = 0
        while j < self.ninst:   
            i = 0
            while i < 2*self.n:
                if i < self.n:
                    f.write(str(self.innerTemp) + " ")
                else:
                    f.write(str(self.outerTemp))
                    
                    if i < 2*self.n-1:
                        f.write(" ")
                    else:
                        f.write("\n")
                
                i+=1            

            j+=1    

        f.close()       
            
rpg = RandomParametersGenerator()

valorMN = settings.inicioDim
for i in xrange(settings.cantDimVariable):
    rpg.generateTest(name="dimVariable", m=valorMN, n=valorMN, subindex=i+1)
    valorMN += settings.aumentoDim

valorInst = settings.inicioInst
valorM = settings.valorM
valorN = settings.valorN
for i in xrange(settings.cantInstVariable):
    rpg.generateTest(name="ninstVariable", m=valorM, n=valorN, ninst=valorInst, subindex=i+1)
    valorInst += settings.aumentoInst