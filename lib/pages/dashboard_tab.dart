import 'package:flutter/material.dart';
import 'summary_tab.dart';
import 'recent_entries_tab.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../constants.dart';
import 'project_list_page.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: Colors.deepPurple,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Summary', icon: Icon(Icons.dashboard)),
              Tab(text: 'Recent', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: Column(
          children: const [
            ClockSection(),
            Expanded(
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

    String elapsedTime =
        '${elapsed.inHours.toString().padLeft(2, '0')}:${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

    return Card(
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.all(standardPadding),
      child: Padding(
        padding: const EdgeInsets.all(standardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Tracking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 16),
            if (!isClockedIn)
              ElevatedButton.icon(
                onPressed: () {
                  _showClockInDialog(context, timesheet);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Clock In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project: ${currentProject?.name ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elapsed Time: $elapsedTime',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Earnings: \$${currentEarnings.toStringAsFixed(2)}',
                    style:
                        const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
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
                            isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(isPaused ? 'Resume' : 'Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPaused
                              ? Colors.green
                              : Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          timesheet.clockOut();
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Clock Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
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

    if (projects.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Projects Available'),
          content: const Text('Please add a project before clocking in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProjectListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Project'),
            ),
          ],
        ),
      );
      return;
    }

    String selectedProject = projects[0].name;
    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Project to Clock In'),
          content: Form(
            key: _dialogFormKey,
            child: DropdownButtonFormField<String>(
              value: selectedProject,
              items: projects
                  .map(
                    (project) => DropdownMenuItem<String>(
                      value: project.name,
                      child: Text(project.name),
                    ),
                  )
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_dialogFormKey.currentState!.validate()) {
                  final project = projects
                      .firstWhere((proj) => proj.name == selectedProject);
                  timesheet.clockIn(project);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clock In'),
            ),
          ],
        );
      },
    );
  }
}
