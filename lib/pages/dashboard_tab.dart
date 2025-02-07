import 'package:flutter/material.dart';
import 'summary_tab.dart';
import 'recent_entries_tab.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../styles.dart';
import '../models/task.dart';
import 'project_list_page.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Material(
              color: colorScheme.surface,
              child: TabBar(
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                labelStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Summary', icon: Icon(Icons.dashboard)),
                  Tab(text: 'Recent', icon: Icon(Icons.history)),
                ],
              ),
            ),
            const ClockSection(),
            const Expanded(
              child: TabBarView(
                children: [
                  SummaryTab(),
                  RecentEntriesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClockSection extends StatelessWidget {
  const ClockSection({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final isClockedIn = timesheet.isClockedIn;
    final isPaused = timesheet.isPaused;
    final currentEarnings = timesheet.currentEarnings;
    final elapsed = timesheet.elapsed;
    final currentProject = timesheet.currentProject;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final elapsedTime =
        '${elapsed.inHours.toString().padLeft(2, '0')}:'
        '${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

    return Card(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: standardPadding, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(standardPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Tracking',
              style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 12),
            if (!isClockedIn)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showClockInDialog(context, timesheet),
                  icon: Icon(Icons.play_arrow, size: 20, color: colorScheme.onPrimary),
                  label: Text(
                    'Clock In',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Project: ${currentProject?.name ?? 'N/A'}', style: textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  Text('Elapsed Time: $elapsedTime', style: textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Current Earnings: \$${currentEarnings.toStringAsFixed(2)}',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.secondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (isPaused) {
                            timesheet.resumeClock();
                          } else {
                            timesheet.pauseClock();
                          }
                        },
                        icon: Icon(
                          isPaused ? Icons.play_arrow : Icons.pause,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        label: Text(isPaused ? 'Resume' : 'Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPaused ? Colors.green[700] : colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          timesheet.pauseClock();
                          _showClockOutTaskDialog(context, timesheet);
                        },
                        icon: Icon(Icons.stop, size: 18, color: colorScheme.onPrimary),
                        label: const Text('Clock Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showClockInDialog(BuildContext context, TimesheetModel timesheet) {
    final projects = timesheet.projects;
    final colorScheme = Theme.of(context).colorScheme;

    if (projects.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No Projects Available'),
          content: const Text('Please add a project before clocking in.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (ctx2) => const ProjectListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Add Project'),
            ),
          ],
        ),
      );
      return;
    }

    String selectedProject = projects[0].name;
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Project to Clock In'),
          content: Form(
            key: dialogFormKey,
            child: DropdownButtonFormField<String>(
              value: selectedProject,
              items: projects
                  .map((project) => DropdownMenuItem<String>(
                        value: project.name,
                        child: Text(project.name),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedProject = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a project';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Project',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  final project = projects.firstWhere((proj) => proj.name == selectedProject);
                  timesheet.clockIn(project);
                  Navigator.of(ctx).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Clock In'),
            ),
          ],
        );
      },
    );
  }

  void _showClockOutTaskDialog(BuildContext context, TimesheetModel timesheet) {
    final dialogFormKey = GlobalKey<FormState>();
    final taskNameController = TextEditingController();
    final taskNotesController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Clock Out Task'),
          content: Form(
            key: dialogFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: taskNameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.task, color: colorScheme.primary),
                      labelText: 'Task Name (Required)',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: taskNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Task Notes (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  final String taskName = taskNameController.text.trim();
                  final String taskNotes = taskNotesController.text.trim();

                  final newTasks = <Task>[
                    Task(
                      timeEntryId: '',
                      taskName: taskName,
                      notes: taskNotes.isEmpty ? null : taskNotes,
                    ),
                  ];

                  Navigator.of(ctx).pop(); 
                  timesheet.clockOut(tasks: newTasks);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                textStyle: textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}