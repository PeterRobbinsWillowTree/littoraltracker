import 'package:flutter/material.dart';
import '../models/task_group.dart';
import '../models/unit.dart';
import '../database/database_helper.dart';
import '../models/marker_color.dart';
// ignore: unused_import
import 'package:path_provider/path_provider.dart';
// ignore: unused_import
import 'dart:io';
// ignore: unused_import
import 'package:share_plus/share_plus.dart';
// ignore: unused_import
import 'package:intl/intl.dart';

class TaskGroupDetailScreen extends StatefulWidget {
  final TaskGroup taskGroup;

  const TaskGroupDetailScreen({
    super.key,
    required this.taskGroup,
  });

  @override
  State<TaskGroupDetailScreen> createState() => _TaskGroupDetailScreenState();
}

class _TaskGroupDetailScreenState extends State<TaskGroupDetailScreen> with SingleTickerProviderStateMixin {
  List<Unit> _units = [];
  bool _isLoading = true;
  String? _errorMessage;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late TabController _tabController;

  Color _getMarkerColor(MarkerColor color) {
    switch (color) {
      case MarkerColor.black: return Colors.black;
      case MarkerColor.red: return Colors.red;
      case MarkerColor.purple: return Colors.purple;
      case MarkerColor.green: return Colors.green;
      case MarkerColor.blue: return Colors.blue;
      case MarkerColor.orange: return Colors.orange;
      case MarkerColor.none: return Colors.transparent;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUnits().then((_) {
      _tabController = TabController(length: _units.length, vsync: this);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _addUnit() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const UnitEditDialog(),
    );

    if (result != null) {
      try {
        await _dbHelper.createUnit(
          taskGroupId: widget.taskGroup.id,
          name: result['name']!,
          type: result['type']!,
          special: result['special'],
          description: result['description'],
        );
        await _loadUnits();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to add unit: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _editUnit(Unit unit) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UnitEditDialog(unit: unit),
    );

    if (result != null) {
      try {
        await _dbHelper.updateUnit(
          id: unit.id,
          name: result['name']!,
          type: result['type']!,
          special: result['special'],
          description: result['description'],
        );
        await _loadUnits();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update unit: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _deleteUnit(Unit unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text('Are you sure you want to delete "${unit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteUnit(unit.id);
        await _loadUnits();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to delete unit: ${e.toString()}';
        });
      }
    }
  }

  void _showAllUnitsTable() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Scaffold(
        appBar: AppBar(
          title: Text('${widget.taskGroup.name} - All Units'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth / 12;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  dataRowHeight: cellSize * 1.2,
                  headingRowHeight: cellSize * 1.4,
                  columns: const [
                    DataColumn(
                      label: Text('Unit Name'),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text('Description'),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text('Attached JCC Cards'),
                      numeric: false,
                    ),
                    DataColumn(
                      label: Text('Black'),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Red'),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Purple'),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Green'),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Blue'),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Orange'),
                      numeric: true,
                    ),
                  ],
                  rows: _units.asMap().entries.map((entry) {
                    final index = entry.key;
                    final unit = entry.value;
                    return DataRow(
                      onSelectChanged: (_) {
                        Navigator.pop(dialogContext);
                        _tabController.animateTo(index);
                      },
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: cellSize * 2),
                            child: Text(
                              unit.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: cellSize * 3),
                            child: Text(
                              unit.description ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: cellSize * 2),
                            child: Text(
                              unit.special ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(_buildMarkerCellWithNumber(unit.id, MarkerColor.black, cellSize)),
                        DataCell(_buildMarkerCellWithNumber(unit.id, MarkerColor.red, cellSize)),
                        DataCell(_buildMarkerCellWithNumber(unit.id, MarkerColor.purple, cellSize)),
                        DataCell(_buildMarkerCellWithNumber(unit.id, MarkerColor.green, cellSize)),
                        DataCell(_buildMarkerCellWithNumber(unit.id, MarkerColor.blue, cellSize)),
                        DataCell(_buildMarkerCellWithNumber(unit.id, MarkerColor.orange, cellSize)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarkerCellWithNumber(String unitId, MarkerColor color, double size) {
    return FutureBuilder<Map<int, List<MarkerColor>>>(
      future: _dbHelper.getMarkersForUnit(unitId),
      builder: (context, snapshot) {
        int position = 0;
        if (snapshot.hasData) {
          snapshot.data!.forEach((pos, colors) {
            if (colors.contains(color)) {
              position = pos;
            }
          });
        }
        
        return Container(
          width: size * 0.8,
          height: size * 0.8,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: position > 0 ? _getMarkerColor(color) : Colors.transparent,
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          child: Text(
            position.toString(),
            style: TextStyle(
              color: position > 0 ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.4,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_units.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No units found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addUnit,
              child: const Text('Add Unit'),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: _units.length,
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: _showAllUnitsTable,
            child: Row(
              children: [
                Text(widget.taskGroup.name),
                const SizedBox(width: 8),
                const Icon(Icons.table_chart, size: 20),
              ],
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: _units.map((unit) => Tab(text: unit.name)).toList(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addUnit,
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: _units.map((unit) => UnitCard(
            unit: unit,
            onEdit: () => _editUnit(unit),
            onDelete: () => _deleteUnit(unit),
          )).toList(),
        ),
      ),
    );
  }
}

class UnitCard extends StatefulWidget {
  final Unit unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UnitCard({
    super.key,
    required this.unit,
    required this.onEdit,
    required this.onDelete,
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

  Color _getMarkerColor(MarkerColor color) {
    switch (color) {
      case MarkerColor.black: return Colors.black;
      case MarkerColor.red: return Colors.red;
      case MarkerColor.purple: return Colors.purple;
      case MarkerColor.green: return Colors.green;
      case MarkerColor.blue: return Colors.blue;
      case MarkerColor.orange: return Colors.orange;
      case MarkerColor.none: return Colors.transparent;
    }
  }

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

  void _handleMarkerTap(int number) {
    setState(() {
      // First, check if the selected color exists anywhere on the card
      int? existingPosition;
      markers.forEach((pos, colors) {
        if (colors.contains(selectedColor)) {
          existingPosition = pos;
        }
      });

      if (existingPosition != null) {
        // If clicking the same position, remove the color
        if (existingPosition == number) {
          markers[number]!.remove(selectedColor);
          if (markers[number]!.isEmpty) {
            markers.remove(number);
          }
        } else {
          // If clicking a different position, move the color
          markers[existingPosition]!.remove(selectedColor);
          if (markers[existingPosition]!.isEmpty) {
            markers.remove(existingPosition);
          }
          
          if (!markers.containsKey(number)) {
            markers[number] = [];
          }
          markers[number]!.add(selectedColor);
        }
      } else {
        // If the color doesn't exist anywhere, add it to the clicked position
        if (!markers.containsKey(number)) {
          markers[number] = [];
        }
        markers[number]!.add(selectedColor);
      }
    });
    _saveMarkers();
  }

  Widget _buildHeader() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Container(
      padding: EdgeInsets.all(isLandscape ? 4 : 8),
      color: Colors.black12,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isLandscape ? 4 : 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              _getUnitTypeIcon(widget.unit.type),
              color: Colors.white,
              size: isLandscape ? 20 : 24,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 4 : 8,
              vertical: isLandscape ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '2',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isLandscape ? 12 : 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(widget.unit.name),
                        content: SingleChildScrollView(
                          child: Text(
                            widget.unit.description ?? 'No description available',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    widget.unit.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isLandscape ? 14 : 16,
                    ),
                  ),
                ),
                Text(
                  widget.unit.special ?? '',
                  style: TextStyle(
                    fontSize: isLandscape ? 10 : 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: widget.onEdit,
            tooltip: 'Edit Unit',
            iconSize: isLandscape ? 20 : 24,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: widget.onDelete,
            tooltip: 'Delete Unit',
            iconSize: isLandscape ? 20 : 24,
          ),
        ],
      ),
    );
  }

  void _showSummaryTable() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unit Summary'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Unit Name')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('JCC Cards')),
                DataColumn(label: Text('Black')),
                DataColumn(label: Text('Red')),
                DataColumn(label: Text('Purple')),
                DataColumn(label: Text('Green')),
                DataColumn(label: Text('Blue')),
                DataColumn(label: Text('Orange')),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text(widget.unit.name)),
                    DataCell(Text(widget.unit.description ?? '')),
                    DataCell(Text(widget.unit.special ?? '')),
                    DataCell(_buildMarkerCell(MarkerColor.black)),
                    DataCell(_buildMarkerCell(MarkerColor.red)),
                    DataCell(_buildMarkerCell(MarkerColor.purple)),
                    DataCell(_buildMarkerCell(MarkerColor.green)),
                    DataCell(_buildMarkerCell(MarkerColor.blue)),
                    DataCell(_buildMarkerCell(MarkerColor.orange)),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerCell(MarkerColor color) {
    bool hasMarker = false;
    markers.forEach((position, colors) {
      if (colors.contains(color)) {
        hasMarker = true;
      }
    });
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: hasMarker ? _getMarkerColor(color) : Colors.transparent,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildTracker() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the size of each cube based on the available space and orientation
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        final availableWidth = constraints.maxWidth - 20; // Account for padding
        final availableHeight = constraints.maxHeight - 20;
        
        // In landscape, use height as the limiting factor
        final cubeSize = isLandscape 
          ? (availableHeight / 4).clamp(30.0, 50.0) // 4 rows
          : (availableWidth / 5).clamp(30.0, 50.0); // 5 columns
        
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey),
          ),
          child: Column(
            children: List.generate(4, (row) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (col) {
                      final number = row * 5 + col + 1;
                      return SizedBox(
                        width: cubeSize,
                        height: cubeSize,
                        child: GestureDetector(
                          onTap: () => _handleMarkerTap(number),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
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
                                      fontSize: cubeSize * 0.3,
                                    ),
                                  ),
                                ),
                                if (markers[number] != null)
                                  ...markers[number]!.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final color = entry.value;
                                    return Positioned(
                                      left: cubeSize * 0.2 + (index * cubeSize * 0.3),
                                      top: cubeSize * 0.2,
                                      child: Container(
                                        width: cubeSize * 0.3,
                                        height: cubeSize * 0.3,
                                        decoration: BoxDecoration(
                                          color: _getMarkerColor(color),
                                          borderRadius: BorderRadius.circular(cubeSize * 0.1),
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildColorSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        final selectorSize = isLandscape ? 30.0 : 40.0;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: MarkerColor.values.where((c) => c != MarkerColor.none).map((color) {
            return GestureDetector(
              onTap: () => setState(() => selectedColor = color),
              child: Container(
                width: selectorSize,
                height: selectorSize,
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
      },
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: _buildTracker(),
                  ),
                  const SizedBox(height: 16),
                  _buildColorSelector(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UnitEditDialog extends StatefulWidget {
  final Unit? unit;

  const UnitEditDialog({super.key, this.unit});

  @override
  State<UnitEditDialog> createState() => _UnitEditDialogState();
}

class _UnitEditDialogState extends State<UnitEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _specialController;
  late final TextEditingController _descriptionController;
  late UnitType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit?.name ?? '');
    _specialController = TextEditingController(text: widget.unit?.special ?? '');
    _descriptionController = TextEditingController(text: widget.unit?.description ?? '');
    _selectedType = widget.unit?.type ?? UnitType.infantry;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.unit == null ? 'Add Unit' : 'Edit Unit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UnitType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: UnitType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialController,
                decoration: const InputDecoration(labelText: 'Attached JCC Cards'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'type': _selectedType,
                'special': _specialController.text,
                'description': _descriptionController.text,
              });
            }
          },
          child: Text(widget.unit == null ? 'Add' : 'Save'),
        ),
      ],
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