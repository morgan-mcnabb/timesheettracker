import 'package:flutter/material.dart';
import 'package:timesheettracker/models/project.dart';
import 'package:timesheettracker/models/xata_metadata.dart';
import 'package:timesheettracker/services/project_service.dart';

class ProjectListPage extends StatefulWidget {
  final List<Project> projects;
  final Function(Project) onAdd;
  final Function(int) onDelete;

  const ProjectListPage({
    Key? key,
    required this.projects,
    required this.onAdd,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ProjectListPageState createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  void _addProject() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String projectName = '';
        double hourlyRate = 0.0;
        final _formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Add Project'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Project Name'),
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
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Hourly Rate (\$)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    hourlyRate = double.tryParse(value) ?? 0.0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an hourly rate';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.tryParse(value)! < 0) {
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
                if (_formKey.currentState!.validate()) {
                  try {
                    final projectService = await ProjectService.create();
                    final newProject = Project(
                      id: null,
                      name: projectName,
                      hourlyRate: hourlyRate,
                      xata: XataMetadata(
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        version: 1,
                      ),
                    );
                    await projectService.createProject(newProject);
                    final updatedProjects = await projectService.getProjects();
                    setState(() {
                      widget.projects.clear();
                      widget.projects.addAll(updatedProjects.records);
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error creating project: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: widget.projects.isEmpty
          ? const Center(
              child: Text(
                'No projects added yet.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: widget.projects.length,
              itemBuilder: (context, index) {
                final project = widget.projects[index];
                return ListTile(
                  title: Text(project.name ?? ''),
                  subtitle: Text(
                      'Hourly Rate: \$${project.hourlyRate?.toStringAsFixed(2) ?? ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      try {
                        final projectService = await ProjectService.create();
                        await projectService.deleteProject(project.id!);
                        final updatedProjects =
                            await projectService.getProjects();
                        setState(() {
                          widget.projects.clear();
                          widget.projects.addAll(updatedProjects.records);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error deleting project: ${e.toString()}'),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
      ),
    );
  }
}
