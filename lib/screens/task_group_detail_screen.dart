import 'package:flutter/material.dart';
import '../models/task_group.dart';
import '../models/unit.dart';
import '../database/database_helper.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/marker_color.dart';

class TaskGroupDetailScreen extends StatefulWidget {
  final TaskGroup taskGroup;

  const TaskGroupDetailScreen({
    super.key,
    required this.taskGroup,
  });

  @override
  State<TaskGroupDetailScreen> createState() => _TaskGroupDetailScreenState();
}

class _TaskGroupDetailScreenState extends State<TaskGroupDetailScreen> {
  List<Unit> _units = [];
  bool _isLoading = true;
  String? _errorMessage;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final unitMaps = await _dbHelper.getUnitsForTaskGroup(widget.taskGroup.id);
      setState(() {
        _units = unitMaps.map((map) => Unit.fromMap(map)).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load units: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _units.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.taskGroup.name),
          bottom: TabBar(
            tabs: _units.map((unit) => Tab(text: unit.name)).toList(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : TabBarView(
                    children: _units.map((unit) => UnitCard(unit: unit)).toList(),
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
  Map<int, List<MarkerColor>> markers = {};
  MarkerColor selectedColor = MarkerColor.black;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loadedMarkers = await _dbHelper.getMarkersForUnit(widget.unit.id);
      setState(() {
        markers = loadedMarkers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load markers: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMarkers() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      await _dbHelper.saveMarkers(widget.unit.id, markers);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save markers: ${e.toString()}';
      });
    }
  }

  Future<void> _resetMarkers() async {
    setState(() {
      markers = {};
      _errorMessage = null;
    });
    await _saveMarkers();
  }

  Future<void> _backupMarkers() async {
    try {
      final markersJson = jsonEncode(markers);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/markers_backup_${widget.unit.id}.json');
      await file.writeAsString(markersJson);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Markers backed up successfully')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to backup markers: ${e.toString()}';
      });
    }
  }

  Future<void> _restoreMarkers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/markers_backup_${widget.unit.id}.json');
      if (await file.exists()) {
        final markersJson = await file.readAsString();
        final restoredMarkers = Map<int, List<MarkerColor>>.from(
          jsonDecode(markersJson),
        );
        setState(() {
          markers = restoredMarkers;
        });
        await _saveMarkers();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Markers restored successfully')),
        );
      } else {
        setState(() {
          _errorMessage = 'No backup found for this unit';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to restore markers: ${e.toString()}';
      });
    }
  }

  void _handleMarkerTap(int number) {
    setState(() {
      // Find and collect positions with the selected color
      final positionsToRemove = <int>[];
      markers.forEach((key, value) {
        if (value.contains(selectedColor)) {
          positionsToRemove.add(key);
        }
      });

      // Remove the color from collected positions
      for (final position in positionsToRemove) {
        markers[position]!.remove(selectedColor);
        if (markers[position]!.isEmpty) {
          markers.remove(position);
        }
      }

      // Add the new marker
      if (!markers.containsKey(number)) {
        markers[number] = [];
      }
      markers[number]!.add(selectedColor);
    });
    _saveMarkers();
  }

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
                  onTap: () => _handleMarkerTap(number),
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
                          ...markers[number]!.asMap().entries.map((entry) {
                            final index = entry.key;
                            final color = entry.value;
                            return Positioned(
                              left: 4 + (index * 8),
                              top: 4,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getMarkerColor(color),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTracker(),
                const SizedBox(height: 16),
                _buildColorSelector(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _resetMarkers,
                      child: const Text('Reset Markers'),
                    ),
                    ElevatedButton(
                      onPressed: _backupMarkers,
                      child: const Text('Backup'),
                    ),
                    ElevatedButton(
                      onPressed: _restoreMarkers,
                      child: const Text('Restore'),
                    ),
                  ],
                ),
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