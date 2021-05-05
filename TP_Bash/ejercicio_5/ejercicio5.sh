#!/bin/bash
#
# =========================== Encabezado =======================
# Nombre del script: ejercicio5.sh
# Número de ejercicio: 5
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
#-----INICIO FUNCION QUE REALIZA EL REPORTE DE NOTAS POR MATERIA------

function ReporteNotas {
awk 'function RdoNota(nota1,nota2,IdMateria,recursan,final,recuperan,abandonaron,promocionan) {
				if ( nota1 >= 4 )
					if ( nota2 >= 4 )
						if ( nota1 >= 7 && nota2 >= 7 )
							promocionan[IdMateria] +=1
						else
							if ( Final == "" )
								final[IdMateria] +=1
							else
								if ( Final >= 4 )
									promocionan[IdMateria] +=1
								else
									recursan[IdMateria] +=1
					else
						recursan[IdMateria] +=1
				else
					recursan[IdMateria] +=1
	 }

function RdoNotaSinRecu(nota1,nota2,IdMateria,recursan,final,recuperan,abandonaron,promocionan) {
				if ( nota1 >= 4 )
					if ( nota2 >= 4 )
						if ( nota1 >= 7 && nota2 >= 7 )
							promocionan[IdMateria] +=1
						else
							if ( Final == "" )
								recuperan[IdMateria] +=1
							else
								if ( Final >= 4 )
									promocionan[IdMateria] +=1
								else
									recursan[IdMateria] +=1
					else
						recuperan[IdMateria] +=1
				else
					if ( nota2 >= 4 )
						recuperan[IdMateria] +=1
					else
						recursan[IdMateria] +=1
	 }
BEGIN{FS= "|";}
{
	if ( NR > 1 )
	{
		IdMateria= $2;
		PrimerParcial= $3;
		SegundoParcial= $4;
		RecuParcial= $5;
		RecuNota= $6;
		Final= $7;
		materia[IdMateria]= IdMateria;
		recursan[IdMateria] +=0;
		final[IdMateria] +=0;
		recuperan[IdMateria] +=0;
		abandonaron[IdMateria] +=0;
		promocionan[IdMateria] +=0;
		if ( RecuParcial == 1 )
			RdoNota(SegundoParcial,RecuNota,IdMateria,recursan,final,recuperan,abandonaron,promocionan)
		else
			if ( RecuParcial == 2 )
			RdoNota(PrimerParcial,RecuNota,IdMateria,recursan,final,recuperan,abandonaron,promocionan)
			else
			if ( RecuParcial == "" )
				if (PrimerParcial == "" || SegundoParcial == "" )
					abandonaron[IdMateria] +=1
		  		else
					RdoNotaSinRecu(PrimerParcial,SegundoParcial,IdMateria,recursan,final,recuperan,abandonaron,promocionan)
	}
}
END{
	print "\"Materia\",\"Final\",\"Recursan\",\"Recuperan\",\"Abandonaron\",\"Promocionan\"";
	for (x in materia)
		{
		OFS=",";
		print  "\""materia[x]"\"","\""final[x]"\"","\""recursan[x]"\"","\""recuperan[x]"\"","\""abandonaron[x]"\"","\""promocionan[x]"\""
}
}' $1
}

#-----FIN DE FUNCION QUE REALIZA EL REPORTE DE NOTAS POR MATERIA-----




#-----INICIO FUNCION DE AYUDA-----

function help {
		clear
		echo "El script lee un archivo con notas de alumnos y muestra por pantalla un reporte por materia de la cantidad de alumnos en final, que recursan, que recuperan y que abandonaron"
		echo "El enunciado no solicitaba mostrar por pantalla los alumnos promocionados pero nos parecio complementario dejarlo  como dato adicional"
		echo "Puede especificar una ruta absoluta o relativa. Si el archivo no existe, arrojara error y terminara el programa. Ademas puede utilizar el comando find -f";
		echo "En caso de no escribir nombre de archivo, el programa le solicitara el mismo"
		echo -e "\nEjemplo: ./Ejercicio5.sh notas.txt\n"
		echo "OPCIONES"
		echo -e "\n	-f	find --->Ejemplo: ./Ejercicio5.sh -f notas.txt"
		echo "	-h | -? | --help	Ayuda"
		}


#----- FIN DE FUNCION DE AYUDA-----



#-----INICIO DE EVALUACION DE PARAMETROS------

case $1 in
	"-h" | "-?" | "--help") 	help
	exit
	;;

	"-s") 	exit
	;;

	"-f") 	if [ ! -n "$2" ]
		then
			echo "Indicar nombre de archivo a procesar";
			read Ruta
			if [ -f $Ruta ];
			then
				clear
				ReporteNotas $Ruta
			else
				clear
				echo "El archivo" $Ruta "no existe, fin del programa. Puede escribir \"./Ejercicio5.sh -h\" para mas ayuda"
			fi
		else
			if [ -f $2 ];
			then
				clear
				ReporteNotas $2
			else
				clear
				echo "El archivo" $2 "no existe, fin del programa. Puede escribir \"./Ejercicio5.sh -h\" para mas ayudasss."
			fi
		fi
	;;

	"")	echo "Indicar nombre de archivo a procesar";
		read Ruta
		if [ -f $Ruta ];
		then
			clear
			ReporteNotas $Ruta
		else
			clear
			echo "El archivo" $Ruta "no existe, fin del programa. Puede escribir \"./Ejercicio5.sh -h\" para mas ayuda."
		fi
		;;

	*)	 if [ -f $1 ];
		then
			clear
			ReporteNotas $1
		else
			clear
			echo "El archivo" $1 "no existe, fin del programa. Puede escribir -h para mas ayuda."
		fi
		;;
		esac


#-----FIN DE EVALUACION DE PARAMETROS------
#-----FIN DE SCRIPT-----------
