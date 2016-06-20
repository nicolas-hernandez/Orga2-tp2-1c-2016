import os


class Options:
	 none = "none"
	 o = "o"
	 o1 = "o1"
	 o2 = "o2"
	 o3 = "o3"

	 @staticmethod
	 def printAllInfo():
		  print "possible flags: " + Options.none + " (no compile), " \
		 + Options.o + " (only make), " + Options.o1 + ", " + Options.o2 + ", " + Options.o3 + " \n"


class Tests:
	 nothing = 0
	 clocksLdr = 1
	 clocksCf = 2
	 clocksSep = 3
	 sizesLdrCold = 4
	 sizesCfCold = 5
	 sizesSepCold = 6
	 compareLdrA = 7
	 compareLdrB = 8
	 compareSepiaB = 9
	 sizesLdrHot = 10
	 sizesCfHot = 11
	 sizesSepHot = 12	

	 @staticmethod
	 def printAllInfo():
		 print "possible performance test are: \n"
		 print str(Tests.nothing) + ": without test \n"
		 print str(Tests.clocksLdr) + ": clocks ldr test. version is ignored \n"
		 print str(Tests.clocksCf) + ": clocks cropflip test. version is ignored \n"
		 print str(Tests.clocksSep) + ": clocks sepia test. version is ignored \n"
		 print str(Tests.sizesLdrCold) + ": size ldr test cold cache\n"
		 print str(Tests.sizesCfCold) + ": size cropflip test cold cache\n"
		 print str(Tests.sizesSepCold) + ": size sepia test cold cache\n"
		 print str(Tests.compareLdrA) + ": compare ldr asm with c with same nums of read and write ops\n version is ignored\n"
		 print str(Tests.compareLdrB) + ": compare ldr asm integer operations with fp operations\n version is ignored\n"
		 print str(Tests.compareSepiaB) + ": compare sepia asm integer operations with fp operations\n version is ignored\n"
		 print str(Tests.sizesLdrHot) + ": size ldr test hot cache\n"
		 print str(Tests.sizesCfHot) + ": size cropflip test hot cache\n"
		 print str(Tests.sizesSepHot) + ": size sepia test hot cache\n"

class Filtro:
	 cropflip = "cropflip"
	 ldr = "ldr"
	 sepia = "sepia"
	 allV = "all"
	 alpha = 150
	 tamX = 40
	 tamY = 140
	 offsetX = 0
	 offsetY = 0


def prunedMeanAndSampleVariance(coords = [], ords	= []):
	 if len(ords) == 1:
		  return (ords[0], 0)

	 alpha = 0.5
	 n = len(coords)
	 x0 = n*alpha
	 mean = 0
	 sampleVariance = 0
	 ords.sort()
	 if x0.is_integer():
		  print 'x0 es entero ' + str(x0)
		  del ords[-int(x0):]
		  print 'quedan ' + str(len(ords))
		  y = sum(ords)
		  mean = y/float(len(ords))
	 else:
		 # no esta probado
		  print 'x0 es float ' + str(x0)
		  x1 = int(x0)
		  y1 = sum(ords[:x1-1])/ float(n)
		  y2 = sum(ords[:x1]) / float(n)
		  mean = float(y2-y1)*float(x0-x1) + y1

	 total = 0
	 for x in ords:
		print 'x is ' + str(x) + ' mean is ' + str(mean)
		sampleVariance = (x-mean)
		sampleVariance *= sampleVariance
		total += sampleVariance
		#Para el caso de x0 entero anda bien. Para el caso no entero no lo se.

	 print 'sumatoria es: ' + str(total) + ' len ords: ' + str(len(ords))	
	 total = total/float(len(ords))

	 return (mean, total)

class ImageDetails:
	 width = 24
	 height = 24
	 decrement = 16

class TestSizeParams:
	 nInst = 100
	 indInst = 1
	 cantImg = 76
	 imgName = "lena32"
	 buildDir = "codigo/build/"
	 pathSW = "../img/"
	 tablesPath = "tables/test_sizes_performance/"
	 graphsPath = "graphs/test_sizes_performance/"
	 coldCache = 'Cold'
	 hotCache = 'Hot'
		
class TestClocksParams:
	 nInst = 100
	 indInst = 1
	 imgName = "lena32"
	 buildDir = "codigo/build/"
	 pathSW = "../img/"
	 tablesPath = "tables/test_clocks_performance/"
	 graphsPath = "graphs/test_clocks_performance/"

class TestExtraParams:
	 nInst = 100
	 indInst = 1
	 imgName = "lena32"
	 buildDir = "codigo/build/"
	 pathSW = "../img/"
	 tablesPath = "tables/test_extra_performance/"
	 graphsPath = "graphs/test_extra_performance/"
	 ldr_asm_name_o = "ldr_asm_test_o.asm"
	 ldr_asm_name_a = "ldr_asm_test_1.asm"
	 ldr_asm_name_b = "ldr_asm_test_2.asm" 
	 sepia_asm_name_o = "sepia_asm_test_o.asm"
	 sepia_asm_name_a = "sepia_asm_test_1.asm"
	 sepia_asm_name_b = "sepia_asm_test_2.asm"
