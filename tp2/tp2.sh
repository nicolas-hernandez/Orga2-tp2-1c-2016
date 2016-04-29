#!/bin/bash
let TIMES=100
MODE=$1
FILTER=$2
PIC=$3
FILTER_ARGS=""
BUILD_DIR="codigo/"
PROGRAM="build/tp2"
LOGFILE="log.txt"

rm $BUILD_DIR$LOGFILE

function usage {
	echo "Modo de uso:"
	echo "./tp2.sh modo filtro imagen [opcionesFiltro]"
	echo "	Donde modo es: asm c0 c1 c2 c3."
	echo "	modo determina que implementacion del filtro se ejecuta"
	echo "	Filtro : sepia cropflip ldr"
}

#TODO: checkear el contenido de filter y llenar filter args
case $FILTER in
	sepia)
		;;
	ldr)
		FILTER_ARGS=$4
		#Si queres pasar negativos van entre comillas
		#ej: "-- -20"
		;;
	cropflip)
		FILTER_ARGS="$4 $5 $6 $7"
		;;
	*)
		usage
		exit 1
esac

case $MODE in
    asm)
        OPTIONS="-i asm "
        ;;
    c0)
        OPTIONS="-i c"
        BUILD_ARGS="-e CFLAGS64="-O0 -Wall -std=c99 -pedantic -m64" "
        ;;
    c1)
        OPTIONS="-i c"
        BUILD_ARGS="-e CFLAGS64="-O1 -Wall -std=c99 -pedantic -m64" "
        ;;
    c2)
        OPTIONS="-i c"
        BUILD_ARGS="-e CFLAGS64="-O2 -Wall -std=c99 -pedantic -m64" "
        ;;
    c3)
        OPTIONS="-i c"
        BUILD_ARGS="-e CFLAGS64="-O3 -Wall -std=c99 -pedantic -m64" "
        ;;
    *)
        usage
        exit 1
esac

WORK_DIR=$(pwd)
TEST_PIC=$WORK_DIR/$PIC

cd $BUILD_DIR
make $BUILD_ARGS
typeset -i i TIMES 
for ((i=1;i<=TIMES;++i)); do
	./$PROGRAM $OPTIONS $FILTER $TEST_PIC $FILTER_ARGS \
		>> $LOGFILE
done


#./$PROGRAM $OPTIONS $FILTER $TEST_PIC $FILTER_ARGS | grep llamada

#./$PROGRAM $OPTIONS $FILTER $TEST_PIC $FILTER_ARGS >> $LOGFILE

#TODO:
#Loop de 1 a $TIMES que corra ejecutable una vez (-t 1)
#Recolectar datos en un archivo
#hacerlos entrar en los scripts de python que generan graficos
