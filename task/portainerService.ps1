[CmdletBinding(DefaultParameterSetName = 'None')]
param
	(
	[String][Parameter(Mandatory=$true)]$ApiURL,
	[int][Parameter(Mandatory=$true)]$EndpointId,
	[Hashtable][Parameter(Mandatory=$true)]$AuthHeader
)

$ServiceName = Get-VstsInput -Name 'ServiceName' -Require
$ImageName = Get-VstsInput -Name 'ImageName' -Require
$tag = Get-VstsInput -Name 'tag' -Require
$Constraints = Get-VstsInput -Name 'Constraints'
$Networks = Get-VstsInput -Name 'Networks'
$Configs = Get-VstsInput -Name 'Configs'
$Secrets = Get-VstsInput -Name 'Secrets'

Write-Host "Get list of existing services"
$Services = Invoke-RestMethod -Method GET -Headers $AuthHeader -UseBasicParsing -ContentType "application/json" -Uri $($ApiURL + "/endpoints/" + $endpointId + "/docker/services?filters=%7B%7D")
$Service = $Services | Where-Object {$_.Spec.Name -eq $ServiceName}
If ($Service) {
	Write-Host "Found service $ServiceName, updating..."
	$BodyObject = $Service.Spec
	$BodyObject.TaskTemplate.ContainerSpec.Image = ($BodyObject.TaskTemplate.ContainerSpec.Image -split ":")[0] + ":" + $tag
	$BodyJSON = $BodyObject | ConvertTo-Json -Depth 99
	Write-Verbose "Generated JSON: $BodyJSON"
	$ServiceUpdate = Invoke-RestMethod -Method POST -Headers $AuthHeader -UseBasicParsing -ContentType "application/json" -Uri $($ApiURL + "/endpoints/" + $endpointId + "/docker/services/" + $Service.ID + "/update?version=" + $Service.Version.Index) -Body $BodyJSON
} Else {
	Write-Host "Not found service $ServiceName, creating..."
	
	[array]$ConfigsSplit = $Configs -Split ","
	ForEach ($Config in $ConfigsSplit) {
		If (!([string]::IsNullOrEmpty($Config))) {
			[array]$ConfigList += New-Object -TypeName PSObject -Property @{
				"ConfigName" = $Config
			}
		}
	}
	
	[array]$SecretsSplit = $Secrets -Split ","
	ForEach ($Secret in $SecretsSplit) {
		If (!([string]::IsNullOrEmpty($Secret))) {
			[array]$SecretList += New-Object -TypeName PSObject -Property @{
				"SecretName" = $Secret
			}
		}
	}
	
	$ContainerSpec = New-Object -TypeName PSObject
	$ContainerSpec | Add-Member -Type NoteProperty -Name Image -Value $($ImageName + ":" + $tag)
	
	## Disabled because not fully functional
	#$ContainerSpec | Add-Member -Type NoteProperty -Name Configs -Value $ConfigList
	#$ContainerSpec | Add-Member -Type NoteProperty -Name Secrets -Value $SecretList

	
	[array]$ConstraintsSplit = $Constraints -Split ","
	ForEach ($Constraint in $ConstraintsSplit) {
		If (!([string]::IsNullOrEmpty($Constraint))) {
			[array]$ConstraintList += $Constraint
		}
	}
	$Placement = New-Object -TypeName PSObject
	$Placement | Add-Member -Type NoteProperty -Name Constraints -Value $ConstraintList

	
	$TaskTemplate = New-Object -TypeName PSObject
	$TaskTemplate | Add-Member -Type NoteProperty -Name ContainerSpec -Value $ContainerSpec
	$TaskTemplate | Add-Member -Type NoteProperty -Name Placement -Value $Placement
	
	
	$Mode = New-Object -TypeName PSObject -Property @{
		"Replicated" = New-Object -TypeName PSObject -Property @{
			"Replicas" = 2
		}
	}
	
	
	[array]$NetworksSplit = $Networks -Split ","
	ForEach ($Network in $NetworksSplit) {
		If (!([string]::IsNullOrEmpty($Network))) {
			[array]$NetworkList += New-Object -TypeName PSObject -Property @{
				"Target" = $Network
			}
		}
	}
	
	$BodyObject = New-Object -TypeName PSObject
	$BodyObject | Add-Member -Type NoteProperty -Name Name -Value $ServiceName
	$BodyObject | Add-Member -Type NoteProperty -Name TaskTemplate -Value $TaskTemplate
	$BodyObject | Add-Member -Type NoteProperty -Name Mode -Value $Mode
	$BodyObject | Add-Member -Type NoteProperty -Name Networks -Value $NetworkList
	

	$BodyJSON = $BodyObject | ConvertTo-Json -Depth 99
	Write-Verbose "Generated JSON: $BodyJSON"
	Try {
		$ServiceCreate = Invoke-RestMethod -Method POST -Headers $AuthHeader -UseBasicParsing -ContentType "application/json" -Uri $($ApiURL + "/endpoints/" + $endpointId + "/docker/services/create") -Body $BodyJSON
	} Catch {
		$Content = $_.Exception.Message
		$response = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($response)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$DetailedContent = $reader.ReadToEnd()
		$Message = ($DetailedContent | ConvertFrom-Json -ErrorAction "SilentlyContinue").message
		If ($Message) {
			throw $Message 
		} Else {
			throw $Content
		}
	}
}

