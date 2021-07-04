Add-Type -AssemblyName System.Windows.Forms

write-host "hi I'mma save"
while($true){
	start-sleep 300;
	[System.Windows.Forms.SendKeys]::SendWait("^s")
	git add .
	git commit -m "auto"
	write-host "save keys sent, $(get-date)"
}