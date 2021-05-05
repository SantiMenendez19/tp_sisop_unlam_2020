<#
.SYNOPSIS
Esta función realiza el reporte de notas por materia
.DESCRIPTION
El script lee un archivo con notas de alumnos y muestra por pantalla un reporte por materia de la cantidad de alumnos en final, que recursan, que recuperan y que abandonaron
.NOTES
 ------------------------ Integrantes ------------------------

	Nombre		|	Apellido		|	DNI
													|
	Pablo Anibal  	|	Gutierrez		|	39.413.681
	Facundo Leonel	|       Martin 			|	40.570.462
	Cristian Damian	|	Azamé			|	32.671.602
	Santiago Ezequiel|	Menendez		|	40.893.022
.EXAMPLE
./ejercicio5.ps1 -Nomina "notas.csv"
#>

Param (
    [Parameter(Mandatory=$true)][string] $Nomina = ""
)
	 
function ReporteNotas
{
param ( $listado )
		$materia = @{}
		$recursan = @{}
		$final = @{}
		$recuperan = @{}
		$abandonaron = @{}
		$promocionan = @{}
	
	
	for($i=0;$i -lt $listado.count;$i++)
	{
		if (!$materia.Contains($listado[$i].IdMateria))
		{
			$materia.Add($listado[$i].IdMateria,$listado[$i].IdMateria)
			$recursan.Add($listado[$i].IdMateria,0)
			$final.Add($listado[$i].IdMateria,0)
			$recuperan.Add($listado[$i].IdMateria,0)
			$abandonaron.Add($listado[$i].IdMateria,0)
			$promocionan.Add($listado[$i].IdMateria,0)
		}
		$IdMateria= $listado[$i].IdMateria;
		$PrimerParcial= $listado[$i].PrimerParcial;
		$SegundoParcial= $listado[$i].SegundoParcial;
		$RecuParcial= $listado[$i].RecuParcial;
		$RecuNota= $listado[$i].RecuNota;
		$Nfinal= $listado[$i].Final;
		if ( $RecuParcial -eq 1 )
		{
			$nota1=[int]$SegundoParcial
			$nota2=[int]$RecuNota
			RdoNota $nota1 $nota2 $IdMateria $recursan $Nfinal $final $recuperan $abandonaron $promocionan
		}
		else
		{
			if ( $RecuParcial -eq 2 )
			{
				$nota1=[int]$PrimerParcial
				$nota2=[int]$RecuNota
				RdoNota $nota1 $nota2 $IdMateria $recursan $Nfinal $final $recuperan $abandonaron $promocionan
			}
			else
			{
				if ( $RecuParcial -eq "" )
				{
					if (($PrimerParcial -eq "") -or ($SegundoParcial -eq ""))
					{
						$abandonaron.$IdMateria +=1
					}
					else
					{	
						$nota1=[int]$PrimerParcial
						$nota2=[int]$SegundoParcial
						RdoNotaSinRecu $nota1 $nota2 $IdMateria $recursan $Nfinal $final $recuperan $abandonaron $promocionan
					}
				}
			}
		}
	}
	$resultado = @()

		 foreach ($x in $materia.keys)
		 {
		 $detalles = [ordered]@{
		 Materia = [int]$materia.Item($x)
		 Final = $final.Item($x)
		 Recursan = $recursan.Item($x)
		 Recuperan = $recuperan.Item($x)
		 Abandonaron = $abandonaron.Item($x)
		 Promocionan = $promocionan.Item($x)
		 }
		 $resultado += New-Object PSObject -Property $detalles
		 }
		 $resultado | Sort-Object  {[int]$_.Materia} |export-csv -Path ReporteNotas.txt -NoTypeInformation
		 Get-Content ReporteNotas.txt
		 Write-host "`nEl reporte fue guardado en el directorio: $pwd\ReporteNotas.txt"

		

}
function RdoNota($nota1,$nota2,$IdMateria,$recursan,$Nfinal,$final,$recuperan,$abandonaron,$promocionan) 
{
	if ( $nota1 -ge 4 )
	{
		if ( $nota2 -ge 4 )
		{
			if (($nota1 -ge 7) -and ($nota2 -ge 7))
			{
				$promocionan.$IdMateria +=1
			}
			else
			{
				if ( $Nfinal -eq "" )
				{
					$final.$IdMateria +=1
				}
				else
				{
					if ( $Nfinal -ge 4 )
					{
						$promocionan.$IdMateria +=1
					}
					else
					{
						$recursan.$IdMateria +=1
					}
				}
			}
		}
		else
		{	
			$recursan.$IdMateria +=1
		}
	}
	else
	{
		$recursan.$IdMateria +=1
	}
}

function RdoNotaSinRecu($nota1,$nota2,$IdMateria,$recursan,$Nfinal,$final,$recuperan,$abandonaron,$promocionan) 
{
	if ( $nota1 -ge 4 )
	{
		if ( $nota2 -ge 4 )
		{
			if (($nota1 -ge 7) -and ($nota2 -ge 7))
			{	
				$promocionan.$IdMateria +=1
			}
			else
			{
				if ( $Nfinal -eq "" )
				{	
					$recuperan.$IdMateria +=1
				}
				else
				{
					if ( $Nfinal -ge 4 )
					{
						$promocionan.$IdMateria +=1
					}
					else
					{
						$recursan.$IdMateria +=1
					}
				}
			}	
		}
		else
		{
			$recuperan.$IdMateria +=1
		}
	}
	else
	{
		if ( $nota2 -ge 4 )
		{
			$recuperan.$IdMateria +=1
		}	
		else
		{	
			$recursan.$IdMateria +=1
		}
	}
}

if ( Test-Path $Nomina )
							{
								$listado=Import-CSV -Path $Nomina -Delimiter "|"
								clear
								ReporteNotas $listado
							}
							else
							{
								clear
								Write-Host "El archivo" $Nomina "no existe, fin del programa. Puede escribir get-help para obtener ayuda y ver un ejemplo de como ejecutar el script"
							}


#-----FIN DE FUNCION QUE REALIZA EL REPORTE DE NOTAS POR MATERIA-----



#-----FIN DE SCRIPT-----------
