#!/bin/bash

COMMAND=$1
FILE=$2

segundosAHoras() {

	horas=$(($1/3600))
	minutos=$(($(($1-$horas*3600))/60))
	segundos=$(($1-$horas*3600-$minutos*60))

	if [[ $horas -le 9 ]]
	then
		horas=0$horas
	fi

	if [[ $minutos -le 9 ]]
	then
		minutos=0$minutos
	fi

	if [[ $segundos -le 9 ]]
	then
		segundos=0$segundos
	fi

	echo "$horas:$minutos:$segundos"

}

if [[ $# == 1 ]]
then

	if [[ $COMMAND == "-h" ]] || [[ $COMMAND == "-?" ]] || [[ $COMMAND == "--help" ]]
	then
		echo "Uso: ejercicio2.sh [OPCION] [ARCHIVO]

Calcula una serie de estadisticas de un archivo que contiene los datos de unas llamadas de un call center

Ejemplo: ./ejercicio2.sh -f callcenter.txt

Opciones:
	-f,			es la opcion de uso general, no tiene otras funciones
	-h, -?, --help		muestra el mensaje de ayuda del script"
		exit "1"
	elif [[ $COMMAND == "-f" ]]
	then
		echo "El parametro \"-f\" debe ser usado seguido de un path a un archivo de texto"
		exit "2"
	else
		echo "Parametro \"$COMMAND\" inválido, ingrese -h, -? o --help para recibir ayuda"
		exit "2"
	fi
fi

if [[ $# == 2 ]]
then

	if [[ $COMMAND == "-f" ]]
	then

		if [ ! -f $FILE ]
		then
			echo 'El archivo no existe, o la ruta es inválida'
			exit "2"
		fi
	else
		echo parametro \'$COMMAND\' inválido, ingrese -h, -? o --help para recibir ayuda
		exit "2"
	fi
else
	echo cantidad de parametros \'\($#\)\' inválida, ingrese -h, -? o --help para recibir ayuda
	exit "2"
fi

if [ ! -r $FILE ]
then
	echo 'El archivo no tiene permisos de lectura'
	exit "2"
fi
	declare -A en_llamada
	declare -A duracion_aux
	declare -A duracion_total
	declare -A cantidad_llamadas
	declare -A duracion_por_dia #punto 1
	declare -A cantidad_por_dia #punto 1
	declare -A duracion_por_usuario_por_dia #punto 2
	declare -A cantidad_por_usuario_por_dia #punto 2
	declare -A duracion_por_llamada_por_dia #punto 4	
	declare -A llamada_bajo_media_por_usuario #punto 4
	flag_primer_dia=true
	
	if [[ ! -s $FILE ]]
	then
		echo "Archivo vacio"
		exit "3"
	fi

	while IFS= read -r line
	do	
	#lee una linea del archivo
		user="${line:22:${#line}}"
		dia="${line:0:10}"

		if [[ -n ${en_llamada[$user]} && ${en_llamada[$user]} == true ]]
		then
		#termina la llamada
			en_llamada[$user]=false
			duracion_aux[$user]=$(( -${duracion_aux[$user]} + ${line:11:2}*3600 + ${line:14:2}*60 + ${line:17:2} ))
			duracion_total[$user]=$(( ${duracion_total[$user]}+${duracion_aux[$user]} ))
			(( cantidad_llamadas[$user]++ ))
			duracion_por_dia[$dia]=$(( ${duracion_por_dia[$dia]}+${duracion_total[$user]} ))
			(( cantidad_por_dia[$dia]++ ))
			duracion_por_usuario_por_dia[$user$dia]=$(( ${duracion_por_usuario_por_dia[$dia]}+${duracion_total[$user]} ))
			(( cantidad_por_usuario_por_dia[$user$dia]++ ))
			duracion_por_llamada_por_dia[$user$dia${cantidad_por_usuario_por_dia[$user$dia]}]=$duracion_aux
		else
		#empieza la llamada
			en_llamada[$user]=true
			duracion_aux[$user]=$((${line:11:2}*3600 + ${line:14:2}*60 + ${line:17:2}))
			
		fi

		if [[ flag_primer_dia==true || $dia_ant!=$dia ]]
		then
			flag_primer_dia=false
			dia_ant=$dia
			for usuario in ${!duracion_total[*]}
			do
				duracion_total[$usuario]=0
				#con esto reseteo el total por dia
			done			
		fi

	done < $FILE

	declare -A media_tiempo_por_dia
	#respuesta 1

	echo "-------------------------------------------
Respuesta 1:
"
	for d in ${!duracion_por_dia[*]}
	do
		tiempo_en_segundos=$(( ${duracion_por_dia[$d]} / ${cantidad_por_dia[$d]} ))
		media_tiempo_por_dia[$d]=$tiempo_en_segundos		
		echo "$d - promedio: `segundosAHoras $tiempo_en_segundos`"
	done
	echo "-------------------------------------------"
	#respuesta 2
	echo "-------------------------------------------
Respuesta 2:
"
	for u in ${!duracion_total[*]} #obtengo la lista de usuarios
	do
		echo "$u"
		for d in ${!duracion_por_dia[*]} #obtengo la lista de dias
		do
		if [[ -n ${duracion_por_usuario_por_dia[$u$d]} ]]
		then
			tiempo_en_segundos=$(( ${duracion_por_usuario_por_dia[$u$d]} / ${cantidad_por_usuario_por_dia[$u$d]} ))			
			echo "--$d:		
	C: ${cantidad_por_usuario_por_dia[$u$d]}
	P: `segundosAHoras $tiempo_en_segundos`"
		fi
		done
	done
	echo "-------------------------------------------"

	#respuesta 3
	echo "-------------------------------------------
Respuesta 3:
"

	i=0
	primero=0
	segundo=0
	tercero=0

	n=${#duracion_total[*]}

	for u in ${!duracion_total[*]}
	do
		i=$(( $i+1 ))
		if [[ $i -eq 1 ]] 
		then
			primero=$u
			continue
		fi
		if [[ $i -eq 2 ]] 
		then
			segundo=$u
			continue
		fi
		if [[ $i -eq 3 ]] 
		then
			tercero=$u
			break
		fi
	done	

	echo ${!duracion_total[*]}	
	
	for u in ${!duracion_total[*]}
	do


		if [[ ${cantidad_llamadas[$u]} -ge ${cantidad_llamadas[$primero]} ]]
		then
			tercero=$segundo
			segundo=$primero
			primero=$u
		elif [[ ${cantidad_llamadas[$u]} -ge ${cantidad_llamadas[$segundo]} ]]
		then
			tercero=$segundo
			segundo=$u
		elif [[ ${cantidad_llamadas[$u]} -ge ${cantidad_llamadas[$tercero]} ]]
		then
			tercero=$u
		fi
	done

	echo "Primero: $primero, con ${cantidad_llamadas[$primero]} llamadas
Segundo: $segundo, con ${cantidad_llamadas[$segundo]} llamadas
Tercero: $tercero, con ${cantidad_llamadas[$tercero]} llamadas"
	echo "-------------------------------------------"
	#respuesta 4
	echo "-------------------------------------------
Respuesta 4:
"
	cantidad_bajo_media=0
	for u in ${!duracion_total[*]} #obtengo la lista de usuarios
	do
		for d in ${!duracion_por_dia[*]} #obtengo la lista de dias
		do
		n=${cantidad_por_usuario_por_dia[$user$dia]}
			for (( i=1; i<=n; i++ ))
			do
				if [[ ${duracion_por_llamada_por_dia[$u$d$i]} -le ${media_tiempo_por_dia[$d]} ]]
				then
					cantidad_bajo_media=$(( $cantidad_bajo_media + 1 ))
					(( llamada_bajo_media_por_usuario[$u]++ ))
				fi
			done

		done
	done
	
	echo $cantidad_bajo_media llamadas bajo la media
	mayor=0
	for u in ${!duracion_total[*]} #obtengo la lista de usuarios
	do
		if [[ ${llamada_bajo_media_por_usuario[$u]} -ge $mayor ]]
		then
			mayor=${llamada_bajo_media_por_usuario[$u]}
			menor_usuario=$u
		fi
	done
	echo "$menor_usuario es el que tiene mas llamadas bajo la media, con $mayor llamadas"
	echo "-------------------------------------------"
