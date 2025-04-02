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
        onPressed: () {
          // TODO: Implement add new task group
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new task group')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 