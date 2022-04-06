#Requires -RunAsAdministrator

# Enable and start WMI service
function Enable-WMIService {

    $serviceName = "Winmgmt"
    $startupType = "Automatic"
    $wmiServiceExists = Get-Service | Where-Object {$_.Name -eq $serviceName}

    Write-Host "Enabling the Windows Management Instrumentation service..."

    if ($wmiServiceExists) {
     
        Set-Service -Name $serviceName -StartupType $startupType
        Start-Service -Name $serviceName 
        Get-Service -Name $serviceName
        Write-Host "Successfully enabled the the Windows Management Instrumentation service!" -ForegroundColor Green
        
        }
    
    else 
    
        {Write-Host "The $serviceName service was not found on this system. Please confirm that the service is present and try again" -ForegroundColor Red -ErrorAction Stop}
        
}

# Reinstall Global Protect
function Install-GlobalProtect {

    $GPInstall = "C:\temp\Global Protect Fix\Global Protect\Deploy-Application.exe"
    $GPVersion = "5.1.8"
    $GPAppName = "GlobalProtect"
    $uninstallKeyPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $GPVersInstalled = (

        Get-ItemProperty -Path $uninstallKeyPath | Where-Object { $_.DisplayVersion -Match $GPVersion }

        )

    $GPAppInstalled = (

        Get-ItemProperty -Path $uninstallKeyPath | Where-Object { $_.DisplayName -Match $GPAppName }

        )

    $GProcess = @("PanGPA", "PanGPS")
    $GProcessCheck = Get-Process $GProcess -ErrorAction SilentlyContinue

    Write-Host "Installing $GPAppName $GPVersion..."
    Write-Host "Checking if any $GPAppName processes are running..."

    if ($null -ne $GProcessCheck) {

        Write-Host "Stopping $GPAppName Processes..."
        $GProcessCheck | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "Processes successfully stopped. Proceeding with installation..."
       
        }

    else { Write-Host "Unable to find any running processes. Proceeding with installation..." }


    if((-Not $GPAppInstalled) -or (-Not $GPVersInstalled)) {

        Start-Process -FilePath $GPInstall -Wait
        Write-Host "$GPAppName $GPVersion installation completed successfully!" -ForegroundColor Green

        }

    else 
    
        { Write-Host "$GPAppName $GPVersion is already installed on your system" -ForegroundColor Yellow }

}

# Delete scheduled task
function Remove-ScheduledTask {
   
    $RunKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
    $KeyName = "GlobalProtectFixPostRebootScript"

    Write-Host "Removing scheduled post-reboot task..."
    
    if(Get-ItemProperty -Path $RunKeyPath -Name $KeyName -ErrorAction SilentlyContinue) {

        Remove-ItemProperty -Path $RunKeyPath -Name $KeyName -Force
        Get-ItemProperty -Path $RunKeyPath
        Write-Host "Scheduled task removed successfully!" -ForegroundColor Green
            
        }
    
    else

        {Write-Host "Scheduled post-reboot task has already been removed" -ForegroundColor Yellow}

}
