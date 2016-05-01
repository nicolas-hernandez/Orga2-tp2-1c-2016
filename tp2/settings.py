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
    cacheCropflip = 1
    clocksLdr = 2
    clocksCf = 3
    clocksSep = 4
    sizesLdr = 5
    sizesCf = 6
    sizesSep = 7
    compareLdrA = 8
    compareLdrB = 9

    @staticmethod
    def printAllInfo():
        print "possible performance test are: \n"
        print str(Tests.cacheCropflip) + ": cache cropflip test \n"
        print str(Tests.clocksLdr) + ": clocks ldr test \n"
        print str(Tests.clocksCf) + ": clocks cropflip test \n"
        print str(Tests.clocksSep) + ": clocks sepia test \n"
        print str(Tests.sizesLdr) + ": size ldr test \n"
        print str(Tests.sizesCf) + ": size cropflip test \n"
        print str(Tests.sizesSep) + ": size sepia test \n"
        print str(Tests.compareLdrA) + ": compare ldr asm with c with same nums of read and write ops\n"
        print str(Tests.compareLdrB) + ": compare ldr asm integer operations with fp operations\n"


class Filtro:
    cropflip = "cropflip"
    ldr = "ldr"
    sepia = "sepia"
    allV = "all"
    alpha = 150
    tamX = 20
    tamY = 320
    offsetX = 20
    offsetY = 0


def prunedMean(coords = [], ords  = []):
    if len(ords) == 1:
        return ords[0]

    alpha = 0.5
    n = len(coords)
    x0 = n*alpha
    mean = 0
    if x0.is_integer():
        ords.sort()
        del ords[-x0:]
        y = sum(ords)
        mean = y/float(n)
    else:
        x1 = int(x0)
        y1 = sum(ords[:x1-1])/ float(n)
        y2 = sum(ords[:x1]) / float(n)
        mean = float(y2-y1)*float(x0-x1) + y1

    return mean

class TestSizeParams:
    nInst = 3  # 300
    indInst = 1
    cantImg = 14  # 14
    imgName = "starWars"
    folderOut = "test_sizes_performance"
    buildDir = "codigo/build/"
    pathSW = "../img/SW/"
    tablesPath = "tables/test_sizes_performance/"
    graphsPath = "graphs/test_sizes_performance/"


