param(
	[int]
	$count = 5, 
	$file
	)

for (($i = 1); $i -lt $count; $i++)
{
	magick convert $file -gravity NorthWest -pointsize 96 -pointsize 96 -fill white -stroke black -strokewidth 3 -pointsize 96 -draw "text 20,20 '$i'" $file_$i.png
}
magick convert $file -gravity NorthWest -pointsize 96 -pointsize 96 -fill white -stroke black -strokewidth 3 -pointsize 96 -draw "text 20,20 '$count (final)'" $file_$count.png