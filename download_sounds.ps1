$textSoundUrl = "https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3"
$outputPath = "assets/sounds/text_sound.mp3"

# Create the sounds directory if it doesn't exist
New-Item -ItemType Directory -Force -Path "assets/sounds"

# Download the sound file
Invoke-WebRequest -Uri $textSoundUrl -OutFile $outputPath 