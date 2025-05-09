# Card Combat Game

A turn-based card combat game built with Flutter and Flame game engine. Players can battle against a goblin enemy using various cards with different effects.

## Features

- Turn-based combat system
- Different card types (Attack, Heal, Status Effect, Cure)
- Visual effects for card actions
- Enemy AI with different attack patterns
- Health tracking for both player and enemy
- Sound effects for actions

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/card_combat_app.git
```

2. Navigate to the project directory:
```bash
cd card_combat_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Create the assets/sounds directory and add required sound files:
- card_play.mp3
- damage.mp3

5. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── components/         # UI components
│   ├── card_visual_component.dart
│   └── game_effects.dart
├── game/              # Game logic
│   └── card_combat_game.dart
├── models/            # Data models
│   ├── card.dart
│   └── cards_data.dart
└── utils/            # Utility functions
```

## Game Controls

- Tap on cards to play them during your turn
- Enemy automatically takes their turn after you play a card

## License

This project is licensed under the MIT License - see the LICENSE file for details.
