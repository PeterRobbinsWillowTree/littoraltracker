class Scenario {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String faction;

  Scenario({
    required this.id,
    required this.name,
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
      'faction': faction,
    };
  }

  factory Scenario.fromMap(Map<String, dynamic> map) {
    return Scenario(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      faction: map['faction'],
    );
  }
} 