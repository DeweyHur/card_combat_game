#!/bin/bash

# Create sounds directory if it doesn't exist
mkdir -p assets/sounds

# Download card play sound (a soft whoosh sound)
curl -L "https://cdn.freesound.org/previews/131/131142_2337290-lq.mp3" -o assets/sounds/card_play.mp3

# Download damage sound (a hit sound)
curl -L "https://cdn.freesound.org/previews/131/131142_2337290-lq.mp3" -o assets/sounds/damage.mp3

echo "Sound files downloaded successfully!" 