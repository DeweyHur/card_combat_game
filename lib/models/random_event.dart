import 'package:card_combat_app/models/player.dart';

class RandomEvent {
  final String title;
  final String description;
  final List<EventChoice> choices;

  RandomEvent({
    required this.title,
    required this.description,
    required this.choices,
  });
}

class EventChoice {
  final String text;
  final EventOutcome outcome;

  EventChoice({
    required this.text,
    required this.outcome,
  });
}

class EventOutcome {
  final double successChance;
  final String Function(PlayerRun) successReward;
  final String Function(PlayerRun) failurePenalty;

  EventOutcome({
    required this.successChance,
    required this.successReward,
    required this.failurePenalty,
  });
}
