<#
.SYNOPSIS
Esta función arroja una estadistica a partir de un log
.DESCRIPTION
Esta función arroja una estadistica a partir de un log. Muestra los promedios de duracion de llamadas por dia, por usuario, etc.
Cada llamada debe contar con 2 registros, uno indicando su comienzo, y, el otro, su fin.

El log debe tener los registros en el siguiente formato:
yyyy-mm-dd HH:MM:SS _ [usuario]
#donde [usuario] es el nombre del usuario (longitud variable)
.EXAMPLE
 ./ejercicio2.ps1 ./enunciado.txt

#>

# Ejercicio 2:
# Se cuenta con un archivo de log, donde se registraron todas las llamadas realizadas en una
# semana por un call center, donde se detalla el inicio y fin de las mismas. Estos registros tienen el
# siguiente formato, donde se indica quién realizó la llamada (usuario). Se debe considerar el primer
# registro como el inicio de la llamada y la siguiente como la finalización. Tener en cuenta que el
# proceso que registra las llamadas tiene problemas de sincronización, por lo que los registros no
# se encuentran ordenados.

# Se pide obtener y mostrar por pantalla los siguientes datos uno debajo del otro:
# ▪ Promedio de tiempo de las llamadas realizadas por día.
# ▪ Promedio de tiempo y cantidad por usuario por día.
# ▪ Los 3 usuarios con más llamadas en la semana.
# ▪ Cuántas llamadas no superan la media de tiempo por día y el usuario que tiene más
# llamadas por debajo de la media en la semana.

# Parámetros:
# • -Path: Directorio en el que se encuentran los archivos de log. Puede ser una ruta
# relativa o absoluta. No se debe realizar búsqueda recursiva dentro del directorio.

# Formato del registro de llamada:
# • Fecha y Hora: Formato YYYY-MM-DD HH:mm:ss
# • Usuario que realiza la llamada.
# • Separador: “ _ “ (espacio, guión bajo, espacio)

# Ejemplo de registros: ((inicio) y (fin) son a modo de ejemplo, no son parte del archivo)
# (inicio) 2020-03-09 14:22:00 _ aerodriguez
# (inicio) 2020-03-09 14:22:10 _ fmarino
# (inicio) 2020-03-09 14:22:11 _ vbo
# (fin) 2020-03-09 14:25:00 _ fmarino
# (fin) 2020-03-09 14:25:10 _ aerodriguez
# (inicio) 2020-03-09 14:26:40 _ aerodriguez
# (fin) 2020-03-09 14:26:41 _ vbo
# (fin) 2020-03-09 14:32:00 _ aerodriguez

# Criterios de corrección:
# Debe cumplir con el enunciado
# El script cuenta con una ayuda visible con Get-Help
# Validación correcta de los parámetros (Param)
# Proveer archivos de ejemplo para realizar pruebas
# Utilizar Format-List para formatear la salida por pantalla

param(
    [CmdletBinding()]
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Test-Path $_ })]
    $path
)

# convierte un numero entero (que expresa una cantidad de segundos) a un string de formato "hh:mm:ss"
Function SegundosAHoraString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][int] $segundos
    )

    $horasAux = ([int]($segundos / 3600)) % 3600
    $minutosAux = ([int]($segundos / 60)) % 60
    $segundosAux = $segundos % 60

    if ($horasAux -lt 10) {
        $horasAux = "0" + $horasAux
    }
    if ($minutosAux -lt 10) {
        $minutosAux = "0" + $minutosAux
    }
    if ($segundosAux -lt 10) {
        $segundosAux = "0" + $segundosAux
    }
    return $horasAux + ":" + $minutosAux + ":" + $segundosAux
}

#recibe 2 parametros de horas (en formato HH:MM:SS) y devuelve la resta (h1 - h2) en segundos
Function RestarHoras {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $hora1,
        [Parameter(Mandatory = $true)][string] $hora2
    )

    $hora1Aux = $hora1.split(":")
    [int]$horas1 = $hora1Aux[0]
    [int]$minutos1 = $hora1Aux[1]
    [int]$segundos1 = $hora1Aux[2]

    $hora2Aux = $hora2.split(":")
    [int]$horas2 = $hora2Aux[0]
    [int]$minutos2 = $hora2Aux[1]
    [int]$segundos2 = $hora2Aux[2]

    return ($horas1 * 3600 + $minutos1 * 60 + $segundos1) - ($horas2 * 3600 + $minutos2 * 60 + $segundos2)
}

