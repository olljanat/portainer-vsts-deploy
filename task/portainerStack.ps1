[CmdletBinding(DefaultParameterSetName = 'None')]
param
	(
	[String][Parameter(Mandatory=$true)]$ApiURL,
	[int][Parameter(Mandatory=$true)]$EndpointId,
	[Hashtable][Parameter(Mandatory=$true)]$AuthHeader
)

$StackName = Get-VstsInput -Name 'StackName' -Require
$ComposeFile = Get-VstsInput -Name 'ComposeFile' -Require
$tag = Get-VstsInput -Name 'tag' -Require

[array]$EnvList += New-Object -TypeName PSObject -Property @{
	"name" = "tag"
	"value" = $tag
}

Write-Host "Reading compose file"
[string]$ComposeFileContent = Get-Content -Path $ComposeFile -Raw

$BodyObject = New-Object -TypeName PSObject
$BodyObject | Add-Member -Type NoteProperty -Name StackFileContent -Value $ComposeFileContent
$BodyObject | Add-Member -Type NoteProperty -Name Env -Value $EnvList

Write-Host "Get list of existing stacks"
$Stacks = Invoke-RestMethod -Method GET -Headers $AuthHeader -UseBasicParsing -ContentType "application/json" -Uri $($ApiURL + "/stacks?endpointId=" + $endpointId)
$Stack = $Stacks | Where-Object {$_.Name -eq $StackName}
If ($Stack) {
	Write-Host "Found stack $StackName, updating..."
	$BodyObject | Add-Member -Type NoteProperty -Name id -Value $Stack.Id
	$BodyObject | Add-Member -Type NoteProperty -Name Prune -Value $True
	$BodyJSON = $BodyObject | ConvertTo-Json -Depth 99
	Write-Verbose "Generated JSON: $BodyJSON"
	$StackUpdate = Invoke-RestMethod -Method PUT -Headers $AuthHeader -UseBasicParsing -ContentType "application/json" -Uri $($ApiURL + "/stacks/" + $Stack.Id + "?endpointId=" + $endpointId) -Body $BodyJSON
} Else {
	Write-Host "Not found stack $StackName, creating..."
	$SwarmInfo = Invoke-RestMethod -Method GET -Headers $AuthHeader -UseBasicParsing -ContentType "application/json" -Uri $($ApiURL + "/endpoints/" + $endpointId + "/docker/swarm")
	$BodyObject | Add-Member -Type NoteProperty -Name Name -Value $StackName
	$BodyObject | Add-Member -Type NoteProperty -Name SwarmId -Value $SwarmInfo.ID
	$BodyJSON = $BodyObject | ConvertTo-Json -Depth 99
	Write-Verbose "Generated JSON: $BodyJSON"
	$StackCreate = Invoke-RestMethod -Method POST -Headers $AuthHeader -UseBasicParsing -ContentType "application/json" -Uri $($ApiURL + "/stacks?endpointId=" + $endpointId + "&method=string&type=1") -Body $BodyJSON
}

