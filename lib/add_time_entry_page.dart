import 'package:flutter/material.dart';
import 'time_entry.dart';

class AddTimeEntryPage extends StatefulWidget {
  final Function(TimeEntry) onAdd;

  const AddTimeEntryPage({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddTimeEntryPageState createState() => _AddTimeEntryPageState();
}

class _AddTimeEntryPageState extends State<AddTimeEntryPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0);
  String _projectName = '';
  double _billableHours = 8.0;

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newEntry = TimeEntry(
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        projectName: _projectName,
        billableHours: _billableHours,
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
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Project Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _projectName = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Billable Hours',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      _billableHours = double.tryParse(value) ?? 0.0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter billable hours';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
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