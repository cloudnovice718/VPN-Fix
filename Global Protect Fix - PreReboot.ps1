#Requires -RunAsAdministrator

# Disable WMI Service
function Disable-WMIService {

    $serviceName = "Winmgmt"
    $startupType = "Disabled"
    $wmiServiceExists = Get-Service | Where-Object {$_.Name -eq $serviceName}

    Write-Host "Disabling the Windows Management Instrumentation service..."

    if ($wmiServiceExists) {

        Stop-Service -Name $serviceName -Force
        Set-Service -Name $serviceName -StartupType $startupType
        Get-Service -Name $serviceName
        Write-Host "The Windows Management Instrumentation service has been successfully disabled!" -ForegroundColor Green        
        
        }     
    
    else 
    
        {Write-Host "The $serviceName service cannot be found on this system. Please confirm that the service is present and try again" -ForegroundColor Red -ErrorAction Stop}
        
}

# Delete the files under C:\Windows\System32\wbem\Repository
function Delete-FilesInSubFolder {

    $FolderLocation = "C:\Windows\System32\wbem\Repository"
    $FolderExists = Test-Path -Path $FolderLocation

    Write-Host "Deleting files from $FolderLocation"

    if ($FolderExists) 

        {Get-ChildItem -Path $FolderLocation -Recurse | Remove-Item; Write-Host "Contents of $FolderLocaton successfully removed!" -ForegroundColor Green}

    else 
        
        {Write-Host "$FolderLocation not found. Continuing..." -ForegroundColor Yellow}

}

# Delete the Palo Alto Networks folder from the registry
function Delete-RegKey {

    $RegKeyPathLM = "HKLM:\SOFTWARE\Palo Alto Networks"
    $RegKeyPathCU = "HKCU:\SOFTWARE\Palo Alto Networks"
    $LMRegKeyPathExists = Test-Path -Path $RegKeyPathLM
    $CURegKeyPathExists = Test-Path -Path $RegKeyPathCU

    if ($LMRegKeyPathExists)

        {Remove-Item -Path $RegKeyPathLM -Recurse; Write-Host "$RegKeyPathLM has been successfully removed!" -ForegroundColor Green}

    else 
    
        {Write-Host "$RegKeyPathLM does not exist. Continuing..." -ForegroundColor Yellow}


    if ($CURegKeyPathExists)

        {Remove-Item -Path $RegKeyPathCU -Recurse; Write-Host "$RegKeyPathCU has been successfully removed!" -ForegroundColor Green}

    else 
    
        {Write-Host "$RegKeyPathCU does not exist. Continuing..." -ForegroundColor Yellow}

}

# Uninstall GlobalProtect 
function Remove-GlobalProtect {

    $GPAppName = "GlobalProtect"
    $GPAppInstalled = (

        Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
        Where-Object { $_.DisplayName -Match $GPAppName }

        )

    Write-Host "Uninstalling $GPAppName..."

    if ($GPAppInstalled)

        {Get-Package -Name $GPAppName -ProviderName "msi" | Uninstall-Package; Write-Host "$GPAppName removed successfully!" -ForegroundColor Green}

    else

        {Write-Host "$GPAppName not installed. Continuing..." -ForegroundColor Yellow}

}

<# Make sure that the virtual adapter in not present in the Network adapter settings
function Verify-VirtualAdapterNotPresent {

    $VirtualAdapterName = "PANGP Virtual Ethernet Adapter"
    $VirtualAdapterExists = Get-PnpDevice | Where-Object {$_.FriendlyName -eq $VirtualAdapterName}

    Write-Host "Checking if $VirtualAdapterName is present..."

    if ($VirtualAdapterExists) {

        Invoke-Command -ScriptBlock {pnputil /delete-driver oem50.inf /force}
        Write-Host "$VirtualAdapterName removed successfully!" -ForegroundColor Green
        
        }
        
    else 
        
        {Write-Host "$VirtualAdapterName is not currently present on this system. Continuing..." -ForegroundColor Yellow}

}
#>

# Ensure post-reboot script runs automatically on reboot
function Schedule-PostRebootTask {

    $RunKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
    $KeyName = "GlobalProtectFixPostRebootScript"
    $KeyValue = 'powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File "C:\temp\Global Protect Fix\Global Protect Fix - PostRebootLauncher.ps1"'

    Write-Host "Preparing system for reboot..."

    if(-not(Get-ItemProperty -Path $RunKeyPath -Name $KeyName -ErrorAction SilentlyContinue)) {

    Write-Host "Scheduling post-reboot tasks..."
    Set-ItemProperty -Path $RunKeyPath -Name $KeyName -Value $KeyValue -Force
    Get-ItemProperty -Path $RunKeyPath
    Write-Host "The post-reboot tasks have been scheduled successfully!" -ForegroundColor Green

    }

    else

        {Write-Host "The post-reboot tasks have already been scheduled. Continuing..." -ForegroundColor Yellow}
        
}

# Reboot machine
function Perform-Reboot {

    Write-Host "Rebooting computer..."
    Invoke-Command -ScriptBlock {shutdown /r} 

}

Disable-WMIService
Delete-FilesInSubFolder
Delete-RegKey
Remove-GlobalProtect
#Verify-VirtualAdapterNotPresent
Schedule-PostRebootTask
Perform-Reboot

exit