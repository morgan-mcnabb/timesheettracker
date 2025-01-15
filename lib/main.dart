// lib/main.dart

import 'package:flutter/material.dart';
import 'time_entry.dart';
import 'add_time_entry_page.dart';
import 'project.dart';
import 'project_list_page.dart';
import 'dart:async'; // Import for Timer

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timesheet Tracker',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  // State variables for Clock In/Out
  bool _isClockedIn = false;
  bool _isPaused = false; // Tracks if the session is paused
  DateTime? _clockInTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _accumulated = Duration.zero; // Accumulates elapsed time before pausing
  double _currentEarnings = 0.0;
  Project? _currentProject;

  /// Starts the clocking in process with project selection
  void _clockIn() async {
    if (_isClockedIn) return; // Prevent multiple clock-ins

    if (_projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a project first before clocking in.')),
      );
      return;
    }

    // Prompt user to select a project
    Project? selectedProject = await showDialog<Project>(
      context: context,
      builder: (BuildContext context) {
        Project? tempSelectedProject;
        final _formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Select Project'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Project>(
                  items: _projects
                      .map(
                        (project) => DropdownMenuItem<Project>(
                          value: project,
                          child: Text(project.name),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
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

    if (selectedProject == null) return; // User canceled

    setState(() {
      _isClockedIn = true;
      _isPaused = false;
      _clockInTime = DateTime.now();
      _elapsed = Duration.zero;
      _accumulated = Duration.zero;
      _currentEarnings = 0.0;
      _currentProject = selectedProject;
    });

    // Start a timer that updates every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        _elapsed = _accumulated + now.difference(_clockInTime!);
        _currentEarnings = (_elapsed.inSeconds / 3600) * _currentProject!.hourlyRate;
      });
    });
  }

  /// Pauses the active session
  void _pauseClock() {
    if (!_isClockedIn || _isPaused) return;

    setState(() {
      _isPaused = true;
      _accumulated += DateTime.now().difference(_clockInTime!);
      _timer?.cancel(); // Stop the timer
    });
  }

  /// Resumes the paused session
  void _resumeClock() {
    if (!_isClockedIn || !_isPaused) return;

    setState(() {
      _isPaused = false;
      _clockInTime = DateTime.now();
      // Restart the timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        setState(() {
          _elapsed = _accumulated + now.difference(_clockInTime!);
          _currentEarnings = (_elapsed.inSeconds / 3600) * _currentProject!.hourlyRate;
        });
      });
    });
  }

  /// Stops the clocking out process
  void _clockOut() {
    if (!_isClockedIn) return; // Prevent clock-out if not clocked in

    final clockOutTime = DateTime.now();

    setState(() {
      _isClockedIn = false;
      _isPaused = false;
      _timer?.cancel();
    });

    // Calculate total elapsed time
    Duration totalElapsed = _accumulated;
    if (!_isPaused && _clockInTime != null) {
      totalElapsed += clockOutTime.difference(_clockInTime!);
    }

    // Create a new TimeEntry
    final newEntry = TimeEntry(
      date: DateTime(_clockInTime!.year, _clockInTime!.month, _clockInTime!.day),
      startTime: TimeOfDay.fromDateTime(_clockInTime!),
      endTime: TimeOfDay.fromDateTime(clockOutTime),
      project: _currentProject!,
      hourlyRate: _currentProject!.hourlyRate,
    );

    setState(() {
      _timeEntries.add(newEntry);
      _elapsed = Duration.zero;
      _accumulated = Duration.zero;
      _currentEarnings = 0.0;
      _clockInTime = null;
      _currentProject = null;
    });
  }

  /// Navigates to the Add Time Entry Page
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
          projects: _projects, // Passing the list of projects
        ),
      ),
    );
  }

  /// Navigates to the Project Management Page
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
    _timer?.cancel(); // Cancel timer if active
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalEarnings =
        _timeEntries.fold(0.0, (sum, entry) => sum + entry.totalEarnings);

    // Calculate Total Hours Logged
    double totalHoursLogged =
        _timeEntries.fold(0.0, (sum, entry) => sum + entry.billableHours);

    // Calculate Project-Specific Metrics
    Map<String, Map<String, double>> projectMetrics = {};
    for (var project in _projects) {
      projectMetrics[project.name] = {
        'hours': 0.0,
        'earnings': 0.0,
      };
    }
    for (var entry in _timeEntries) {
      if (projectMetrics.containsKey(entry.project.name)) {
        projectMetrics[entry.project.name]!['hours'] =
            projectMetrics[entry.project.name]!['hours']! + entry.billableHours;
        projectMetrics[entry.project.name]!['earnings'] =
            projectMetrics[entry.project.name]!['earnings']! + entry.totalEarnings;
      }
    }

    // Determine Recent Time Entries (last 5)
    List<TimeEntry> recentEntries = List.from(_timeEntries);
    // Sort the list by date descending
    recentEntries.sort((a, b) {
      // Combine date and startTime to get the actual start DateTime
      DateTime aStart = DateTime(a.date.year, a.date.month, a.date.day, a.startTime.hour, a.startTime.minute);
      DateTime bStart = DateTime(b.date.year, b.date.month, b.date.day, b.startTime.hour, b.startTime.minute);
      return bStart.compareTo(aStart);
    });
    // Take the first 5 entries
    recentEntries = recentEntries.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            tooltip: 'Manage Projects',
            onPressed: _navigateToManageProjects,
          ),
          if (!_isClockedIn)
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Clock In',
              onPressed: _clockIn,
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Clock Out',
              onPressed: _clockOut,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Made the entire body scrollable
          child: Column(
            children: [
              // Summary Metrics Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Total Hours Logged Card
                    Expanded(
                      child: Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0), // Reduced padding from 16 to 12
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Ensures the column takes minimal vertical space
                            children: [
                              const Text(
                                'Total Hours Logged',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${totalHoursLogged.toStringAsFixed(2)} hrs',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Total Earnings Card
                    Expanded(
                      child: Card(
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0), // Reduced padding from 16 to 12
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Ensures the column takes minimal vertical space
                            children: [
                              const Text(
                                'Total Earnings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '\$${totalEarnings.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Projects Overview Section
              if (_projects.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Projects Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              if (_projects.isNotEmpty)
                SizedBox(
                  height: 180, // Increased height from 150 to 180
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _projects.length,
                    itemBuilder: (context, index) {
                      final project = _projects[index];
                      final metrics = projectMetrics[project.name]!;

                      return Card(
                        margin: const EdgeInsets.only(right: 16.0),
                        elevation: 4,
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(12.0), // Reduced padding from 16 to 12
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Ensures the column takes minimal vertical space
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Hourly Rate: \$${project.hourlyRate.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              Divider(height: 20, color: Colors.grey[400]),
                              Text(
                                'Hours Logged: ${metrics['hours']!.toStringAsFixed(2)} hrs',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              Text(
                                'Earnings: \$${metrics['earnings']!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // **Active Session Display Section (Moved Above Recent Time Entries)**
              if (_isClockedIn)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: Colors.blue[50],
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Ensures the column takes minimal vertical space
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Active Session',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                _isPaused ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                color: _isPaused ? Colors.orange : Colors.green,
                                size: 30,
                              ),
                            ],
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
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isPaused ? _resumeClock : _pauseClock,
                                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                                label: Text(_isPaused ? 'Resume' : 'Pause'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isPaused ? Colors.green : Colors.orange,
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: _clockOut,
                                icon: const Icon(Icons.logout),
                                label: const Text('Clock Out'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, // Corrected from foregroundColor
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Recent Time Entries Section
              if (_timeEntries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Time Entries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              if (_timeEntries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: recentEntries.map((entry) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.work),
                          title: Text(entry.project.name),
                          subtitle: Text(
                            '${entry.date.year}-${_twoDigits(entry.date.month)}-${_twoDigits(entry.date.day)} | ${entry.startTime.format(context)} - ${entry.endTime.format(context)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${entry.billableHours.toStringAsFixed(2)} hrs'),
                              SizedBox(height: 4),
                              Text(
                                '\$${entry.totalEarnings.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Implement navigation to entry details or editing
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // All Time Entries List
              if (_timeEntries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'All Time Entries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              if (_timeEntries.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true, // Important to prevent unbounded height
                  physics: NeverScrollableScrollPhysics(), // Disable inner scroll
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
                          Text('${entry.billableHours.toStringAsFixed(2)} hrs'),
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
            ],
          ),
        ),
      ),
      // **Refined FAB Positioning: Removed Bottom "Total Earnings" and Added Padding Above FAB**
      floatingActionButton: SafeArea( // Ensures FAB respects safe areas
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0), // Adds padding above FAB
          child: FloatingActionButton(
            onPressed: _navigateToAddEntry,
            tooltip: 'Add Time Entry',
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Keeps FAB at the end float position
      // Removed the bottomNavigationBar to prevent overlapping and redundancy
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.all(16.0),
      //   color: Colors.grey[200],
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       const Text(
      //         'Total Earnings:',
      //         style: TextStyle(
      //           fontSize: 18,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       Text(
      //         '\$${totalEarnings.toStringAsFixed(2)}',
      //         style: TextStyle(
      //           fontSize: 18,
      //           fontWeight: FontWeight.bold,
      //           color: Colors.green[700],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
