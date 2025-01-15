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
        textTheme: TextTheme(
          headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(fontSize: 16.0),
        ),
      ),
      home: const MyHomePage(title: 'Timesheet Tracker'),
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
  bool _isPaused = false;
  DateTime? _clockInTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _accumulated = Duration.zero;
  double _currentEarnings = 0.0;
  Project? _currentProject;

  /// Starts the clocking in process with project selection
  void _clockIn(Project project) async {
    if (_isClockedIn) return; // Prevent multiple clock-ins

    setState(() {
      _isClockedIn = true;
      _isPaused = false;
      _clockInTime = DateTime.now();
      _elapsed = Duration.zero;
      _accumulated = Duration.zero;
      _currentEarnings = 0.0;
      _currentProject = project;
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
          // **Removed Clock-In/Clock-Out Buttons from AppBar**
          // Previously:
          // if (!_isClockedIn)
          //   IconButton(
          //     icon: const Icon(Icons.login),
          //     tooltip: 'Clock In',
          //     onPressed: _clockIn,
          //   )
          // else
          //   IconButton(
          //     icon: const Icon(Icons.logout),
          //     tooltip: 'Clock Out',
          //     onPressed: _clockOut,
          //   ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Made the entire body scrollable
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                // Summary Metrics Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Total Hours Logged Card
                      Expanded(
                        child: Card(
                          color: Colors.blue[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.blue[700], size: 40),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.attach_money, color: Colors.green[700], size: 40),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Projects Overview Section
                if (_projects.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(Icons.business_center, color: Colors.grey[700]),
                          SizedBox(width: 8),
                          Text(
                            'Projects Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 220, // Increased height for better card display
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        final project = _projects[index];
                        final metrics = projectMetrics[project.name]!;

                        bool isActiveProject = _isClockedIn && _currentProject == project;

                        return Card(
                          margin: const EdgeInsets.only(right: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: Colors.white,
                          elevation: 4,
                          child: Container(
                            width: 220,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.work, color: Colors.deepPurple[700], size: 30),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        project.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple[700],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Hourly Rate: \$${project.hourlyRate.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                                Divider(height: 20, color: Colors.grey[400]),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Hours Logged',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                    Text(
                                      '${metrics['hours']!.toStringAsFixed(2)} hrs',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Earnings',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                    Text(
                                      '\$${metrics['earnings']!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                // **Added Clock-In/Clock-Out Button**
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: !_isClockedIn || (isActiveProject)
                                        ? () {
                                            if (!_isClockedIn) {
                                              _clockIn(project);
                                            } else if (isActiveProject) {
                                              _clockOut();
                                            }
                                          }
                                        : null, // Disable button if another session is active
                                    icon: Icon(
                                      !_isClockedIn
                                          ? Icons.login
                                          : Icons.logout,
                                      size: 20,
                                    ),
                                    label: Text(
                                      !_isClockedIn
                                          ? 'Clock In'
                                          : 'Clock Out',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: !_isClockedIn
                                          ? Colors.deepPurple
                                          : Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                SizedBox(height: 24),

                // Active Session Display Section
                if (_isClockedIn) ...[
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade50,
              Colors.deepPurple.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0), // Reduced padding for smaller card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Buttons
            Row(
              children: [
                Icon(
                  _isPaused ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: _isPaused ? Colors.orange : Colors.green,
                  size: 28, // Slightly smaller icon size
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Active Session',
                    style: TextStyle(
                      fontSize: 20, // Slightly reduced font size
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                ),
                // Action Buttons
                Row(
                  children: [
                    // Pause/Resume Button
                    ElevatedButton.icon(
                      onPressed: _isPaused ? _resumeClock : _pauseClock,
                      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 20),
                      label: Text(
                        _isPaused ? 'Resume' : 'Pause',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPaused ? Colors.green : Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Clock-Out Button
                    ElevatedButton.icon(
                      onPressed: _clockOut,
                      icon: Icon(Icons.logout, size: 20),
                      label: Text(
                        'Clock Out',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12), // Reduced spacing

            // Project Information
            Row(
              children: [
                Icon(Icons.business, color: Colors.deepPurple[700], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentProject!.name,
                    style: TextStyle(
                      fontSize: 16, // Slightly reduced font size
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12), // Reduced spacing

            // Elapsed Time and Earnings
            Row(
              children: [
                // Elapsed Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Elapsed Time',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDuration(_elapsed),
                        style: TextStyle(
                          fontSize: 18, // Slightly reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[900],
                        ),
                      ),
                    ],
                  ),
                ),
                // Current Earnings
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Earnings',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${_currentEarnings.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18, // Slightly reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
],
                SizedBox(height: 24),

                // Recent Time Entries Section
                if (_timeEntries.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: Colors.grey[700]),
                        SizedBox(width: 8),
                        Text(
                          'Recent Time Entries',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: recentEntries.map((entry) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: Icon(Icons.work, color: Colors.deepPurple[700], size: 30),
                            title: Text(
                              entry.project.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  '${entry.date.year}-${_twoDigits(entry.date.month)}-${_twoDigits(entry.date.day)}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  '${entry.startTime.format(context)} - ${entry.endTime.format(context)}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer, size: 16, color: Colors.grey[700]),
                                    SizedBox(width: 4),
                                    Text(
                                      '${entry.billableHours.toStringAsFixed(2)} hrs',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                                    SizedBox(width: 4),
                                    Text(
                                      '\$${entry.totalEarnings.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
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
                ],

                SizedBox(height: 24),

                // All Time Entries List
                if (_timeEntries.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.list_alt, color: Colors.grey[700]),
                        SizedBox(width: 8),
                        Text(
                          'All Time Entries',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true, // Important to prevent unbounded height
                      physics: NeverScrollableScrollPhysics(), // Disable inner scroll
                      itemCount: _timeEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _timeEntries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(Icons.work, color: Colors.deepPurple[700], size: 30),
                            title: Text(
                              entry.project.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  '${entry.date.year}-${_twoDigits(entry.date.month)}-${_twoDigits(entry.date.day)}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  '${entry.startTime.format(context)} - ${entry.endTime.format(context)}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer, size: 16, color: Colors.grey[700]),
                                    SizedBox(width: 4),
                                    Text(
                                      '${entry.billableHours.toStringAsFixed(2)} hrs',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                                    SizedBox(width: 4),
                                    Text(
                                      '\$${entry.totalEarnings.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SafeArea( // Ensures FAB respects safe areas
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FloatingActionButton(
            onPressed: _navigateToAddEntry,
            tooltip: 'Add Time Entry',
            child: const Icon(Icons.add),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, 
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
