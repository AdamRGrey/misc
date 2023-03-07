param(
	$webp = 16
	)

$target = [System.IO.Path]::GetDirectoryName($webp) + "/" + [System.IO.Path]::GetFileNameWithoutExtension($webp) + ".png"
dwebp $webp -o $target
remove-item $webp
