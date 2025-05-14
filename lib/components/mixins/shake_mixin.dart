import 'package:flame/components.dart';
import 'package:card_combat_app/models/game_card.dart';

mixin ShakeMixin on PositionComponent {
  Future<void> shake({bool horizontal = true, double intensity = 12, int times = 8, Duration duration = const Duration(milliseconds: 16)}) async {
    final originalPosition = position.clone();
    for (int i = 0; i < times; i++) {
      position.add(horizontal
          ? Vector2((i % 2 == 0 ? intensity : -intensity), 0)
          : Vector2(0, (i % 2 == 0 ? intensity : -intensity)));
      await Future.delayed(duration);
      position.setFrom(originalPosition);
      await Future.delayed(duration);
    }
    position.setFrom(originalPosition);
  }

  Future<void> shakeForType(CardType type) async {
    switch (type) {
      case CardType.attack:
        await shake(horizontal: true, intensity: 12, times: 8);
        break;
      case CardType.heal:
        await shake(horizontal: false, intensity: 6, times: 4);
        break;
      case CardType.statusEffect:
        await shake(horizontal: true, intensity: 1, times: 4);
        break;
      case CardType.cure:
        await shake(horizontal: false, intensity: 2, times: 2);
        break;
    }
  }
} 