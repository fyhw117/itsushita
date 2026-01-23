class ActionRecord {
  final String id;
  final String actionId;
  final DateTime timestamp;

  ActionRecord({
    required this.id,
    required this.actionId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionId': actionId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActionRecord.fromMap(Map<String, dynamic> map) {
    return ActionRecord(
      id: map['id'],
      actionId: map['actionId'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
