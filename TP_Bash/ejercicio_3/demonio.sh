#!/bin/bash
#
#
#
########################################

DIRECTORIO=$1
ITIME=$2


function validaArchivoNuevo()
{

OLD_STAT_FILE='./.old_stat.txt'

if [ -e $OLD_STAT_FILE ]
then
        OLD_STAT=`cat $OLD_STAT_FILE`
else
        OLD_STAT="nothing"
fi

NEW_STAT=`stat -t $DIRECTORIO`

if [[ "$OLD_STAT" != "$NEW_STAT" ]]
then
        echo $NEW_STAT > $OLD_STAT_FILE
		BORRAR_ARCHIVOS
fi

}

function start()
{

while [ 1 -eq 1 ]
do

validaArchivoNuevo

sleep $ITIME

done
exit
}

BORRAR_ARCHIVOS() 
{
	
LISTA_ARCHIVOS=$(ls $DIRECTORIO | grep .log | sort -r)
	
for archivosR in $LISTA_ARCHIVOS
do
	empresa1=${archivosR%-*}
	for archivosL in $LISTA_ARCHIVOS
	do
	empresa2=${archivosL%-*}
		if [[ $empresa1 == $empresa2 && $archivosR > $archivosL ]]
		then
			echo "archivo eliminado $archivosL"
			rm -f $archivosL
		fi
	done
done
}

start
