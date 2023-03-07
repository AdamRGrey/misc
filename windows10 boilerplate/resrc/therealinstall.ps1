#be admin, we're going to fuck with registry
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "pwsh";
   $newProcess.Arguments = """" + $myInvocation.MyCommand.Definition + """";
   $newProcess.Verb = "RunAs";
   [System.Diagnostics.Process]::Start($newProcess);
   exit
}

#customize windows
#regedit: hide recycle bin, skip recycle bin, show file extensions, better time format, powershell scripts run by default
Set-Content -Path ~/boilerplate_registry.reg -Value @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement]
"ScoobeSystemSettingEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel]
"{645FF040-5081-101B-9F08-00AA002F954E}"=dword:00000001
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel]
"{645FF040-5081-101B-9F08-00AA002F954E}"=dword:00000001

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoRecycleFiles"=dword:00000001
"ConfirmFileDelete"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoRecycleFiles"=dword:00000001
"ConfirmFileDelete"=dword:00000001

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"HideFileExt"=dword:00000000
"Hidden":dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"HideFileExt"=dword:00000000
"Hidden":dword:00000001

[HKEY_CURRENT_USER\Control Panel\International]
"sShortDate"="yyyy-MM-dd"
"sShortTime"="HH:mm"
"sTimeFormat"="HH:mm:ss"
[HKEY_LOCAL_MACHINE\Control Panel\International]
"sShortDate"="yyyy-MM-dd"
"sShortTime"="HH:mm"
"sTimeFormat"="HH:mm:ss"

[HKEY_CLASSES_ROOT\.ps1]
@="Microsoft.PowerShellScript.1"
[HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\Open\Command]
@="\"$((get-command pwsh).Source)\" \"-Command\" \"if((Get-ExecutionPolicy ) -ne 'AllSigned') { Set-ExecutionPolicy -Scope Process Bypass }; & '%1'\""
[HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\0\Command]
@="\$((get-command pwsh).Source)\" \"-Command\" \"if((Get-ExecutionPolicy ) -ne 'AllSigned') { Set-ExecutionPolicy -Scope Process Bypass }; & '%1'\""
"@
regedit /s $(Resolve-Path ~/boilerplate_registry.reg)
Write-Host "registry updated: hide recycle bin, skip recycle bin, show delete confirmation dialog, show file extensions, better time format, powershell scripts run by default (like bats)"

Set-TimeZone -Name "Eastern Standard Time"
Write-Host "Set timezone to Eastern Standard. (pretty sure even if it's daylight savings time at the moment, it knows what we're talking about)"

#remove desktop shortcuts, Notably Edge.
rm "~/Desktop/*.lnk";
Write-Host "desktop shortcuts removed"

