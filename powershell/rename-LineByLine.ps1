#make a source, make a dest, get to the target location and go nuts
param($srcNamesFile, $destNamesFile)

if($srcNamesFile -and $destNamesFile){

	$srcLines = (Get-Content -Path $srcNamesFile)
	$destLines = (Get-Content -Path $destNamesFile)
	if($srcLines.length -ne $destLines.length){
		Write-Host "different lengths"
	} else{
		0..($srcLines.length) | ForEach-Object {
			$src = $srcLines[$_]
			$dest = $destLines[$_]
			if($src -and $dest){
				Rename-Item $src $dest
			}
		}
	}
} else{
	$files = (Get-ChildItem -Name)
	$files > _src.txt
	$files > _dest.txt
	Write-Host "edit dest.txt in your favorite text editor, then call me again like:"
	$me = $myInvocation.MyCommand.Name
	Write-Host "$me -srcNamesFile src.txt -destNamesFile dest.txt"
	Write-Host "note we don't recurse."
	Write-Host "hint: to replace a dot that is not the last dot on the line, use this regex: \.(?=.*\..*)"
}
