import 'package:card_combat_app/models/game_character.dart';
import 'package:card_combat_app/components/panel/base_panel.dart';
import 'package:card_combat_app/components/layout/name_emoji_component.dart';
import 'package:card_combat_app/components/panel/stats_row.dart';

abstract class BasePlayerPanel extends BasePanel {
  late GameCharacter player;
  late NameEmojiComponent nameEmojiComponent;
  late StatsRow statsRow;

  BasePlayerPanel({required this.player});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    nameEmojiComponent = NameEmojiComponent(character: player);
    resetVerticalStack();
    registerVerticalStackComponent('nameEmoji', nameEmojiComponent, 60);
    statsRow = StatsRow(character: player);
    registerVerticalStackComponent('statsRow', statsRow, 20);
  }

  void updatePlayer(GameCharacter newPlayer) {
    player = newPlayer;
    nameEmojiComponent.updateCharacter(newPlayer);
    statsRow.setCharacter(player);
    updateUI();
  }

  @override
  void updateUI() {
    statsRow.updateUI();
  }
}
