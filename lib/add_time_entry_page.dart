import 'package:flutter/material.dart';
import 'time_entry.dart';
import 'project.dart';

class AddTimeEntryPage extends StatefulWidget {
  final Function(TimeEntry) onAdd;
  final List<Project> projects;

  const AddTimeEntryPage({
    Key? key,
    required this.onAdd,
    required this.projects,
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, 
              onPrimary: Colors.white, 
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple, 
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked =
        await showTimePicker(
          context: context,
          initialTime: _startTime,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.deepPurple, 
                  onPrimary: Colors.white,
                  onSurface: Colors.black, 
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
    if (picked != null && picked != _startTime)
      setState(() {
        _startTime = picked;
      });
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay? picked =
        await showTimePicker(
          context: context,
          initialTime: _endTime,
          builder: (BuildContext context, Widget? child) {
            // Applying consistent theme
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.deepPurple, 
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
    if (picked != null && picked != _endTime)
      setState(() {
        _endTime = picked;
      });
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (!_validateTimeOrder()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('End Time must be after Start Time')),
        );
        return;
      }

      final newEntry = TimeEntry(
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        project: _selectedProject!,
        hourlyRate: _selectedProject!.hourlyRate,
      );
      widget.onAdd(newEntry);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Time Entry'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0), 
          child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                    title: Text(
                        'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                    onTap: _pickDate,
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.access_time, color: Colors.deepPurple),
                    title: Text('Start Time: ${_startTime.format(context)}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                    onTap: _pickStartTime,
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.access_time, color: Colors.deepPurple),
                    title: Text('End Time: ${_endTime.format(context)}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                    onTap: _pickEndTime,
                  ),
                  SizedBox(height: 24),
                  DropdownButtonFormField<Project>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.work_outline, color: Colors.deepPurple),
                      labelText: 'Select Project',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    items: widget.projects
                        .map(
                          (project) => DropdownMenuItem<Project>(
                            value: project,
                            child: Text(project.name),
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
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'Add Entry',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              )),
        ));
  }
}

