import 'package:flutter/services.dart';

class DialogueEntry {
  final String id;
  final String character;
  final String message;
  final String nextId;

  DialogueEntry({
    required this.id,
    required this.character,
    required this.message,
    required this.nextId,
  });
}

class DialogueManager {
  static final DialogueManager _instance = DialogueManager._internal();
  factory DialogueManager() => _instance;
  DialogueManager._internal();

  final Map<String, List<DialogueEntry>> _dialogues = {};
  String? _currentDialogueId;
  int _currentIndex = 0;

  Future<void> loadDialogue(String dialogueId) async {
    if (_dialogues.containsKey(dialogueId)) return;

    try {
      final String data =
          await rootBundle.loadString('assets/dialogues/$dialogueId.csv');
      final List<String> lines = data.split('\n');

      // Skip header
      final List<DialogueEntry> entries = [];
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        final List<String> values = lines[i].split(',');
        if (values.length >= 4) {
          entries.add(DialogueEntry(
            id: values[0],
            character: values[1],
            message: values[2],
            nextId: values[3],
          ));
        }
      }

      _dialogues[dialogueId] = entries;
    } catch (e) {
      // Optionally handle error
    }
  }

  void startDialogue(String dialogueId) {
    _currentDialogueId = dialogueId;
    _currentIndex = 0;
  }

  DialogueEntry? getCurrentEntry() {
    if (_currentDialogueId == null ||
        !_dialogues.containsKey(_currentDialogueId)) {
      return null;
    }

    final entries = _dialogues[_currentDialogueId]!;
    if (_currentIndex >= entries.length) {
      return null;
    }

    return entries[_currentIndex];
  }

  bool advanceDialogue() {
    if (_currentDialogueId == null ||
        !_dialogues.containsKey(_currentDialogueId)) {
      return false;
    }

    final entries = _dialogues[_currentDialogueId]!;
    _currentIndex++;

    if (_currentIndex >= entries.length) {
      return false;
    }

    return true;
  }

  bool isDialogueComplete() {
    if (_currentDialogueId == null ||
        !_dialogues.containsKey(_currentDialogueId)) {
      return true;
    }

    final entries = _dialogues[_currentDialogueId]!;
    return _currentIndex >= entries.length;
  }
}
