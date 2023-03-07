vboxland
./VBoxManage list vms | 
	Select-String -Pattern "\{[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\}" |
		Foreach-Object {
			$vmName = """$($_.Matches[0])"""
			./VBoxManage.exe snapshot $vmName take "$(Get-Date -Format "yyyy-MM-ddThh-mm-ss.ffff")"
		}