MODE=$1
FILTER=$2
FILTER_ARGS=""
BUILD_DIR="codigo/"
PROGRAM="build/tp2"
TEST_PIC="img/lena32.bmp"
LOGFILE="log.txt"

function usage {
    echo "Should be implemented."
}


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

cd $BUILD_DIR
make $BUILD_ARGS
./$PROGRAM $OPTIONS $FILTER $TEST_PIC $FILTER_ARGS | grep llamada

#./$PROGRAM $OPTIONS $FILTER $TEST_PIC $FILTER_ARGS >> $LOGFILE

#TODO:
#Loop de 1 a $TIMES que corra ejecutable una vez (-t 1)
#Recolectar datos en un archivo
#hacerlos entrar en los scripts de python que generan graficos
