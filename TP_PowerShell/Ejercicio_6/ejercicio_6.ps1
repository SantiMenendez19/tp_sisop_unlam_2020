<#
.SYNOPSIS
Esta función realiza la suma de una lista de fracciones de un archivo
.DESCRIPTION
Esta función realiza la suma de una lista de fracciones de un archivo
.PARAMETER Path
Path del archivo de fracciones a utilizar
.NOTES
	Nombre del archivo      : <ejercicio_6.ps1>
	Autor         : Santiago Menendez
	Requisitos : PowerShell v7.0
	Copyright 2020 - Santiago Menendez
.EXAMPLE
./ejercicio_6.ps1 -Path "lista_fracciones.txt"
#>

# Parametros de Entrada
Param (
    [Parameter(Mandatory=$true)][string] $Path = ""
)

function Get-mcd($num,$den)
{
	if ( $num -lt 0 ) {
        $num=$(( $num * -1 ))
    }
    [int]$resto = 1
	while (!($resto -eq 0)) {
		$resto = $num % $den
		$num = $den
		$den = $resto
    }
    return [int]$num
}
function ejercicio6 {
    # Validacion de parametros
    Write-Host "Path del archivo de fracciones: " $Path
    if (Test-Path $Path) {
        Write-Host "Existe el directorio $Path"
    }
    else {
        Write-Host "No existe el directorio $Path , se termina el proceso"
        return
    }
    
    #Variables 
    try {
        $fracciones = (Get-Content $Path).split(",")
    }
    catch {
        Write-Host "El archivo esta vacio"
    }
    $res_numerador = 0
    $res_denominador = 1 
    $array_numerador = @()
    $array_denominador = @()
    Write-Host "Cantidad de fracciones:" $fracciones.Count
    foreach ($fraccion in $fracciones) {
        # Delimito la fraccion, calculo numero mixto
        $numero_mixto = 0
        $numero_negativo = $false
        $denominador = $fraccion.split("/")[1]
        if (!$denominador) {
            $denominador = 1
        }
        if ($fraccion.split(":").Count -gt 1) {
            $numero_mixto = [int]($fraccion.split(":")[0]) * $denominador
            if ($numero_mixto -lt 0) {
                $numero_mixto = $numero_mixto * -1
                $numero_negativo = $true
            }
            $numerador = [int](($fraccion.split(":")[1]).split("/")[0]) + $numero_mixto
        }
        else {
            $numerador = $fraccion.split("/")[0]
        }
        if ($numero_negativo) {
            $numerador = $numerador * -1
        }
        Write-Host $numerador"/"$denominador "+"
        # Calculo denominador final
        if (!([int]$res_denominador % [int]$denominador -eq 0)) {
            $res_denominador = [int]$res_denominador * [int]$denominador
        }
        $array_numerador = $array_numerador + $numerador
        $array_denominador = $array_denominador + $denominador
    }
    # Calculo numerador final
    for ($i = 0; $i -lt $fracciones.Count ; $i++ ) {
        $res_numerador = [int]$res_numerador + (([int]$res_denominador / [int]$array_denominador[$i]) * [int]$array_numerador[$i])
    }
    # Simplifacion
    $max_divisor= Get-mcd $res_numerador $res_denominador
    $res_numerador = [int]($res_numerador / $max_divisor)
    $res_denominador = [int]($res_denominador / $max_divisor)

    # Devuelvo el resultado
    Write-Host "Resultado final:" $res_numerador"/"$res_denominador
    #$path_salida = Split-Path -Path $Path
    Write-Output $res_numerador"/"$res_denominador > salida.out
    return
}

ejercicio6