param(
	[int]
	$length = 16
	)

if($length -lt 1){
	Write-Warning "I call 1..length, so 1..0 counts backwards, giving 2 characters, -1 gives 3, etc."
}

$str = 1..$length | ForEach-Object{
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "K", "J", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" | Get-Random
} 
return $str -join ""