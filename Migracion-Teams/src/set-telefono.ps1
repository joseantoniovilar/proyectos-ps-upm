<#
.SYNOPSIS
Asigna telefono teams al usuario UPN 

.DESCRIPTION
Permite asignar el telefono al usuario upn de teams

.EXAMPLE
# Ejemplo de ejecución
# Desde la carpeta donde está el script:
cd 'C:\Users\user\Documents\Proyectos\Migracion teams telefonia\src'
.\set-telefono.ps1 -CsvPath '..\datos\usuarios.csv'

# Ejemplo de fichero CSV (delimitador ';', columnas upn;tel;iderloc):
# upn;tel;iderloc
# usuario1@dominio.com;600111222;12345
# usuario2@dominio.com;600333444;67890

.NOTES
Requiere Windows PowerShell 7 or later
Requiere Modulo MicrosoftTeams
Requiere Admininistrador consola de teams
Autor: joseantonio.vilar@upm.es
Fecha: 13/10/2025
Modificado: 22/10/2025
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, HelpMessage = "Ruta al fichero CSV con columnas upn;tel;iderloc (ej: ..\\datos\\test.csv)")]
    [ValidateNotNullOrEmpty()]
    [string]$CsvPath
)


# Iniciar medición del tiempo
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()



# log
$script:logFile = Join-Path -Path (Join-Path $PSScriptRoot '..\logs') -ChildPath "migracion-tel-teams.log"
$logDir = Split-Path $script:logFile
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir }


function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('OK','ERROR')][string]$Level = 'OK'
    )
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $entry = "$ts [$Level] $Message"
    switch ($Level) {
        'ERROR' { Write-Host $entry -ForegroundColor Red }
        'OK'    { Write-Host $entry -ForegroundColor Green }
        default { Write-Host $entry }
    }
    $entry + "`n" | Out-File -FilePath $script:logFile -Encoding utf8 -Append
}


# Comprobar/instalar módulo MicrosoftTeams 
$moduleName = 'MicrosoftTeams'
$module = Get-Module -ListAvailable -Name $moduleName

if (-not $module) {
    Write-Log "Módulo $moduleName no instalado. Intentando instalar..." 'WARN'
    try {
        if (-not (Get-Command -Name Install-Module -ErrorAction SilentlyContinue)) {
            Write-Log "Install-Module no disponible. Instale PowerShellGet/PackageManagement." 'ERROR'
            exit 1
        }
        Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        Write-Log "Módulo $moduleName instalado correctamente." 'OK'
    }
    catch {
        Write-Log "Falló la instalación del módulo $moduleName $($_ | Out-String)" 'ERROR'
        exit 1
    }
}
else {
    Write-Log "Módulo $moduleName disponible (versión: $($module.Version))." 'OK'
}

# Importar módulo
try {
    Import-Module $moduleName -ErrorAction Stop
    Write-Log "Módulo $moduleName importado." 'OK'
}
catch {
    Write-Log "No se pudo importar $moduleName $($_ | Out-String)" "ERROR"
    exit 1
}


# Conectar a Microsoft Teams
if (-not (Get-Command -Name Connect-MicrosoftTeams -ErrorAction SilentlyContinue)) {
    Write-Log "Connect-MicrosoftTeams no está disponible en el módulo cargado." 'ERROR'
    exit 1
}

try {
    Connect-MicrosoftTeams -ErrorAction Stop
    # comprobación ligera de conectividad (si falla, se registra como WARN pero no se sale)
    try {
        Get-CsTenantDialPlan -ErrorAction Stop | Out-Null
        Write-Log "Conexión a Microsoft Teams establecida y verificada." 'OK'
    }
    catch {
        Write-Log "Conexión a Teams establecida, comprobación ligera fallida: $($_ | Out-String)" 'ERROR'
    }v
}
catch {
    Write-Log "No se pudo conectar a Microsoft Teams: $($_ | Out-String)" 'ERROR'
    exit 1
}



# Leer usuarios
$users = Import-Csv -Path $csvPath -Delimiter ";" -Header 'upn','tel','iderloc'

#Para obtener la localizaciones de emergencia Get-CsOnlineLisLocation | OutGridView. Usar id
#Get-CsOnlineLisLocation | Where-Object {$_.Description -like  "*Rectorado*"}       
#$localizacionEmergencia="633d5d08-3bd5-4184-ab7a-b37f96082d77"
# https://learn.microsoft.com/en-us/powershell/module/microsoftteams/set-csphonenumberassignment?view=teams-ps

foreach ($user in $users) {
    $upn = ($user.upn -as [string]).Trim()
    $tel = ($user.tel -as [string]).Trim()
    $idloc = ($user.iderloc -as [string]).Trim()

    if ([string]::IsNullOrWhiteSpace($upn)) {
        Write-Log "Registro con UPN vacío -> omitido." 'ERROR'
        continue
    }

    if ([string]::IsNullOrWhiteSpace($tel)) {
        Write-Log "Registro $upn sin número (tel) -> omitido." 'ERROR'
        continue
    }
    
    try {
        Set-CsPhoneNumberAssignment -Identity $upn -PhoneNumber $tel -PhoneNumberType DirectRouting -LocationId $idloc -ErrorAction Stop
        Write-Log "Asignado $tel (DirectRouting) location '$idloc' a $upn" 'OK'
    }
    catch {
        Write-Log "Fallo al asignar número $tel a $upn $($_ | Out-String)" 'ERROR'
    }

    try {
        Set-CsOnlineVoicemailUserSettings -Identity $upn -PromptLanguage "es-ES" -ErrorAction Stop
        Write-Log "Idioma es-ES aplicado al buzón de $upn" 'OK'
    }
    catch {
        Write-Log "Fallo al establecer idioma del buzón para $upn $($_ | Out-String)" 'ERROR'
    }
}
# Desconectar de Microsoft Teams
Disconnect-MicrosoftTeams -Confirm:$false


# Detener medición y mostrar resultados
$stopwatch.Stop()
Write-Log "Tiempo total de ejecución: $($stopwatch.Elapsed.TotalSeconds) segundos" 'OK'
