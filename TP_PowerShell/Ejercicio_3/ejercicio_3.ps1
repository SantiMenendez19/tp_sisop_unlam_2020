<#
.SYNOPSIS
    
    Este es un script que monitorea un directorio de la creacion de archivos nuevos
.DESCRIPTION
   
    se recibe un directorio el cual se comienza a monitorear por creacion de nuevos archivos '.log', en tal caso se eliminan las versiones viejas dejando solo el ultimo que cumpla con el formato 'empresa-numero.log' 
.NOTES
	Nombre del archivo      : <ejercicio_3.ps1>
	Requisitos : PowerShell v7.0
	------------------------ Integrantes ------------------------
	Nombre				|	Apellido		|	DNI
	Pablo Anibal  		|	Gutierrez		|	39.413.681
	Facundo Leonel		|   Martin 			|	40.570.462
	Cristian Damian		|	Azamé			|	32.671.602
	Santiago Ezequiel	|	Menendez		|	40.893.022

    Solo se permite ingresar un directorio. Para desuscribirse de los eventos lanzados utilizar el comando
    Unregister-Event FileCreated
.EXAMPLE
    ./ejercicio_3.ps1
#>


Param([Parameter(Mandatory=$true)][String] $Directorio = "" )

#############################################################################
##Funcion para eliminar archivos
function eliminaArchivos {

$archivos = gci $Directorio *.log -Name | sort-object -descending
$caracteres = '[a-z][A-Z]'
	foreach($archivoL in $archivos)
		{
		$empresaL = $archivoL.split("-")[0]
		$versionL = $archivoL.split("-")[1]
		$versionL2 = $versionL.split(".")[0]
		if ((!($versionL2 -match $caracteres)) -And ($archivoL -match "(\w+)(?=-(\d*).log$)"))
			{
			foreach($archivoR in $archivos)
				{
				$empresaR = $archivoR.split("-")[0]
				$versionR = $archivoR.split("-")[1]
				$versionR2 = $versionR.split(".")[0]

		
				if ((!($versionR2 -match $caracteres)) -And ( $archivoR -match "(\w+)(?=-(\d*).log$)"))
				{
					if(($empresaL -eq $empresaR) -And (Test-Path $Directorio/$archivoR))
					{
						if([int]$versionL2 -gt [int]$versionR2){					
					Write-Host ""					
					Write-Host "archivoeliminado $archivoR"
					Remove-Item "$Directorio/$archivoR"
						}
					}
				}
				}
			}
		}

}
###########################################################################


##Programa principal

if (!(Test-Path $Directorio))
{
	Write-Warning "El directorio $Directorio no existe"
	return
}

eliminaArchivos

@("FileCreated") | ForEach-Object {
Unregister-Event -SourceIdentifier $_ -ErrorAction SilentlyContinue
Remove-Event -SourceIdentifier $_ -ErrorAction SilentlyContinue	
}

#se crea el objeto que monitorea
$fsw = New-Object IO.FileSystemWatcher $Directorio, $filter -Property @{ 
        IncludeSubdirectories = $false
        EnableRaisingEvents = $true
}

$onCreated = Register-ObjectEvent $fsw created -SourceIdentifier FileCreated -Action {
$Path = $Event.SourceEventArgs.FullPath
$Director = [io.path]::GetDirectoryName($Path)

$archivos = gci $Director *.log -Name | sort-object -descending
	$caracteres = '[a-z][A-Z]'
	foreach($archivoL in $archivos)
		{
		$empresaL = $archivoL.split("-")[0]
		$versionL = $archivoL.split("-")[1]
		$versionL2 = $versionL.split(".")[0]
		if ((!($versionL2 -match $caracteres)) -And ($archivoL -match "(\w+)(?=-(\d*).log$)"))
			{
			foreach($archivoR in $archivos)
				{
				$empresaR = $archivoR.split("-")[0]
				$versionR = $archivoR.split("-")[1]
				$versionR2 = $versionR.split(".")[0]

		
				if ((!($versionR2 -match $caracteres)) -And ( $archivoR -match "(\w+)(?=-(\d*).log$)"))
				{
					if(($empresaL -eq $empresaR) -And (Test-Path $archivoR)) 
					{
						if([int]$versionL2 -gt [int]$versionR2){					
					Write-Host ""					
					Write-Host "archivo eliminado $archivoR"
					Remove-Item "$Director/$archivoR"
						}
					}
				}
				}
			}
		}

}







