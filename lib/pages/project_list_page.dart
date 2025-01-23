import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timesheettracker/services/project_service.dart';
import '../models/timesheet_model.dart';
import '../models/project.dart';
import '../styles.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: Consumer<TimesheetModel>(
        builder: (context, timesheet, child) {
          if (timesheet.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (timesheet.hasError) {
            return Center(
              child: Text('Error: ${timesheet.error}'),
            );
          }

          final projects = timesheet.projects;

          if (projects.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
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
                    color: colorScheme.primary,
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
                          size: 16, color: colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${project.hourlyRate.toStringAsFixed(2)} / hr',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Project'),
                          content: const Text(
                              'Are you sure you want to delete this project?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          final projectService = await ProjectService.create();
                          await projectService.deleteProject(project.id);
                          await timesheet.refreshProjects();

                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Project deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete project: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              );
            },
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
    final colorScheme = Theme.of(context).colorScheme;

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
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.work_outline, color: colorScheme.primary),
                    labelText: 'Project Name',
                    border: const OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.attach_money, color: colorScheme.primary),
                    labelText: 'Hourly Rate (\$)',
                    border: const OutlineInputBorder(),
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
              onPressed: () async {
                if (dialogFormKey.currentState!.validate()) {
                  try {
                    final double hourlyRate = double.parse(hourlyRateStr);
                    final newProject = Project(
                      id: "",
                      name: projectName,
                      hourlyRate: hourlyRate,
                      createdAt: DateTime.now(),
                    );

                    final projectService = await ProjectService.create();
                    await projectService.createProject(newProject);
                    await timesheet.refreshProjects();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Project created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to create project: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
