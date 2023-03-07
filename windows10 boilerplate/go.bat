cd "resrc"
"./PowerShell-7.0.3-win-x64.msi" /passive ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
powershell "Set-ExecutionPolicy RemoteSigned -scope CurrentUser"
powershell "./therealinstall.ps1"