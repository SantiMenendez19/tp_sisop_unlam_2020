#!/bin/bash
#
# =========================== Encabezado =======================
# Nombre del script: 1ejercicio1.sh
# Número de ejercicio: 1
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

ErrorS() # funcion que muestra mensaje por comando no valido
{
echo "Error. La sintaxis del script es la siguiente:"
echo "Cuento la cantidad de lineas en el archivo: $0 nombre_archivo L" # COMPLETAR
echo "Cuento la cantidad de caracteres del archivo: $0 nombre_archivo C" # COMPLETAR
echo "Cuento el largo de la linea mas larga del archivo: $0 nombre_archivo M" # COMPLETAR
}
ErrorP() # funcion que muestra mensaje por archivo no valido
{
echo "Error. el archivo $0 no existe o no se puede leer" # 
}
if test $# -lt 2 #si la cantidad de parametros es menor a 2 llamo a la funcion errorS
	then
	ErrorS
fi
if ! test -r $1   # Chequeo tener permiso de lectura sobre el archivo
	then
	ErrorP

elif test -f $1 && ( test $2 = "L" || test $2 = "C" || test $2 = "M" ); #valido archivo valido y que el comando sea L C o M
then
	if test $2 == "L" #verifico si el comando es L ingreso al if
		then
		res=`wc -l $1` #guardo en variable el numero de lineas
		echo "La cantidad de lineas del archivo es: $res" #muestro el resultado y el contenido de la variable
	elif test $2 == "C"; #verifico si el comando es C ingreso al if
		then
		res=`wc -c $1` #guardo en variable el numero de caracteres
		echo "La cantidad de caracteres dentro del archivo, incluyendo saltos de linea es: $res" #muestro el resultado y el contenido de la variable
	elif test $2 == "M"; #verifico si el comando es M ingreso al if
		then
		res=`wc -L $1` #guardo en variable la cantidad de caracteres de la linea mas larga
		echo "La linea mas larga tiene en total de caracteres $res " #muestro el resultado y el contenido de la variable
	fi
else
	ErrorS
fi


#Responda:
#a) ¿Cuál es el objetivo de este script?
#b) ¿Qué parámetros recibe?
#c) Comentar el código según la funcionalidad (no describa los comandos, indique la lógica)
#d) Completar los “echo” con el mensaje correspondiente.
#e) ¿Qué información brinda la variable “$#”? ¿Qué otras variables similares conocen?
#Explíquelas.
#f) Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shellscripts

#RESPUESTAS:

#a) El script se encarga de contar dentro del archivo, las diferentes opciones:
#L para contar lineas, C para contar caracteres y M buscar y contar la linea mas larga
#esto se realiza mediante el comando wc(wordcount) y sus diferentes opciones -l, -c -L

#b) Recibe un archivo como primer parametro y un comando (L, C , M) como segundo parametro

#e) $# es una variable que devuelve la cantidad de parámetros que recibio el script 
# Otras variables similares pueden ser:
# $N: siendo N un numero hace referencia al numero(en ubicacion) de parametro recibido
# $?: el valor de salida (exit value) del último comando ejecutado. 
# $_: el último parámetro del último comando ejecutado.
# $0: el nombre del script.
# $@: devuelve todos los parámetros como un array.
# $*: devuelve todos los parámetros como una sola palabra (un string).
# $$: PID del proceso actual.
# $!: PID del último proceso hijo ejecutado en segundo plano.

#f)Las diferentes comillas pueden ser:
#Comillas simples: muestra el contenido explicito de lo que contiene
#Comillas Dobles: Interpreta las referencias a las variables, mostrando el contenido de las mismas
#Acento grave: Interpreta y ejecuta el comando dentro del contenido de los acentos
