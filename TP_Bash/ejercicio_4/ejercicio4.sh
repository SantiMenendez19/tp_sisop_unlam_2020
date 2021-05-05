#!/bin/bash

#
# =========================== Encabezado =======================
# Nombre del script: ejercicio4.sh
# Número de ejercicio: 4
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

#-----INICIO FUNCION QUE REALIZA EL MOVIMIENTO Y BORRADOS DE LOS LOGS A ZIPS------

function help()
{
	echo "El script realiza el movimiento de los logs existentes en la ubicacion de logs y los comprime en archivos zips"
	echo "correspondiente al nombre de cada log."
	echo "Los logs movidos se eliminan para no ocupar espacio"
	echo "Parametros posibles: "
	echo "-f		ubicacion de los archivos de logs"
	echo "-z		ubicacion de los archivos de zips comprimidos"
	echo "-e		nombre de la empresa (opcional)"
	echo "-h		ayuda"
	exit 1
}

# Busqueda de parametros ingresados
while [ $# -ne 0 ]
do
	case $1 in
	-f)
		path_log=$2
		shift
		;;
	-z)
		path_zip=$2
		shift
		;;
	-e)
		empresa=$2
		shift
		;;
	*)
		echo "Error, el parametro $1 no existe"
		help
		;;
	esac;
	shift
done

# Validacion de los parametros
if [ -z "${path_log}" ] || [ -z "${path_zip}" ]; then
	help
fi
if [ ! -d $path_log ]; then
	echo "No existe la ubicacion de la carpeta de logs"
	exit 1
fi

if [ ! -d $path_zip ]; then	
	echo "No existe la ubicacion de la carpeta de zips"
	exit 1
fi

echo "Ubicacion de logs: " $path_log
echo "Ubicacion de zips: " $path_zip

if [ -n "$empresa" ]; then
	flag_empresa=1
	echo "Se ingreso la empresa: "$empresa
else
	flag_empresa=0
	echo "Se revisaran todas las empresas"
fi

# Zipeado y borrado de los logs
if [ $flag_empresa -eq 1 ]; then
	for archivo in $(ls $path_log/$empresa-*.log)
	do
		echo "Se guardara el archivo "$archivo
		if [ ! -f $path_zip"/"$empresa".zip" ]; then
			echo "Creacion del archivo .zip"
			zip -j $path_zip"/"$empresa".zip" $archivo
		else
			zip -uj $path_zip"/"$empresa".zip" $archivo
		fi
		echo "Borrado del archivo" $archivo
		rm $archivo
	done
else
	for archivo in $(ls $path_log/*)
	do
		empresa=$(echo $archivo | grep -oP "(\w+)(?=-(\d*).log$)")
		echo "Se guardara el archivo "$archivo
		if [ ! -f $path_zip"/"$empresa".zip" ]; then
			echo "Creacion del archivo .zip"
			zip -j $path_zip"/"$empresa".zip" $archivo
		else
			zip -uj $path_zip"/"$empresa".zip" $archivo
		fi
		echo "Borrado del archivo" $archivo
		rm $archivo
	done
fi

#-----FIN DEL SCRIPT-----