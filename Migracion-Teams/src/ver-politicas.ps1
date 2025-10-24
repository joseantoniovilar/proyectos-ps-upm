
<# 
Requisitos:
- PowerShell 7+ recomendado
- Módulo MicrosoftTeams (versión reciente)
#>

#
$module = Get-Module MicrosoftTeams -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
if (-not $module) {
  Install-Module MicrosoftTeams -Scope CurrentUser -Force -AllowClobber
}
Import-Module MicrosoftTeams -ErrorAction Stop
Connect-MicrosoftTeams
#Disconnect-MicrosoftTeams

#
function Get-PolicyMap {
    param($Assignments)
    $map = @{}
    foreach ($a in $Assignments) {
        # Ejemplos de PolicyType: TeamsMeetingPolicy, TeamsCallingPolicy, TeamsMessagingPolicy,
        # TeamsAppSetupPolicy, TeamsAppPermissionPolicy, OnlineVoiceRoutingPolicy, etc.
        $map[$a.PolicyType] = $a.PolicyName
    }
    return $map
}

#
    $upn = 'joseantonio.vilar@upm.es'
    $user = Get-CsOnlineUser -Filter "UserPrincipalName -like '$upn'"
    Write-host Informacion del usuario
    $user
    # --- Asignaciones de políticas por usuario
    $assignments = $null
    try {
        $assignments = Get-CsUserPolicyAssignment -Identity $upn -ErrorAction Stop
    } catch {
        # Algunas organizaciones no tienen este cmdlet disponible en versiones antiguas
        $assignments = @()
    }
    $p = Get-PolicyMap -Assignments $assignments
    write-host Politicas Asignadas
    write-host $p
   
    # --- Teléfono y tipo (Direct Routing / Calling Plans / etc.)
    # Preferimos buscar por AssignedPstnTargetId (el UPN del usuario)

    $numInfo = Get-CsPhoneNumberAssignment -AssignedPstnTargetId $upn -ErrorAction Stop | Select-Object -First 1
    $numInfo

    # --- Voicemail
    $vm = Get-CsOnlineVoicemailUserSettings -Identity $upn -ErrorAction Stop
    $vm
