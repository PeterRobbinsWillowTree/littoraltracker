import 'package:flutter/material.dart';
import '../models/scenario.dart';
import '../database/database_helper.dart';
import 'task_group_list_screen.dart';

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
                        return ListTile(
                          leading: Icon(
                            scenario.faction == 'USMC'
                                ? Icons.flag
                                : Icons.flag_outlined,
                            color: scenario.faction == 'USMC'
                                ? Colors.blue
                                : Colors.red,
                          ),
                          title: Text(scenario.name),
                          subtitle: Text(scenario.description ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteScenario(scenario),
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