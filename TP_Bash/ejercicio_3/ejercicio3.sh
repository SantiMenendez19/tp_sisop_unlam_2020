#!/bin/bash
#
# =========================== Encabezado =======================
# Nombre del script: ejercicio3.sh
# Número de ejercicio: 3
# Trabajo Práctico: 1
# Entrega: Primer entrega
# ==============================================================
# ------------------------ Integrantes ------------------------
#
#	Nombre		|	Apellido		|	DNI
#							|						|
#	Pablo Anibal  	|	Gutierrez		|	39.413.681
#	Facundo Leonel	|       Martin 			|	40.570.462
#	Cristian Damian	|	Azamé			|	32.671.602
#	Santiago Ezequiel|	Menendez		|	40.893.022
#
# -------------------------------------------------------------

ORIGEN=$2
TIME=$4

ARCHIVO=demonio
PID=`ps -ef | pgrep $ARCHIVO`

function ErrorS()
{
echo "Error. La sintaxis del script es la siguiente:"
echo "......................: $0 Ejecute -h -? o -help para mostrar ayuda"
exit
}

function Ayuda()
{
echo "Este script muestra elimina los archivos log viejos para el directorio indicado en el parametro y el tiempo pasado"
echo "El formato esperado para comenzar a observar un directorio es:"
echo "./$0  -f  DIRECTORIO_A_LIMPIAR  -t  TIEMPO_EN_SEGUNDOS"
echo "Para detener un proceso el formato es:"
echo "./$0 stop"
exit
}

#  ./ejercicio3.sh -f ~/Procesos -t 10

function Verifica_proceso_activo()
{
run=$(ps -ef | pgrep $ARCHIVO | wc -l)
if test $run = 1
then
	echo "El proceso ya se encuentra activo";
fi
}

function Proceso_inac()
{
runInact=$(ps -ef | pgrep $ARCHIVO | wc -l)
if test $runInact = 1
then
	echo "El proceso se encontraba activo, se detuvo"
else
	echo "El proceso esta inactivo no se puede ejecutar";
	exit;
fi
}


function start()
{
./demonio.sh "$ORIGEN" "$TIME" &
}

function stop()
{
	ps -ef | pgrep $ARCHIVO | xargs kill &
	exit
}



if [ $# -lt 1 ]
	then 
		ErrorS
	exit
elif [[ $1 == "-f" &&  $3 == "-t" ]]
	then
		Verifica_proceso_activo
		if [ ! -d $2 ]
			then echo "la ruta $2 no es valida"
			exit
		elif [[ $4 =~ - || $4 == 0 ]]
			then echo "El tiempo tiene que ser mayor a cero"
			exit	
		elif [ $# -ne 4 ]
			then echo "cantidad de parametros no validos"
			Ayuda
			exit
		else
			start
			exit
		fi
elif [ "$1" == "stop" ]
	then 
		Proceso_inac
		stop

elif [[ "$1" == "-h" || "$1" == "?" || "$1" == "-help" ]]
	then Ayuda
	exit
else
	Ayuda
	exit
fi
