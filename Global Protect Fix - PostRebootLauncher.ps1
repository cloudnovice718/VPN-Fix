# Script that launches the post-reboot file
 Start-Process powershell.exe -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass', '-NoExit', '-NoProfile', '-File "C:\temp\Global Protect Fix\Global Protect Fix - PostReboot.ps1"'
