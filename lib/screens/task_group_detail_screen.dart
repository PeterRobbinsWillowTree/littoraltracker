import 'package:flutter/material.dart';
import '../models/task_group.dart';
import '../models/unit.dart';

class TaskGroupDetailScreen extends StatelessWidget {
  final TaskGroup taskGroup;

  const TaskGroupDetailScreen({
    super.key,
    required this.taskGroup,
  });

  // Mock data for units
  List<Unit> get units => [
        Unit(
          id: '1',
          name: 'Marine Squad',
          type: UnitType.infantry,
          attack: 4,
          defense: 3,
          movement: 2,
          special: 'Amphibious',
        ),
        Unit(
          id: '2',
          name: 'Tank Platoon',
          type: UnitType.armor,
          attack: 6,
          defense: 5,
          movement: 3,
          special: 'Heavy Armor',
        ),
        Unit(
          id: '3',
          name: 'Artillery Battery',
          type: UnitType.artillery,
          attack: 5,
          defense: 2,
          movement: 1,
          special: 'Indirect Fire',
        ),
        Unit(
          id: '4',
          name: 'Attack Helicopter',
          type: UnitType.air,
          attack: 5,
          defense: 3,
          movement: 4,
          special: 'Air Mobility',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(taskGroup.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Unit 1'),
              Tab(text: 'Unit 2'),
              Tab(text: 'Unit 3'),
              Tab(text: 'Unit 4'),
            ],
          ),
        ),
        body: TabBarView(
          children: units.map((unit) => UnitCard(unit: unit)).toList(),
        ),
      ),
    );
  }
}

class UnitCard extends StatefulWidget {
  final Unit unit;

  const UnitCard({
    super.key,
    required this.unit,
  });

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard> {
  int currentHealth = 20;  // Start at full health

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.unit.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Health tracking row
            Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: List.generate(20, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentHealth = 20 - index;  // Convert index to health value
                      });
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 64) / 20,  // Responsive width
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey,
                            width: index < 19 ? 1 : 0,  // No border on last square
                          ),
                        ),
                        color: index >= (20 - currentHealth) 
                            ? Colors.transparent
                            : Colors.black,  // Black marker for current health
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text('Type: ${widget.unit.type.name}'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatBox(label: 'Attack', value: widget.unit.attack),
                _StatBox(label: 'Defense', value: widget.unit.defense),
                _StatBox(label: 'Movement', value: widget.unit.movement),
              ],
            ),
            const Divider(),
            Text(
              'Special: ${widget.unit.special}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;

  const _StatBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
} 