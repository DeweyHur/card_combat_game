#!/bin/bash

# Create sounds directory if it doesn't exist
mkdir -p assets/sounds

# Generate card play sound (a soft whoosh)
ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.2" -af "volume=0.3" assets/sounds/card_play.mp3

# Generate damage sound (a hit sound)
ffmpeg -f lavfi -i "sine=frequency=200:duration=0.1" -af "volume=0.5" assets/sounds/damage.mp3

echo "Sound files generated successfully!" 