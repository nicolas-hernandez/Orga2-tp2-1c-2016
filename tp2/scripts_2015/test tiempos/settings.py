import os

# Paramtros test de dimension
cantDimVariable = 30
inicioDim = 3 # Primer valor para m y n
aumentoDim = 1 # En cuanto se aumentan los valores de m y n

# Parametros test de instancias
cantInstVariable = 150
inicioInst = 2
aumentoInst = 2
valorM = 10
valorN = 10

# Diferentes variantes del ejercicio
variantes = ['EG', 'LU']

# Muestras por instancia
muestras = 5

# Programa compilado
executable = './tp' if os.name == 'posix' else 'tp.exe'