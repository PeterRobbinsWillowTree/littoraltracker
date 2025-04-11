enum UnitType { infantry, armor, artillery, air, naval, logistics }

class Unit {
  final String id;
  final String taskGroupId;
  final String name;
  final UnitType type;
  final String? special;
  final String? description;

  Unit({
    required this.id,
    required this.taskGroupId,
    required this.name,
    required this.type,
    this.special,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_group_id': taskGroupId,
      'name': name,
      'type': type.toString().split('.').last,
      'special': special,
      'description': description,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'],
      taskGroupId: map['task_group_id'],
      name: map['name'],
      type: UnitType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      special: map['special'],
      description: map['description'],
    );
  }
} 