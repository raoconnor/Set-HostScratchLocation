<# 
Get-vm-details

.Description
    Set scratch
	russ 02/05/2016

    
.Example
    .\Set-MutipleHostScratchLocation.ps1
#>
# Enter variables

$vmhost = Read-Host "Enter host name"	
$password  = Read-Host "Enter the root password for hosts?"  
	
connect-viserver $vmhost -User root -Password $password
#if (!$vmhost) { Write-Host "Error no host specificed" } -ErrorAction Stop

#Getting the path of the script, this is needed to reset back after mounting drive
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

# Load variables
$vmh = Get-VMHost 
$dirName = $vmh.NetworkInfo.HostName
$datastoreName = Read-Host "Enter name of datasatstore used for scatch logs"

# Mount drive
New-PSDrive -Name "mounteddatastore" -Root \ -PSProvider VimDatastore -Datastore (Get-Datastore "$datastoreName")
Set-Location mounteddatastore:\


#New-Item "VMwareLogs" -ItemType directory
New-Item "VMwareLogs\.locker-$dirName" -ItemType directory

# Load path
$datastore = Get-datastore $datastoreName
$ds = $datastore.Name
$path = "/vmfs/volumes/$ds/VMwareLogs/.locker-$dirName"


# Check current setting
Get-VMhost | Get-AdvancedSetting -Name "ScratchConfig.ConfiguredScratchLocation" | ft -a

# Set location
Get-VMhost | Get-AdvancedSetting -Name "ScratchConfig.ConfiguredScratchLocation" | Set-AdvancedSetting -Value "$path" -Confirm:$false


# Check new setting
Get-VMhost | Get-AdvancedSetting -Name "ScratchConfig.ConfiguredScratchLocation" | ft -a

#Change location back to original
Set-Location $scriptPath

disconnect-viserver $vmh.Name -Confirm:$false
