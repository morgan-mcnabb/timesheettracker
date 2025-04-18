import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../models/project.dart';
import '../styles.dart';
import '../utils.dart';
import '../models/task.dart'; 

class AddTimeEntryPage extends StatefulWidget {
  const AddTimeEntryPage({super.key});

  @override
  _AddTimeEntryPageState createState() => _AddTimeEntryPageState();
}

class _AddTimeEntryPageState extends State<AddTimeEntryPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  Project? _selectedProject;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskNotesController = TextEditingController();

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              onSurface: colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget? child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              onSurface: colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (BuildContext context, Widget? child) {
      final colorScheme = Theme.of(context).colorScheme;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              onSurface: colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  bool _validateTimeOrder() {
    final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute);
    final end = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute);
    return end.isAfter(start);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateTimeOrder()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End Time must be after Start Time')),
      );
      return;
    }

    final timesheet = Provider.of<TimesheetModel>(context, listen: false);
    final String taskName = _taskNameController.text.trim();
    final String taskNotes = _taskNotesController.text.trim();

    try {
      final newTasks = <Task>[
        Task(
          timeEntryId: '', 
          taskName: taskName,
          notes: taskNotes.isEmpty ? null : taskNotes,
        ),
      ];

      await timesheet.addManualTimeEntry(
        _selectedDate,
        _startTime,
        _endTime,
        _selectedProject!,
        tasks: newTasks,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add time entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final projects = timesheet.projects;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Time Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(standardPadding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.calendar_today, color: colorScheme.primary),
                title: Text(
                  'Date: '
                  '${_selectedDate.year}-${twoDigits(_selectedDate.month)}-'
                  '${twoDigits(_selectedDate.day)}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: Icon(Icons.access_time, color: colorScheme.primary),
                title: Text('Start Time: ${_startTime.format(context)}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: _pickStartTime,
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: Icon(Icons.access_time, color: colorScheme.primary),
                title: Text('End Time: ${_endTime.format(context)}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: _pickEndTime,
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<Project>(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.work_outline, color: colorScheme.primary),
                  labelText: 'Select Project',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                items: projects
                    .map((project) => DropdownMenuItem<Project>(
                          value: project,
                          child: Text(project.name),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() => _selectedProject = newValue);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a project';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.task, color: colorScheme.primary),
                  labelText: 'Task Name (Required)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _taskNotesController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.notes, color: colorScheme.primary),
                  labelText: 'Task Notes (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Entry', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}