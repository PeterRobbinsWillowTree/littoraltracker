import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../database/database_helper.dart';
import 'task_group_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ScenarioListScreen extends StatefulWidget {
  const ScenarioListScreen({super.key});

  @override
  State<ScenarioListScreen> createState() => _ScenarioListScreenState();
}

class _ScenarioListScreenState extends State<ScenarioListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Scenario> _scenarios = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final scenarioMaps = await _dbHelper.getAllScenarios();
      setState(() {
        _scenarios = scenarioMaps.map((map) => Scenario.fromMap(map)).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load scenarios: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createScenario() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const CreateScenarioDialog(),
    );

    if (result != null) {
      try {
        await _dbHelper.createScenario(
          name: result['name']!,
          faction: result['faction']!,
          description: result['description'],
        );
        await _loadScenarios();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to create scenario: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _deleteScenario(Scenario scenario) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scenario'),
        content: Text('Are you sure you want to delete "${scenario.name}"?'),
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
        await _dbHelper.deleteScenario(scenario.id);
        await _loadScenarios();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to delete scenario: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _editScenario(Scenario scenario) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => EditScenarioDialog(scenario: scenario),
    );

    if (result != null) {
      try {
        await _dbHelper.updateScenario(
          id: scenario.id,
          name: result['name']!,
          faction: result['faction']!,
          description: result['description'],
        );
        await _loadScenarios();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update scenario: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _duplicateScenario(String scenarioId) async {
    try {
      final newScenarioId = await DatabaseHelper.instance.duplicateScenario(scenarioId);
      setState(() {
        _scenarios = _scenarios.map((s) {
          if (s.id == scenarioId) {
            return Scenario(
              id: newScenarioId,
              name: '${s.name} (Copy)',
              description: s.description,
              createdAt: DateTime.now(),
              faction: s.faction,
            );
          }
          return s;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to duplicate scenario: $e')),
      );
    }
  }

  Future<void> _exportScenario(String scenarioId) async {
    try {
      final jsonData = await DatabaseHelper.instance.exportScenario(scenarioId);
      final scenario = _scenarios.firstWhere((s) => s.id == scenarioId);
      final fileName = '${scenario.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';
      
      // Create a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonData);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Exporting scenario: ${scenario.name}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export scenario: $e')),
      );
    }
  }

  Future<void> _importScenario() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final path = file.path;
        
        if (path == null) {
          throw Exception('Failed to get file path');
        }

        final fileContent = await File(path).readAsString();
        await DatabaseHelper.instance.importScenario(fileContent);
        await _loadScenarios();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scenario imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import scenario: $e')),
      );
    }
  }

  Future<void> _showScenarioStats(String scenarioId) async {
    try {
      final stats = await DatabaseHelper.instance.getScenarioStats(scenarioId);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Scenario Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Task Groups: ${stats['taskGroupCount']}'),
              Text('Units: ${stats['unitCount']}'),
              Text('Markers: ${stats['markerCount']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load statistics: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scenarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createScenario,
          ),
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: _importScenario,
            tooltip: 'Import Scenario',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Database'),
                  content: const Text('This will delete all scenarios and their data. Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await DatabaseHelper.instance.deleteDatabase();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database reset successfully')),
                  );
                  setState(() {});
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _scenarios.isEmpty
                  ? const Center(child: Text('No scenarios found'))
                  : ListView.builder(
                      itemCount: _scenarios.length,
                      itemBuilder: (context, index) {
                        final scenario = _scenarios[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: scenario.faction == 'USMC' ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    scenario.faction == 'USMC' ? Icons.flag : Icons.flag_outlined,
                                    color: scenario.faction == 'USMC' ? Colors.blue : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  scenario.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (scenario.description?.isNotEmpty ?? false)
                                      Text(
                                        scenario.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Created: ${DateFormat('MMM d, y').format(scenario.createdAt)}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskGroupListScreen(
                                        scenario: scenario,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Divider(height: 1),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.bar_chart, size: 20),
                                      onPressed: () => _showScenarioStats(scenario.id),
                                      tooltip: 'Statistics',
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.edit, size: 20),
                                      onPressed: () => _editScenario(scenario),
                                      tooltip: 'Edit',
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.content_copy, size: 20),
                                      onPressed: () => _duplicateScenario(scenario.id),
                                      tooltip: 'Duplicate',
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.file_download, size: 20),
                                      onPressed: () => _exportScenario(scenario.id),
                                      tooltip: 'Export',
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete, size: 20),
                                      onPressed: () => _deleteScenario(scenario),
                                      tooltip: 'Delete',
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}

class CreateScenarioDialog extends StatefulWidget {
  const CreateScenarioDialog({super.key});

  @override
  State<CreateScenarioDialog> createState() => _CreateScenarioDialogState();
}

class _CreateScenarioDialogState extends State<CreateScenarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedFaction = 'USMC';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Scenario'),
      content: Form(
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
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFaction,
              decoration: const InputDecoration(labelText: 'Faction'),
              items: const [
                DropdownMenuItem(value: 'USMC', child: Text('USMC')),
                DropdownMenuItem(value: 'PLAN', child: Text('PLAN')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFaction = value;
                  });
                }
              },
            ),
          ],
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
                'description': _descriptionController.text,
                'faction': _selectedFaction,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class EditScenarioDialog extends StatefulWidget {
  final Scenario scenario;

  const EditScenarioDialog({
    super.key,
    required this.scenario,
  });

  @override
  State<EditScenarioDialog> createState() => _EditScenarioDialogState();
}

class _EditScenarioDialogState extends State<EditScenarioDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _selectedFaction;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.scenario.name);
    _descriptionController = TextEditingController(text: widget.scenario.description);
    _selectedFaction = widget.scenario.faction;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Scenario'),
      content: Form(
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
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFaction,
              decoration: const InputDecoration(labelText: 'Faction'),
              items: const [
                DropdownMenuItem(value: 'USMC', child: Text('USMC')),
                DropdownMenuItem(value: 'PLAN', child: Text('PLAN')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFaction = value;
                  });
                }
              },
            ),
          ],
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
                'description': _descriptionController.text,
                'faction': _selectedFaction,
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 