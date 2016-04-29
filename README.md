# Orga2-2016

La idea es usar el mismo repo para los dos tps. 
Sean descriptivos con los mensajes de los commits, 
ahora para el tp2 no es tan importante, pero para el tp3 si.

Estaria bueno ir poniendo aca tips, notas y comandos que queremos que
el resto del grupo vea; por ejemplo uso de ciertos scripts para generar
graficos, uso/sintaxis de paquetes de latex o cosas por el estilo.


Uso de tp2.sh:

	./tp2.sh MODO FILTRO IMAGEN [opcionesFiltro]

	MODO:
		asm: corre el make comun y la implementacion asm
		c0: corre el make con el flag -O0 (sin ninguna optimizacion) y luego el tp2 con "-i c"
		c1: corre el make con el flag -O1 (el default de gcc)
		c2: corre el make con el flag -O2 (las optimizaciones del nivel anterior y algunas mas)
		c3: corre el make con el flag -O3 (todas las optimizaciones. creo)
	
	FILTRO: ldr cropflip sepia
	IMAGEN: path relativo de la imagen ("codigo/img/scarlett.bmp" funca pero "/home/nico/scarlett.bmp" no)

	Ojo, no esta pensado para correrse desde cualquier directorio.

	Los resultados se guardan en codigo/log.txt. El script sobrescribe este archivo.

