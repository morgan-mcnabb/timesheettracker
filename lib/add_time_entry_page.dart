import 'package:flutter/material.dart';
import 'package:timesheettracker/models/time_entry.dart';
import 'package:timesheettracker/models/project.dart';
import 'package:timesheettracker/services/time_entry_service.dart';

class AddTimeEntryPage extends StatefulWidget {
  final Function(TimeEntry) onAdd;
  final List<Project> projects;
  final TimeEntryService timeEntryService;

  const AddTimeEntryPage({
    Key? key,
    required this.onAdd,
    required this.projects,
    required this.timeEntryService,
  }) : super(key: key);

  @override
  _AddTimeEntryPageState createState() => _AddTimeEntryPageState();
}

class _AddTimeEntryPageState extends State<AddTimeEntryPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0);
  Project? _selectedProject;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null && picked != _startTime)
      setState(() {
        _startTime = picked;
      });
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _endTime);
    if (picked != null && picked != _endTime)
      setState(() {
        _endTime = picked;
      });
  }

  bool _validateTimeOrder() {
    final start = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _startTime.hour, _startTime.minute);
    final end = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _endTime.hour, _endTime.minute);
    return end.isAfter(start);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!_validateTimeOrder()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('End Time must be after Start Time')),
        );
        return;
      }

      final newEntry = TimeEntry(
        id: null,
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        project: _selectedProject!,
        rate: _selectedProject!.hourlyRate ?? 0,
        projectName: _selectedProject!.name ?? '',
      );

      widget.timeEntryService.createTimeEntry(newEntry).then((_) async {
        // Fetch updated entries from server
        final timeEntriesResponse =
            await widget.timeEntryService.getTimeEntries();
        widget.onAdd(
            timeEntriesResponse.records.last); // Pass the server-created entry
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create time entry: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Time Entry'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                        'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text('Start Time: ${_startTime.format(context)}'),
                    trailing: Icon(Icons.access_time),
                    onTap: _pickStartTime,
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text('End Time: ${_endTime.format(context)}'),
                    trailing: Icon(Icons.access_time),
                    onTap: _pickEndTime,
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<Project>(
                    decoration: InputDecoration(
                      labelText: 'Select Project',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.projects
                        .map(
                          (project) => DropdownMenuItem<Project>(
                            value: project,
                            child: Text(project.name ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (Project? newValue) {
                      setState(() {
                        _selectedProject = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a project';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text('Add Entry'),
                  )
                ],
              )),
        ));
  }
}
