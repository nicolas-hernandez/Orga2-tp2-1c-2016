# Orga2-2016

La idea es usar el mismo repo para los dos tps. 
Sean descriptivos con los mensajes de los commits, 
ahora para el tp2 no es tan importante, pero para el tp3 si.

Estaria bueno ir poniendo aca tips, notas y comandos que queremos que
el resto del grupo vea; por ejemplo uso de ciertos scripts para generar
graficos, uso/sintaxis de paquetes de latex o cosas por el estilo.

Si tienen quilombo con instalar el bochs:
(les dice que falta gtk.h)
sudo apt-get install libgtk2.0-dev
(les dice algo de un "sanity test")
sudo apt-get install g++

correr en frio cropflip:
    dejar en tp2.c: int fria = 1;
	correr desde el directorio tp2 el script tp2.py: python tp2.py -t 2 -v all (aca la version no interesa porque compara c-O1 vs. c-O3 vs. asm)
	correr python tp2.py -t 5 -v all (compara asm con c-O1)
	dejar en tp2.c: int fria = 0;
	correr python tp2.py -t 12 -v asm (solo vamos a ver con asm, creo que ver mas es al cuete, pero podes mirar a ver que pasa)
	
	Esperaria ver lo mismo que vine viendo hasta ahora. una curva casi cuadratica. Mira la carpeta graph...ahi estan las corridas para sepia y ldr.

