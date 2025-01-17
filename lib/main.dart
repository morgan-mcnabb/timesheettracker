import 'package:flutter/material.dart';
import 'time_entry.dart';
import 'add_time_entry_page.dart';
import 'project.dart';
import 'project_list_page.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timesheet Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Timesheet Tracker Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];

  bool _isClockedIn = false;
  DateTime? _clockInTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  double _currentEarnings = 0.0;
  Project? _currentProject;

  void _clockIn() async {
    if (_isClockedIn) return;

    if (_projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add a project first before clocking in.')),
      );
      return;
    }

    Project? selectedProject = await showDialog<Project>(
      context: context,
      builder: (BuildContext context) {
        Project? tempSelectedProject;
        final _formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Select Project'),
          content: Form(
            key: _formKey,
            child: Container(
              width: 300.0,
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButtonFormField<Project>(
                    isExpanded: true,
                    items: _projects
                        .map(
                          (project) => DropdownMenuItem<Project>(
                            value: project,
                            child: Text(
                              project.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (Project? newValue) {
                      tempSelectedProject = newValue;
                    },
                    validator: (value) {
                      if (value == null) {
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
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop(tempSelectedProject);
                }
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );

    if (selectedProject == null) return;

    setState(() {
      _isClockedIn = true;
      _clockInTime = DateTime.now();
      _elapsed = Duration.zero;
      _currentEarnings = 0.0;
      _currentProject = selectedProject;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        _elapsed = now.difference(_clockInTime!);
        _currentEarnings =
            (_elapsed.inSeconds / 3600) * _currentProject!.hourlyRate;
      });
    });
  }

  void _clockOut() {
    if (!_isClockedIn) return;

    final clockOutTime = DateTime.now();

    setState(() {
      _isClockedIn = false;
      _timer?.cancel();
    });

    final newEntry = TimeEntry(
      date:
          DateTime(_clockInTime!.year, _clockInTime!.month, _clockInTime!.day),
      startTime: TimeOfDay.fromDateTime(_clockInTime!),
      endTime: TimeOfDay.fromDateTime(clockOutTime),
      project: _currentProject!,
      hourlyRate: _currentProject!.hourlyRate,
    );

    setState(() {
      _timeEntries.add(newEntry);
    });

    setState(() {
      _elapsed = Duration.zero;
      _currentEarnings = 0.0;
      _clockInTime = null;
      _currentProject = null;
    });
  }

  void _navigateToAddEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTimeEntryPage(
          onAdd: (newEntry) {
            setState(() {
              _timeEntries.add(newEntry);
            });
          },
          projects: _projects,
        ),
      ),
    );
  }

  void _navigateToManageProjects() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectListPage(
          projects: _projects,
          onAdd: (newProject) {
            setState(() {
              _projects.add(newProject);
            });
          },
          onDelete: (index) {
            setState(() {
              _projects.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalEarnings =
        _timeEntries.fold(0.0, (sum, entry) => sum + entry.totalEarnings);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            tooltip: 'Manage Projects',
            onPressed: _navigateToManageProjects,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
          if (!_isClockedIn)
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Clock In',
              onPressed: _clockIn,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Clock Out',
              onPressed: _clockOut,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _timeEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No time entries yet.',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _timeEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _timeEntries[index];
                        return ListTile(
                          leading: const Icon(Icons.work),
                          title: Text(entry.project.name),
                          subtitle: Text(
                            '${entry.date.year}-${_twoDigits(entry.date.month)}-${_twoDigits(entry.date.day)} | ${entry.startTime.format(context)} - ${entry.endTime.format(context)}',
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '${entry.billableHours.toStringAsFixed(2)} hrs'),
                              const SizedBox(height: 4),
                              Text(
                                '\$${entry.totalEarnings.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (_isClockedIn)
              Card(
                color: Colors.blue[50],
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Active Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Project: ${_currentProject!.name}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Elapsed Time:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            _formatDuration(_elapsed),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Earnings:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '\$${_currentEarnings.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _clockOut,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text('Clock Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 16,
              children: [
                const Text(
                  'Total Earnings:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalEarnings.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 25),
              onPressed: _navigateToAddEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(50, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
