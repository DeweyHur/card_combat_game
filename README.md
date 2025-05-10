# Card Combat Game

A turn-based card combat game built with Flutter and Flame engine.

## Features

- Four unique character classes with different playstyles:
  - **Fighter**: High HP, +1 energy per turn, Attack cards deal +1 damage
  - **Paladin**: Highest HP, heals 2 HP per turn, Healing cards heal +2 HP
  - **Sorcerer**: Low HP, draws extra card, Status effects last longer
  - **Warlock**: Medium HP, more energy, Powerful attacks with drawbacks

- Card System:
  - Attack cards for dealing damage
  - Healing cards for restoring HP
  - Status effect cards (Poison, Burn, Freeze)
  - Utility cards (Cure, Cleanse)

- Combat Mechanics:
  - Turn-based gameplay
  - Card drawing and hand management
  - Status effects system
  - Enemy AI with predictable actions

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/card_combat_app.git
cd card_combat_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the game:
```bash
flutter run
```

## Game Structure

### Core Components

- `CardCombatGame`: Main game class handling game state and initialization
- `BaseScene`: Base class for all game scenes
- `CombatScene`: Handles combat mechanics and UI
- `PlayerSelectionScene`: Character selection screen

### Character Classes

- `PlayerBase`: Base class for all player characters
- `Fighter`: Melee-focused character
- `Paladin`: Defensive character with healing abilities
- `Sorcerer`: Status effect specialist
- `Warlock`: High-risk, high-reward character

### Card System

- `GameCard`: Base class for all cards
- Card Types:
  - Attack
  - Heal
  - Status Effect
  - Cure

## Development

### Project Structure

```
lib/
├── components/         # Game components (cards, effects)
├── game/              # Core game logic
├── models/            # Game models (cards, characters)
├── scenes/            # Game scenes
└── utils/             # Utility functions and logging
```

### Adding New Features

1. Cards:
   - Add new card definitions in `game_cards_data.dart`
   - Implement card effects in `GameCard` class

2. Characters:
   - Create new character class extending `PlayerBase`
   - Add character to selection screen in `PlayerSelectionScene`

3. Scenes:
   - Create new scene extending `BaseScene`
   - Register scene in `SceneController`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Game engine powered by [Flame](https://flame-engine.org/)
- Inspired by popular card games and roguelikes
