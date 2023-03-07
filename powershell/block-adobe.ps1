cd "C:\Program Files\Adobe\Adobe Premiere Pro CC 2019";

Get-ChildItem -Recurse -Filter *.exe | ForEach-Object { New-NetFirewallRule -DisplayName "adobe" -Direction Outbound -Program $_.FullName -Action Block}