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
      title: 'Timesheet Tracker',
      debugShowCheckedModeBanner: false, 
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

  void _clockIn() async {
    if (_isClockedIn) return; 

    if (_projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a project first before clocking in.')),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Project>(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.work_outline),
                    labelText: 'Project',
                    border: OutlineInputBorder(),
                  ),
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
      _isPaused = false;
      _clockInTime = DateTime.now();
      _elapsed = Duration.zero;
      _accumulated = Duration.zero;
      _currentEarnings = 0.0;
      _currentProject = selectedProject;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        _elapsed = _accumulated + now.difference(_clockInTime!);
        _currentEarnings = (_elapsed.inSeconds / 3600) * _currentProject!.hourlyRate;
      });
    });
  }

  void _pauseClock() {
    if (!_isClockedIn || _isPaused) return;

    setState(() {
      _isPaused = true;
      _accumulated += DateTime.now().difference(_clockInTime!);
      _timer?.cancel(); 
    });
  }

  void _resumeClock() {
    if (!_isClockedIn || !_isPaused) return;

    setState(() {
      _isPaused = false;
      _clockInTime = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        setState(() {
          _elapsed = _accumulated + now.difference(_clockInTime!);
          _currentEarnings = (_elapsed.inSeconds / 3600) * _currentProject!.hourlyRate;
        });
      });
    });
  }

  void _clockOut() {
    if (!_isClockedIn) return; 

    final clockOutTime = DateTime.now();

    setState(() {
      _isClockedIn = false;
      _isPaused = false;
      _timer?.cancel();
    });

    Duration totalElapsed = _accumulated;
    if (!_isPaused && _clockInTime != null) {
      totalElapsed += clockOutTime.difference(_clockInTime!);
    }

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

    double totalHoursLogged =
        _timeEntries.fold(0.0, (sum, entry) => sum + entry.billableHours);

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

    List<TimeEntry> recentEntries = List.from(_timeEntries);
    recentEntries.sort((a, b) {
      DateTime aStart = DateTime(a.date.year, a.date.month, a.date.day, a.startTime.hour, a.startTime.minute);
      DateTime bStart = DateTime(b.date.year, b.date.month, b.date.day, b.startTime.hour, b.startTime.minute);
      return bStart.compareTo(aStart);
    });
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
        child: SingleChildScrollView( 
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
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
                    height: 220, 
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        final project = _projects[index];
                        final metrics = projectMetrics[project.name]!;

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
                                    Text(
                                      project.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple[700],
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                SizedBox(height: 24),

                if (_isClockedIn) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      color: Colors.orange[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isPaused ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                  color: _isPaused ? Colors.orange : Colors.green,
                                  size: 30,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Active Session',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.business, color: Colors.grey[700]),
                                    SizedBox(width: 8),
                                    Text(
                                      'Project:',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Text(
                                  _currentProject!.name,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.timer, color: Colors.grey[700]),
                                    SizedBox(width: 8),
                                    Text(
                                      'Elapsed Time:',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ],
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
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.attach_money, color: Colors.grey[700]),
                                    SizedBox(width: 8),
                                    Text(
                                      'Current Earnings:',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ],
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
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _isPaused ? _resumeClock : _pauseClock,
                                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                                  label: Text(_isPaused ? 'Resume' : 'Pause'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isPaused ? Colors.green : Colors.orange,
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  ),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _clockOut,
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Clock Out'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                SizedBox(height: 24),

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
                      shrinkWrap: true, 
                      physics: NeverScrollableScrollPhysics(),
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
              ]
              ),
            ),
          ),
        ),
      
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FloatingActionButton(
            onPressed: _navigateToAddEntry,
            tooltip: 'Add Time Entry',
            child: const Icon(Icons.add),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
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
