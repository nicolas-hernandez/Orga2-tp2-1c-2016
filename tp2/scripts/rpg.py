import random
import math
import io

PI = math.pi
YES = 'y'

class RandomParametersGenerator(object):
	def __init__(self, r_i=10, r_e=100, m=30, n=30, iso=500, ninst=1, innerTemp=1500):
		self.r_i = r_i
		self.r_e = r_e
		self.m = m
		self.n = n
		self.iso = iso
		self.ninst = ninst
		self.innerTemp = innerTemp
		
	def generateRandomOutPut(self):
		self.ninst = int(raw_input("Enter ninst value: "))
		res = raw_input("Do you want use standard inputs or maybe change with other values? \n please, press Y or n: ")
		if res.lower() == YES:
			self.r_i = int(raw_input("r_i: "))
			self.r_e = int(raw_input("r_e: "))
			self.m = int(raw_input("m: "))
			self.n = int(raw_input("n: "))
			self.iso = int(raw_input("iso: "))

		res = raw_input("Do you want use standard inner temp or maybe change it with other value? \n please, press Y or n: ")
		if res.lower() == YES:
			self.innerTemp = int(raw_input("Enter new innerTemp: "))

		ln = open('lastTextFileNumber', 'r+')
		readed = ln.read(1)

		lastNumberFile = int(readed)
		lastNumberFile+=1
		
		ln.close()

		ln = open('lastTextFileNumber', 'r+')
		ln.write(str(lastNumberFile))		
		ln.close()

		f = open('test' + str(lastNumberFile) + '.in', 'w+')
		# w+ == f.truncate() pero truncate no funciona..
		f.write(str(self.r_i) + " " + str(self.r_e) + " " + str(self.m) + " " + str(self.n) + " " + str(self.iso) + " " + str(self.ninst) + "\n")
			
		res = raw_input("Do you want constant temperature in the external wall? \n please, press Y or n: ")
		constante = False		
		constantTemp = random.uniform(0, self.iso)		
		if res.lower() == YES: 
			constante = True
		
		j = 0
		while j < self.ninst: 	
			i = 0
			while i < 2*self.n:
				if i < self.n:
					f.write(str(self.innerTemp) + " ")
				else:
					if constante:
						f.write(str(constantTemp))						
					else:
						f.write(str(random.uniform(0, self.iso)))
				
					if i < 2*self.n-1:
						f.write(" ")
					else:
						f.write("\n")
				
				i+=1			

			j+=1	

		print "file saved as " + f.name

		f.close()		
			
rpg = RandomParametersGenerator()
rpg.generateRandomOutPut()
