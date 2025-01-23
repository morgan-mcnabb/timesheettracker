import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../models/time_entry.dart';
import '../models/task.dart';
import '../widgets/task_list_widget.dart';

class TimeEntryDetailPage extends StatefulWidget {
  final String timeEntryId;

  const TimeEntryDetailPage({
    super.key,
    required this.timeEntryId,
  });

  @override
  State<TimeEntryDetailPage> createState() => _TimeEntryDetailPageState();
}

class _TimeEntryDetailPageState extends State<TimeEntryDetailPage> {
  TimeEntry? _entry;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTimeEntryAndTasks();
  }

  Future<void> _loadTimeEntryAndTasks() async {
    final timesheet = Provider.of<TimesheetModel>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    final entry = timesheet.findTimeEntryById(widget.timeEntryId);
    if (entry == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Time Entry not found.';
      });
      return;
    }

    try {
      final fetchedTasks = await timesheet.getTasksForTimeEntry(widget.timeEntryId);
      setState(() {
        _entry = entry;
        _tasks = fetchedTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Time Entry Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_entry == null || _errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Time Entry Details')),
        body: Center(
          child: Text(_errorMessage ?? 'No time entry found.'),
        ),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Entry Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Project: ${_entry!.projectName}',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${_entry!.date.toLocal()}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start: ${_entry!.startTime.toLocal()}',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              'End: ${_entry!.endTime.toLocal()}',
              style: theme.textTheme.bodyLarge,
            ),
            const Divider(height: 32),
            Text(
              'Tasks',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            _tasks.isEmpty
                ? const Text(
                    'No tasks for this time entry.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  )
                : TaskListWidget(tasks: _tasks),
          ],
        ),
      ),
    );
  }
}
