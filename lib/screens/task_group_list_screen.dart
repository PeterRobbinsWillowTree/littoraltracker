import 'package:flutter/material.dart';
import '../models/task_group.dart';
import '../models/scenario.dart';
import '../database/database_helper.dart';
import 'task_group_detail_screen.dart';

class TaskGroupListScreen extends StatefulWidget {
  final Scenario scenario;

  const TaskGroupListScreen({
    super.key,
    required this.scenario,
  });

  @override
  State<TaskGroupListScreen> createState() => _TaskGroupListScreenState();
}

class _TaskGroupListScreenState extends State<TaskGroupListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<TaskGroup> _taskGroups = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTaskGroups();
  }

  Future<void> _loadTaskGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskGroupMaps = await _dbHelper.getTaskGroupsForScenario(widget.scenario.id);
      setState(() {
        _taskGroups = taskGroupMaps.map((map) => TaskGroup.fromMap(map)).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load task groups: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTaskGroup() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => CreateTaskGroupDialog(
        faction: widget.scenario.faction,
      ),
    );

    if (result != null) {
      try {
        await _dbHelper.createTaskGroup(
          scenarioId: widget.scenario.id,
          name: result['name']!,
          faction: widget.scenario.faction,
          description: result['description'],
        );
        await _loadTaskGroups();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to create task group: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _deleteTaskGroup(TaskGroup taskGroup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task Group'),
        content: Text('Are you sure you want to delete "${taskGroup.name}"?'),
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
        await _dbHelper.deleteTaskGroup(taskGroup.id);
        await _loadTaskGroups();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to delete task group: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenario.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createTaskGroup,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _taskGroups.isEmpty
                  ? const Center(child: Text('No task groups found'))
                  : ListView.builder(
                      itemCount: _taskGroups.length,
                      itemBuilder: (context, index) {
                        final taskGroup = _taskGroups[index];
                        return ListTile(
                          title: Text(taskGroup.name),
                          subtitle: Text(taskGroup.description ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTaskGroup(taskGroup),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskGroupDetailScreen(
                                  taskGroup: taskGroup,
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

class CreateTaskGroupDialog extends StatefulWidget {
  final String faction;

  const CreateTaskGroupDialog({
    super.key,
    required this.faction,
  });

  @override
  State<CreateTaskGroupDialog> createState() => _CreateTaskGroupDialogState();
}

class _CreateTaskGroupDialogState extends State<CreateTaskGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Task Group'),
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
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
} 