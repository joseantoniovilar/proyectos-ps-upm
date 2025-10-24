
<#
.SYNOPSIS
Asigna politicas de teams al usario UPN

.DESCRIPTION
Permite asignar ciertas políticas necesaria para la migración de la telefonía a teams

.EXAMPLE
# Ejemplo de ejecución
# Desde la carpeta donde está el script:
cd 'C:\Users\user\Documents\Proyectos\Migracion teams telefonia\src'
.\aplicar-politicas.ps1 -CsvPath '..\datos\usuarios.csv'

# Ejemplo de fichero CSV (delimitador ';', columnas upn;tel;iderloc):
# upn;tel;iderloc
# usuario1@dominio.com;+34600111222;r23r34mm34r2.m12345
# usuario2@dominio.com;+34600333444;rrklrm678rrmkr90

.NOTES
Requiere Windows PowerShell 7 or later
Requiere Modulo MicrosoftTeams
Requiere Admininistrador consola de teams
Autor: joseantonio.vilar@upm.es
Fecha: 06/10/2025
Modificado: 20/10/2025
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
    Write-Log "Módulo $moduleName no instalado. Intentando instalar..." 'ERROR'
    try {
        if (-not (Get-Command -Name Install-Module -ErrorAction SilentlyContinue)) {
            Write-Log "Install-Module no disponible. Instale PowerShellGet/PackageManagement." 'ERROR'
            exit 1
        }
        Install-Module -Name $moduleName -Scope CurrentUser -Force
        Write-Log "Módulo $moduleName instalado correctamente." 'OK'
    }
    catch {
        Write-Log "Fallo al instalar el módulo $moduleName $_" 'ERROR'
        exit 1
    }
}

# Conectar a Microsoft Teams
if (-not (Get-Command -Name Connect-MicrosoftTeams -ErrorAction SilentlyContinue)) {
    Write-Log "Connect-MicrosoftTeams no está disponible en el módulo cargado." 'ERROR'
    exit 1
}

try {
    Connect-MicrosoftTeams -ErrorAction Stop
    Write-Log "Conectado a Microsoft Teams correctamente." 'OK'
}
catch {
    Write-Log "Fallo al conectar a Microsoft Teams: $_" 'ERROR'
    exit 1
}

# Comprobar existencia del fichero CSV
$csvExiste = Resolve-Path -Path $CsvPath -ErrorAction SilentlyContinue
if (-not $csvExiste) {
    Write-Log "Fichero CSV '$CsvPath' no encontrado." 'ERROR'
    exit 1
}

# Leer usuarios
$users = Import-Csv -Path $csvPath -Delimiter ";" -Header 'upn','tel','iderloc'

foreach ($user in $users) {
    $upn = ($user.upn -as [string]).Trim()
    $tel = ($user.tel -as [string]).Trim()
    #$currentPoliticas = Get-CsUserPolicyAssignment  -Identity $upn 
    
    if ([string]::IsNullOrWhiteSpace($upn)) {
        Write-Log "Registro con UPN vacío -> vacio." 'ERROR'
        continue
    }

    if ([string]::IsNullOrWhiteSpace($tel)) {
        Write-Log "Registro $upn sin número (tel) -> vacio." 'ERROR'
        continue
    }

    # Asignar políticas
    try {
        #https://learn.microsoft.com/en-us/powershell/module/microsoftteams/grant-cscallinglineidentity?view=teams-ps
        #Grant-CsExternalAccessPolicy -Identity $upn -PolicyName "FederationAndPICDefault"
        #https://learn.microsoft.com/en-us/powershell/module/microsoftteams/grant-cscallinglineidentity?view=teams-ps
        Grant-CsCallingLineIdentity -Identity $upn -PolicyName "Normal-UPM"
        Write-Log "Aplicada politica Normal-UPM a $upn" 'OK'
    }
    catch {
        Write-Log "Aplicada politica Normal-UPM a $upn" 'ERROR'
    }

    try {
        
        #Grant-CsTeamsMeetingPolicy -Identity $upn -PolicyName "BposSAllModality"
        #https://learn.microsoft.com/en-us/powershell/module/microsoftteams/grant-cstenantdialplan?view=teams-ps
        Grant-CsTenantDialPlan -Identity $upn -PolicyName "C3-Nacional-Movil" 
        Write-Log "Aplicada politica C3-Nacional-Móvil a $upn" 'OK'
    }
    catch {
       Write-Log "Aplicada politica C3-Nacional-Móvil a $upn" 'ERROR'
    }
    
    try {
         Grant-CsOnlineVoiceRoutingPolicy -Identity $upn -PolicyName "VoiceRoutingPolicy1"
         Write-Log "Aplicada politica VoiceRoutingPolicy1 a $upn" 'OK'

    }
    catch {
        Write-Log "Aplicada politica VoiceRoutingPolicy1 a $upn" 'ERROR'
    }

    try {
        Grant-CsTeamsCallingPolicy -Identity $upn -PolicyName "CP-1"
        Write-Log "Aplicada politica CP-1 a $upn" 'OK'

    }
    catch {
       Write-Log "Aplicada politica VoiceRoutingPolicy1 a $upn" 'ERROR'
    }

}


# Desconectar de Microsoft Teams
Disconnect-MicrosoftTeams -Confirm:$false

# Detener medición y mostrar resultados
$stopwatch.Stop()
Write-Log "Tiempo total de ejecución: $($stopwatch.Elapsed.TotalSeconds) segundos" 'OK'