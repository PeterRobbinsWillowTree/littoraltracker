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

enum MarkerColor {
  black,
  red,
  purple,
  green,
  blue,
  none
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
  Map<int, MarkerColor> markers = {};
  MarkerColor selectedColor = MarkerColor.black;

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black12,
      child: Row(
        children: [
          // Unit icon with background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              _getUnitTypeIcon(widget.unit.type),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          // Unit value indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '2',  // Unit value - you might want to add this to your Unit model
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.unit.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.unit.special,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMarkerColor(MarkerColor color) {
    switch (color) {
      case MarkerColor.black: return Colors.black;
      case MarkerColor.red: return Colors.red;
      case MarkerColor.purple: return Colors.purple;
      case MarkerColor.green: return Colors.green;
      case MarkerColor.blue: return Colors.blue;
      case MarkerColor.none: return Colors.transparent;
    }
  }

  Widget _buildColorSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MarkerColor.values.where((c) => c != MarkerColor.none).map((color) {
        return GestureDetector(
          onTap: () => setState(() => selectedColor = color),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getMarkerColor(color),
              border: Border.all(
                color: selectedColor == color ? Colors.yellow : Colors.grey,
                width: selectedColor == color ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTracker() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: List.generate(4, (row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (col) {
                final number = row * 5 + col + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (markers[number] == selectedColor) {
                        markers.remove(number);
                      } else {
                        markers[number] = selectedColor;
                      }
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            number.toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (markers[number] != null)
                          Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _getMarkerColor(markers[number]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTracker(),
                const SizedBox(height: 16),
                _buildColorSelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _getUnitTypeIcon(UnitType type) {
  switch (type) {
    case UnitType.infantry:
      return Icons.directions_walk; // Person walking for infantry
    case UnitType.armor:
      return Icons.directions_car; // Vehicle for armor
    case UnitType.artillery:
      return Icons.flash_on; // Lightning bolt for artillery
    case UnitType.air:
      return Icons.flight; // Air unit
    case UnitType.naval:
      return Icons.directions_boat; // Boat for naval units
    case UnitType.logistics:
      return Icons.local_shipping; // Truck for logistics
  }
} 