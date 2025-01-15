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
                  title: Text(project.name),
                  subtitle: Text('Hourly Rate: \$${project.hourlyRate.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      widget.onDelete(index);
                      setState(() {});
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
