class TaskGroup {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String scenarioId;
  final String faction;

  TaskGroup({
    required this.id,
    required this.name,
    required this.scenarioId,
    required this.faction,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'scenario_id': scenarioId,
      'faction': faction,
    };
  }

  factory TaskGroup.fromMap(Map<String, dynamic> map) {
    return TaskGroup(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      scenarioId: map['scenario_id'],
      faction: map['faction'],
    );
  }
} 