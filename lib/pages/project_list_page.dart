import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../project.dart';
import '../constants.dart';

class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final List<Project> projects = timesheet.projects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No projects added yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(standardPadding),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      Icons.work,
                      color: Colors.deepPurple[700],
                      size: 30,
                    ),
                    title: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          '\$${project.hourlyRate.toStringAsFixed(2)} / hr',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Project'),
                            content: const Text(
                                'Are you sure you want to delete this project?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  timesheet.deleteProject(index);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProjectDialog(context);
        },
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context, listen: false);
    String projectName = '';
    String hourlyRateStr = '';
    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Project'),
          content: Form(
            key: _dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.work_outline, color: Colors.deepPurple),
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    projectName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.attach_money, color: Colors.deepPurple),
                    labelText: 'Hourly Rate (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    hourlyRateStr = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an hourly rate';
                    }
                    final rate = double.tryParse(value);
                    if (rate == null) {
                      return 'Please enter a valid number';
                    }
                    if (rate < 0) {
                      return 'Hourly rate cannot be negative';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_dialogFormKey.currentState!.validate()) {
                  final double hourlyRate = double.parse(hourlyRateStr);
                  final newProject = Project(
                    name: projectName,
                    hourlyRate: hourlyRate,
                  );
                  timesheet.addProject(newProject);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  static String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
