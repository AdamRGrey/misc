Add-Type -AssemblyName System.Windows.Forms

while ($true){
	$Pos = [System.Windows.Forms.Cursor]::Position
	$x = (get-random -minimum 0 -maximum 3840)
	$y = (get-random -minimum 0 -maximum 2160)
	[System.WIndows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
	Write-Host "$x, $y"
	get-date -DisplayHint time
	start-sleep -Seconds 90
}