#remove some known windows bloatware. 
#king.com = candy crush, farm heroes
#zunemusic = groove music
$bloatwarePatterns = @"
^king\.com\.
^Microsoft\.Skype
^Microsoft\.Xbox
^Microsoft\.Zune
^Spotify
"@ -split "`n"
ForEach($pattern in $bloatwarePatterns){
	ForEach($bloatware in ls "C:/Program Files/WindowsApps" | split-path -Leaf){
		if($bloatware -match $pattern){
			Remove-AppxPackage $bloatware
			Write-Host "removed bloatware: $bloatware"
		}
	}
}

#scoop
if(![bool](Get-Command -Name scoop -ErrorAction SilentlyContinue))
{
	Write-Host "installing scoop"
	#if we do this and scoop is already installed, we error out of the whole script. try/catch will not save you.
	#however, if we scoop install any scoop app, and it's already there, we get a warning and we keep going.
	iwr -useb get.scoop.sh | iex;
}
else
{
	Write-Host "already have scoop"
}

scoop install git;
scoop bucket add extras;
scoop install 7zip firefox sublime-text sublime-merge keepassxc kdiff3 openssh

#have sshd put you in powershell
Set-Content -Path ~/boilerplate_registry_sshd.reg -Value @"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\OpenSSH]
"DefaultShell"="$((get-command pwsh).Source)"
[HKEY_CURRENT_USER\SOFTWARE\OpenSSH]
"DefaultShell"="$((get-command pwsh).Source)"
"@
regedit /s $(resolve-path ~/boilerplate_registry_sshd.reg)
Write-Host "told SSHD to put you in powershell"


Write-Host "back in ye olden times, would have registered Sublime Text"
#configure sublime text
New-Item -ItemType Directory -Force -Path "~/scoop/persist/sublime-text/Data/Packages/User/"
Set-Content -Path "~/scoop/persist/sublime-text/Data/Packages/User/Preferences.sublime-settings" -Value @"
{
	"font_size": 12,
	"ignored_packages":
	[
		"Vintage"
	],
	"hot_exit": false
}
"@
Write-Host "Configured sublime text"

#start keepassxc on logon
$keepassAction = New-ScheduledTaskAction -Execute (Resolve-Path "~/scoop/apps/keepassxc/current/KeePassXC.exe")
$keepassTrigger = New-ScheduledTaskTrigger -AtLogOn -User $env:UserName
Register-ScheduledTask -TaskName "KeePass XC" -Action $keepassAction -Trigger $keepassTrigger
Write-Host "Set KeePass XC to start on logon"

#shortcuts:
$wshshell = new-Object -comobject wscript.shell
$volEnv = $wshShell.environment("volatile")
#sublime text
$shortcut = $wshShell.CreateShortcut("$(Resolve-Path ~/Desktop)/Sublime Text.lnk")
$shortcut.TargetPath = (Resolve-Path "~/scoop/apps/sublime-text/current/sublime_text.exe")
$shortcut.WorkingDirectory = (Resolve-Path ~/Desktop)
$shortcut.save();
#firefox
$shortcut = $wshShell.CreateShortcut("$(Resolve-Path ~/Desktop)/Firefox.lnk")
$shortcut.TargetPath = (Resolve-Path "~/scoop/apps/firefox/current/firefox.exe")
$shortcut.save();
#powershell
$shortcut = $wshShell.CreateShortcut("$(Resolve-Path ~/Desktop)/Powershell.lnk")
$shortcut.TargetPath = $((get-command pwsh).Source)
$shortcut.WorkingDirectory = (Resolve-Path ~/Desktop)
$shortcut.save();

#popup stuff the user has to do
#auto-logon
netplwiz.exe
#firefox extensions
firefox "https://addons.mozilla.org/en-US/firefox/addon/adblock-plus/" "https://addons.mozilla.org/en-US/firefox/addon/greasemonkey/" "https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/" "https://addons.mozilla.org/en-US/firefox/addon/awesome-rss/" "https://addons.mozilla.org/en-US/firefox/addon/cookie-remover/" "https://addons.mozilla.org/en-US/firefox/addon/dark-gold/"

#registry edit
regedit

set-content -Path ~/desktop/test.log -value "i am a test set me to open with sublime text"
Set-Content -Path ~/desktop/test.txt -value "I am a test set me to open with sublime text"

#pop some data up in a prettier form than the console window
Set-Content -Path ~/boilerplate_readme.txt -Value @"
things that you must do now:

FIRST: I popped up regedit. 
keys:
Computer\HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\0\Command
Computer\HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\open\Command
value: pwsh %1

* Set hostname. If you open powershell as admin, Rename-Computer
* I popped up netplwiz for you, set up auto-logon. Just uncheck, it'll ask for your password.
* customize start menu.
* customize task bar.
* tell 7zip to get on the context menu.
* set firefox to be the default web browser.
* I popped up firefox to some extensions, you'll have to actually do the installation.
* set sublime text to be the default for any file types.
* I put some shortcuts on the desktop, you'll have to drag them to the quick launch bar, then delete the ones on the desktop
* reboot, at some point

Other notes: 
this text file (should) delete itself on your next logon, along with some other junk that got dumped in your home dir.
I swear we enabled file type extensions. You may have to refresh your explorer windows to see it. The key exists for hkey current user, but we did also make one for local machine, hopefully if you make new accounts they'll get it too.
I think command line won't see pwsh until you reboot. Also when you reboot it'll refresh the desktop so recycle bin will hide.
"@
subl ~/boilerplate_readme.txt

#cleanup files we created
Set-Content -Path ~/boilerplate_cleanup.ps1 -Value @"
	`$logfile = "~/Desktop/debug.log"
	Add-Content -Path `$logfile -Value "cleaning up. "
	rm ~/boilerplate_registry.reg
	rm ~/boilerplate_readme.txt
	rm ~/boilerplate_registry_sshd.reg
	Add-Content -Path `$logfile -Value "Removed some junk. "
	Unregister-ScheduledTask -TaskName "Cleanup From Boilerplate" -Confirm:`$false
	Add-Content -Path `$logfile -Value "Removed task. "
	Add-Content -Path `$logfile -Value "self-destructing... "
	rm ~/boilerplate_cleanup.ps1;
	Add-Content -Path `$logfile -Value "destroyed self. Will I dream, dave?"
	pause;
"@
$cleanupAction = New-ScheduledTaskAction -Execute (Resolve-Path ~/boilerplate_cleanup.ps1)
$cleanupTrigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "Cleanup From Boilerplate" -Action $cleanupAction -Trigger $cleanupTrigger -RunLevel Highest
