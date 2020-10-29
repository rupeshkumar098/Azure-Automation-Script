 param (
     [Parameter(Mandatory=$true)]$dName, [Parameter(Mandatory=$true)]$smaPass
     )
#LogFile Provisioning
$timestamp = Get-Date -F MM-dd-yyyy-hh-mm-ss
$LogFile = "C:\ADDSLogs\"+"log "+ $timestamp + ".log"
Start-Transcript -path $LogFile -append

# Turn Off Windows Firewall 
netsh advfirewall set allprofiles state off 

#Converting a simple string to secure string for -SafeModeAdministratorPassword
$Secure2 = ConvertTo-SecureString $smaPass -AsPlainText -Force

try
{
	#Installing ADDS Features
	Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
	Write-Host "ADDS Features Installed."

	#Promote this PC to Domain Controller
	Import-Module ADDSDeployment
	Install-ADDSForest `
	-DomainName $dName `
	-SafeModeAdministratorPassword $Secure2 `
	-LogPath "C:\Logs" -Force
	Write-Host "Server Promoted to Domain Controller Successfully."
	
}
catch
{ 
	Write-Host $_.Exception.Message
}

# Turn On Windows Firewall 
netsh advfirewall set allprofiles state On

Write-Host "ALL DONE, Now Rebooting the Server."
#Restart the computer to complete the process


Stop-Transcript



