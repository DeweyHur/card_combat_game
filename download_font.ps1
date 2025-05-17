$fontUrl = "https://fonts.google.com/download?family=Press+Start+2P"
$outputPath = "assets/fonts/PressStart2P-Regular.ttf"

Invoke-WebRequest -Uri $fontUrl -OutFile $outputPath 