#funcion principal de resolucion del ejercicio
function Get-Values {
    param (
        [CmdletBinding()]
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ })]
        $dir 
    )
    
    begin { 

        $vacio = $true
        $archivosVacios = $true
        
        $usuarioEnLlamada = @{ }
        $duracionAux = @{ }

        #punto 1
        $promedioPorDia = @{ }
        $cantidadPorDia = @{ }
        $textPromedioPorDia = @{ }
        #punto 2
        $promedioPorDiaPorUsuario = @{ }
        $cantidadPorDiaPorUsuario = @{ }
        $textPorDiaPorUsuario = @{ }
        #punto 3 y 4
        $cantidadPorUsuario = @{ }
        #punto 4
        $duracionPorLlamadaPorUsuario = @{ }
        [int]$mediaLlamadas = 0
        [int]$cantidadLlamadas = 0
        [int]$llamadasBajoMedia = 0
        $usuariosBajoMedia = @{ }

        $fileList = Get-ChildItem $dir
        
    }
    
    process {

        foreach ($file in $fileList) {
            $vacio = $false
            
            foreach ($line in Get-Content ($file)) {
                
                $archivosVacios = $false                

                $aux = $line.Split(" _ ")
                $splittedAux = $aux[0].split(" ")

                $dia = $splittedAux[0]
                $hora = $splittedAux[1]
                $usuario = $aux[1]
       

                if ($usuarioEnLlamada.Contains($usuario) -and $usuarioEnLlamada[$usuario] -eq $true ) {
                    #si estaba en llamada, la misma termina y se calcula el tiempo

                    $usuarioEnLlamada[$usuario] = $false
                    $duracionLlamada = RestarHoras $hora ($duracionAux[$usuario])

                    #punto 1
                    $promedioPorDia[$dia] += $duracionLlamada
                    $cantidadPorDia[$dia]++

                    #punto 2
                    $delimPorDiaPorUsuario = $dia + "_" + $usuario            
                    $promedioPorDiaPorUsuario[$delimPorDiaPorUsuario] += $duracionLlamada
                    $cantidadPorDiaPorUsuario[$delimPorDiaPorUsuario]++
            
                    #punto 3
                    $cantidadPorUsuario[$usuario]++

                    #punto 4
                    $duracionPorLlamadaPorUsuario[$usuario + [string]($cantidadPorUsuario[$usuario])] += $duracionLlamada
                    $cantidadLlamadas++
                    $mediaLlamadas += $duracionLlamada

                }
                else {
                    #si no estaba en llamada, abro una, digo que esta en llamada y anoto la hora a la que comienza

                    $usuarioEnLlamada[$usuario] = $true
                    $duracionAux[$usuario] = $hora

                }

            }
        }

        
    }
    
    end {

        if ($vacio -eq $true) {
            Write-Host El directorio `< $path `> esta vacio
            exit
        }
        else {
            if ($archivosVacios -eq $true) {
                Write-Host Todos los archivos del directorio `< $path `> están vacios
                exit
            } 
        }

        # ▪ 1) Promedio de tiempo de las llamadas realizadas por día.
        foreach ($d in $cantidadPorDia.GetEnumerator() | Sort-Object -Property Name -Descending) {
            $textPromedioPorDia[$d.Name] = SegundosAHoraString ($promedioPorDia[$d.Name] / $cantidadPorDia[$d.Name])
        }
        Write-Host
        Write-Output "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        Write-Output "1) Promedio de tiempo de las llamadas por dia"
        Write-Output "-------------------------------------------------------------------------"
        Write-Output $textPromedioPorDia | Format-Table -HideTableHeaders

        # ▪ 2) Promedio de tiempo y cantidad por usuario por día.
        foreach ($du in $cantidadPorDiaPorUsuario.GetEnumerator() | Sort-Object -Property Name) {
            $textPorDiaPorUsuario[$du.name] = "Cantidad: " + $cantidadPorDiaPorUsuario[$du.Name] + " - Promedio: " + 
            (SegundosAHoraString ($promedioPorDiaPorUsuario[$du.Name] / $cantidadPorDiaPorUsuario[$du.Name]))
        }
        Write-Output "-------------------------------------------------------------------------"
        Write-Output "2) Promedio de tiempo y cantidad por usuario por dia"
        Write-Output "-------------------------------------------------------------------------"
        Write-Output $textPorDiaPorUsuario | Format-Table -HideTableHeaders

        # ▪ 3) Los 3 usuarios con más llamadas en la semana.
        Write-Output "-------------------------------------------------------------------------"
        Write-Output "3) Top 3 usuarios con mas llamadas en la semana`n"
        Write-Output "-------------------------------------------------------------------------"
        foreach ($u in $cantidadPorUsuario.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 3) {
            Write-Host $u.Name con $u.Value llamadas
        }
        Write-Host

        # ▪ 4) Cuántas llamadas no superan la media de tiempo por día y el usuario que tiene más
        Write-Output "-------------------------------------------------------------------------"
        Write-Output "4) Llamadas que no superan la media, y que usuario tiene más de éstas"
        Write-Output "-------------------------------------------------------------------------" 
        $mediaLlamadas /= $cantidadLlamadas       
        foreach ($u in $cantidadPorUsuario.GetEnumerator() | Sort-Object -Property Value -Descending) {
            $n = $cantidadPorUsuario[$u.Name]
            for ($i = 1; $i -le $n; $i++) {

                $index = $u.Name + ($i.ToString())

                if (($duracionPorLlamadaPorUsuario[$index]) -lt $mediaLlamadas) {
                    $llamadasBajoMedia++
                    $usuariosBajoMedia[$u.Name]++
                }
            }
        }        
        
        Write-Host
        Write-Host Hay $llamadasBajoMedia llamadas bajo la media `(media = (SegundosAHoraString $mediaLlamadas)`)
        foreach ($u in $usuariosBajoMedia.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 1) {
            Write-Host $u.Name tiene mas llamadas bajo la media, con $u.Value llamadas
        }
        Write-Output "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        Write-Host       
    }
}

Get-Values $path
