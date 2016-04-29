#!/usr/bin/python
#from scripts.fabricate import *
#from scripts.settings import *
#from scripts.utils import listfiles
import os
from sys import argv

# Acciones
def build():
  compile()

def compile():
    build_dir = "codigo/"
    cwd = os.getcwd() # get current directory
    os.chdir(build_dir)
    os.system("make -e CFLAGS64=\"-O3 -g -ggdb -Wall -Wextra -std=c99 -pedantic -m64\" ")
    #os.system("make")
    os.chdir(cwd)

#    for source in sources:
#    run(compiler, '-c', source+'.cpp', '-o', source+'.o')


def clean():
    build_dir = "codigo/"
    cwd = os.getcwd() # get current directory
    os.chdir(build_dir)
    os.system("make clean")
    os.chdir(cwd)

def test():
  build()
  import unittest
  unittest.main(module='scripts.tptests', exit=False, argv=argv[:1], verbosity=3)

def main():
    #build()
    #test()
    clean()
    

main()

    
