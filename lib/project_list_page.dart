// lib/project_list_page.dart

import 'package:flutter/material.dart';
import 'project.dart';

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
  void _addProject() {
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
                // Project Name Field
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.work_outline, color: Colors.deepPurple),
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
                SizedBox(height: 16),
                // Hourly Rate Field
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.attach_money, color: Colors.deepPurple),
                    labelText: 'Hourly Rate (\$)',
                    border: OutlineInputBorder(),
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newProject = Project(
                    name: projectName,
                    hourlyRate: hourlyRate,
                  );
                  widget.onAdd(newProject);
                  setState(() {});
                  Navigator.of(context).pop();
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
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: widget.projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  const Text(
                    'No projects added yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.projects.length,
              itemBuilder: (context, index) {
                final project = widget.projects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(Icons.work, color: Colors.deepPurple[700], size: 30),
                    title: Text(
                      project.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Colors.grey[700]),
                        SizedBox(width: 4),
                        Text(
                          '\$${project.hourlyRate.toStringAsFixed(2)} / hr',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        widget.onDelete(index);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }
}
