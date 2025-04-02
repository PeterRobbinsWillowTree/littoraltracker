enum UnitType { infantry, armor, artillery, air }

class Unit {
  final String id;
  final String name;
  final UnitType type;
  final int attack;
  final int defense;
  final int movement;
  final String special;

  Unit({
    required this.id,
    required this.name,
    required this.type,
    required this.attack,
    required this.defense,
    required this.movement,
    required this.special,
  });
} 