enum ActionType {
  shouldDo, // Positive: Muscle training, etc.
  shouldNotDo, // Negative: Eating snacks, etc.
}

class ActionItem {
  final String id;
  final String name;
  final ActionType type;
  final int colorValue; // Store color as int
  final String frequency; // Description of frequency
  final bool showConsecutiveDays;

  ActionItem({
    required this.id,
    required this.name,
    required this.type,
    required this.colorValue,
    required this.frequency,
    this.showConsecutiveDays = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'colorValue': colorValue,
      'frequency': frequency,
      'showConsecutiveDays': showConsecutiveDays ? 1 : 0,
    };
  }

  factory ActionItem.fromMap(Map<String, dynamic> map) {
    return ActionItem(
      id: map['id'],
      name: map['name'],
      type: ActionType.values[map['type']],
      colorValue: map['colorValue'],
      frequency: map['frequency'] ?? '',
      showConsecutiveDays: (map['showConsecutiveDays'] ?? 1) == 1,
    );
  }
}
