#!/bin/bash
#
# =========================== Encabezado =======================
# Nombre del script: ejercicio6.sh
# Número de ejercicio: 6
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

#-----INICIO DE FUNCION QUE REALIZA SUMA DE FRACCIONES-----

# Funciones
function help()
{
	echo "El script realiza una suma de fracciones de un archivo .txt que se le pasa al parametro"
	echo "El script realiza el calculo de las fracciones delimitadas por : y despues realiza la simplificacion del resultado"
	echo "El resultado lo guarda en un archivo de salida que se llama salida.out"
	echo "Parametros posibles: "
	echo "-f		ubicacion del archivo de fracciones"
	echo "-h		ayuda"
	exit 1
}

function mcd()
{
	num=$1
	if [ $num -lt 0 ]; then
		num=$(( $num * -1 ))
	fi
	den=$2
	resto=1
	while ! [ $resto -eq 0 ]
	do
		resto=$(( $num % $den ))
		num=$den
		den=$resto
	done
	# Retorna la funcion
	echo $num
}

# Busqueda de parametros
while [ $# -ne 0 ]
do
	case $1 in
	-f)
		path=$2
		shift
		;;
	-h)
		help
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
if [ -z "${path}" ]; then
	help
fi
if [ ! -f $path ]; then
	echo "No existe la ubicacion del archivo de fracciones"
	help
	exit 1
fi

echo "Ubicacion del archivo de fracciones: " $path

# Declaro las variables a utilizar
cant_numeros=$(cat $path | sed 's/,/\n/g' | wc -l)
res_numerador=0
res_denominador=1
declare -a array_numerador
declare -a array_denominador

# Loop de la lista de fracciones
for ((i=1;i<=$cant_numeros;i++))
do
	numero=$(cat $path | cut -f $i -d ',')
	numero_mixto=$(echo $numero | grep -oP "([-]*[\d]+)(?=\:[\d-]+)")
	numerador=$(echo $numero | grep -oP "([\d-]+)(?=\/\d+)")
	denominador=$(echo $numero | grep -oP "(?![-]*\d+\/)(?![-]*\d+\:)([-]*\d+)")
	numero_m_negativo=0
	if [ $numero_mixto ]; then # Caso de numero mixto
		numero_mixto=$(( $denominador * $numero_mixto ))
		if [ $numero_mixto -lt 0 ]; then
			numero_m_negativo=1
			numero_mixto=$(($numero_mixto * -1))
		fi
		numerador=$(( $numerador + $numero_mixto ))
	fi
	if [ $res_denominador -eq 0 ]; then
		res_denominador=$denominador
	elif ! [ $(( $res_denominador % $denominador )) -eq 0 ]; then 
		res_denominador=$(( $res_denominador * $denominador ))
	fi
	if [ -z $numerador ]; then # Caso en el que es un numero entero, no fraccion, ya que solo lo reconoce en la variable de denominador
		numerador=$denominador
		denominador=1
	fi
	if [ $numero_m_negativo -eq 1 ]; then
		numerador=$(($numerador * -1))
	fi
	array_numerador=("${array_numerador[@]}" "$numerador")
	array_denominador=("${array_denominador[@]}" "$denominador")
	echo "$numerador/$denominador +"
done

# Loop de la suma de fracciones
for ((i=0;i<$cant_numeros;i++))
do
	res_numerador=$(( $res_numerador + (($res_denominador / ${array_denominador[$i]}) * ${array_numerador[$i]}) ))
done

# Simplifico la fraccion resultado
max_divisor=$(mcd $res_numerador $res_denominador)
res_numerador=$(( $res_numerador / $max_divisor ))
res_denominador=$(( $res_denominador / $max_divisor ))

# Guardo el resultado
echo "=" $res_numerador/$res_denominador
echo $res_numerador/$res_denominador > ${path%/*}/salida.out

#-----FIN DE SCRIPT-----