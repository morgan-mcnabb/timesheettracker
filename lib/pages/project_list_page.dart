import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/xata_metadata.dart';
import '../models/timesheet_model.dart';
import '../models/project.dart';
import '../styles.dart';

class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final List<Project> projects = timesheet.projects;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
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
                  Icon(Icons.business, size: 80, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No projects added yet.',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
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
                  child: ListTile(
                    leading: Icon(
                      Icons.work,
                      color: colorScheme.primary,
                      size: 30,
                    ),
                    title: Text(
                      project.name,
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 16, color: colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '\$${project.hourlyRate.toStringAsFixed(2)} / hr',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: colorScheme.error),
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
                                  backgroundColor: colorScheme.error,
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
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context, listen: false);
    String projectName = '';
    String hourlyRateStr = '';
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Project'),
          content: Form(
            key: dialogFormKey,
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
                if (dialogFormKey.currentState!.validate()) {
                  final double hourlyRate = double.parse(hourlyRateStr);
                  final newProject = Project(
                    id: "",
                    name: projectName,
                    hourlyRate: hourlyRate,
                    xata: XataMetadata(),
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

  static String twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
