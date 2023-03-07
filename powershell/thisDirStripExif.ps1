Get-ChildItem *.jpg | foreach-object 
{
	magick convert $_.Name -auto-orient -strip $_.Name
}