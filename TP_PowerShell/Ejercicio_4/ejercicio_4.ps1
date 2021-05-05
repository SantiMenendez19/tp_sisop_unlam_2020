<#
.SYNOPSIS
Esta función comprime y elimina los archivos .log segun la empresa a la que pertenecen
.DESCRIPTION
Esta función comprime y elimina los archivos .log segun la empresa a la que pertenecen
.PARAMETER Directorio
Path de la carpeta de logs a tomar.
.PARAMETER DirectorioZip
Path de la carpeta de zips a guardar.
.PARAMETER Empresa
Logs de la empresa a comprimir, si no se ingresa se comprimiran los logs de todas las empresas existentes.
.NOTES
	Nombre del archivo      : <ejercicio_4.ps1>
	Autor         : Santiago Menendez
	Requisitos : PowerShell v7.0
	Copyright 2020 - Santiago Menendez
.EXAMPLE
./ejercicio_4.ps1 -Directorio "logs" -DirectorioZip "zips" -Empresa "movistar"
.EXAMPLE
./ejercicio_4.ps1 -Directorio "logs" -DirectorioZip "zips"
#>

# Parametros de Entrada
Param (
    [Parameter(Mandatory = $true)][string] $Directorio = "",
    [Parameter(Mandatory = $true)][string] $DirectorioZip = "",
    [string] $Empresa = ""
)

function ejercicio4 {
    # Validacion de parametros
    Write-Host "Path de logs: " $Directorio
    Write-Host "Path de zips: " $DirectorioZip
    if (Test-Path $Directorio) {
        Write-Host "Existe el directorio $Directorio"
    }
    else {
        Write-Host "No existe el directorio $Directorio , se termina el proceso"
        return
    }
    if (Test-Path $DirectorioZip) {
        Write-Host "Existe el directorio $DirectorioZip"
    }
    else {
        Write-Host "No existe el directorio $DirectorioZip , se termina el proceso"
        return
    }
    if ($Empresa) {
        Write-Host "Se comprimiran los logs de la empresa" $Empresa
        $flag_empresa = $True
    }
    else {
        Write-Host "Se comprimiran los logs de todas las empresas disponibles"
        $flag_empresa = $False
    }

    $caracteres = '[a-zA-Z]+$'
    # Zipeado y borrado de logs
    if ($flag_empresa) {
        $archivos = Get-ChildItem $Directorio/$Empresa-*.log -Name | sort-object -descending
        foreach ($archivoL in $archivos) {
            $empresaL = $archivoL.split("-")[0]
            $versionL = $archivoL.split("-")[1]
            $versionL2 = $versionL.split(".")[0]
            if (!($versionL2 -match $caracteres) -And ($empresaL -match $caracteres)) {
                foreach ($archivoR in $archivos) {
                    if (Test-Path $Directorio/$archivoR -PathType Leaf) {
                        $empresaR = $archivoR.split("-")[0]
                        $versionR = $archivoR.split("-")[1]
                        $versionR2 = $versionR.split(".")[0]
                        if (!($versionR2 -match $caracteres) -And ($empresaR -match $caracteres)) {
                            if ($empresaL -eq $empresaR -And $versionL2 -gt $versionR2) {
                                Write-Host "Se comprimira el archivo" $archivoR
                                Compress-Archive -Path $Directorio/$archivoR -DestinationPath $DirectorioZip/$empresaR.zip -Update
                                Write-Host "Se eliminara el archivo $archivoR"
                                Remove-Item $Directorio/$archivoR
                            }
                        }
                    }
                }
            }
        }
    }
    else {
        $archivos = Get-ChildItem $Directorio *.log -Name | sort-object -descending
        foreach ($archivoL in $archivos) {
            $empresaL = $archivoL.split("-")[0]
            $versionL = $archivoL.split("-")[1]
            $versionL2 = $versionL.split(".")[0]
            if ($empresaL -match $caracteres) {
                Write-Host $empresaL
            }
            if (!($versionL2 -match $caracteres) -And ($empresaL -match $caracteres)) {
                foreach ($archivoR in $archivos) {
                    if (Test-Path $Directorio/$archivoR -PathType Leaf) {
                        $empresaR = $archivoR.split("-")[0]
                        $versionR = $archivoR.split("-")[1]
                        $versionR2 = $versionR.split(".")[0]
                        if (!($versionR2 -match $caracteres) -And ($empresaR -match $caracteres)) {
                            if ($empresaL -eq $empresaR -And $versionL2 -gt $versionR2) {
                                Write-Host "Se comprimira el archivo" $archivoR "para la empresa" $empresaR
                                Compress-Archive -Path $Directorio/$archivoR -DestinationPath $DirectorioZip/$empresaR.zip -Update
                                Write-Host "Se eliminara el archivo $archivoR"
                                Remove-Item $Directorio/$archivoR
                            }
                        }
                    }
                }
            }
        }
    }
    Write-Host "Los archivos fueron comprimidos, fin del proceso"
    return
}

ejercicio4