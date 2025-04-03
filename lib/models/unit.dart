enum UnitType { infantry, armor, artillery, air, naval, logistics }

class Unit {
  final String id;
  final String taskGroupId;
  final String name;
  final UnitType type;
  final int attack;
  final int defense;
  final int movement;
  final String special;

  Unit({
    required this.id,
    required this.taskGroupId,
    required this.name,
    required this.type,
    required this.attack,
    required this.defense,
    required this.movement,
    required this.special,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_group_id': taskGroupId,
      'name': name,
      'type': type.toString(),
      'attack': attack,
      'defense': defense,
      'movement': movement,
      'special': special,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'],
      taskGroupId: map['task_group_id'],
      name: map['name'],
      type: UnitType.values.firstWhere((e) => e.toString() == map['type']),
      attack: map['attack'],
      defense: map['defense'],
      movement: map['movement'],
      special: map['special'],
    );
  }
} 