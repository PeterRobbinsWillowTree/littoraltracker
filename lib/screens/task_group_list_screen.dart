import 'package:flutter/material.dart';
import '../models/task_group.dart';
import '../screens/task_group_detail_screen.dart';

class TaskGroupListScreen extends StatefulWidget {
  const TaskGroupListScreen({super.key});

  @override
  State<TaskGroupListScreen> createState() => _TaskGroupListScreenState();
}

class _TaskGroupListScreenState extends State<TaskGroupListScreen> {
  // Temporary mock data
  final List<TaskGroup> taskGroups = [
    TaskGroup(
      id: '1',
      name: 'Alpha Group',
      description: 'Primary assault force',
      createdAt: DateTime.now(),
    ),
    TaskGroup(
      id: '2',
      name: 'Bravo Group',
      description: 'Support element',
      createdAt: DateTime.now(),
    ),
  ];

  void _addNewTaskGroup() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Task Group Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  taskGroups.add(
                    TaskGroup(
                      id: (taskGroups.length + 1).toString(),
                      name: nameController.text,
                      description: descriptionController.text,
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Groups'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: taskGroups.length,
        itemBuilder: (context, index) {
          final taskGroup = taskGroups[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(taskGroup.name),
              subtitle: Text(taskGroup.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskGroupDetailScreen(taskGroup: taskGroup),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTaskGroup,
        child: const Icon(Icons.add),
      ),
    );
  }
} 