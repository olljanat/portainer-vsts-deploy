[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
Import-VstsLocStrings "$PSScriptRoot\task.json"


# Login
Write-Verbose "Parsing parameters..."
$PortainerService = Get-VstsInput -Name 'PortainerService' -Require
$ServiceEndpoint = Get-VstsEndpoint -Name $PortainerService -Require
$ApiURL = $ServiceEndpoint.Url + "api"
$UserName = $ServiceEndpoint.Auth.parameters.username
$Password = $ServiceEndpoint.Auth.parameters.password
$EndpointId = $ServiceEndpoint.Auth.parameters.endpointId

$AuthURL = $($ApiURL + "/auth")
Write-Verbose "Login to $AuthURL using username: $UserName and password $Password"
$Token = Invoke-RestMethod -Method POST -Body ('{"Username":"' + $UserName + '", "Password":"' + $Password  + '"}') -ContentType "application/json" -Uri $AuthURL
$AuthHeader = @{Authorization="Bearer $($token.jwt)"}


$action = Get-VstsInput -Name 'action' -Require
switch ( $action )
{
	"Deploy an stack" {
		. "$PSScriptRoot\portainerStack.ps1" -ApiURL $ApiURL -EndpointId $EndpointId -AuthHeader $AuthHeader
	}
	"Deploy an service" {
		. "$PSScriptRoot\portainerService.ps1" -ApiURL $ApiURL -EndpointId $EndpointId -AuthHeader $AuthHeader
	}
	default { Write-Warning "Action: $action is not yet implemented" }
}
