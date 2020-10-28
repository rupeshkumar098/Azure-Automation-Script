 param (
     [Parameter(Mandatory=$true)]$dName, [Parameter(Mandatory=$true)]$smaPass
     )
#LogFile Provisioning
$timestamp = Get-Date -F MM-dd-yyyy-hh-mm-ss
$LogFile= "C:\ADDSLogs\"+ $timestamp + ".log"
Start-Transcript -path $LogFile -append

# Set Winrm trust for remote powershell 
Set-Item wsman:\localhost\client\trustedhosts * -Force 

# Turn Off Windows Firewall 
netsh advfirewall set allprofiles state off 

#Converting a simple string to secure string for -SafeModeAdministratorPassword
$Secure2 = ConvertTo-SecureString $smaPass -AsPlainText -Force

try
{
	#Installing ADDS Features
	Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
	Write-Host "ADDS Features Installed."

	#Promite this PC to Domain Controller
	Import-Module ADDSDeployment
	Install-ADDSForest `
	-DomainName $dName `
	-SafeModeAdministratorPassword $Secure2 `
	-NoRebootOnCompletion `
	-LogPath "C:\Logs.txt" -Force
	Write-Host "Server Prompted to Domain Controller Successfully."
	
}
catch
{ 
	Write-Host $_.Exception.Message
}

# Turn On Windows Firewall 
netsh advfirewall set allprofiles state On

Write-Host "ALL DONE, Now Rebooting the Server."
#Restart the computer to complete the process
Restart-computer

Stop-Transcript



