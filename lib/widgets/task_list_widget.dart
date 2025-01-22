import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;

  const TaskListWidget({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final task = tasks[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.task, color: colorScheme.primary),
            title: Text(
              task.taskName,
              style: theme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: task.notes != null && task.notes!.isNotEmpty
                ? Text(task.notes!)
                : const Text('No notes'),
          ),
        );
      },
    );
  }
}
