import 'package:flutter/material.dart';
import 'styles.dart';
import 'models/time_entry.dart';
import 'package:provider/provider.dart';
import 'models/timesheet_model.dart';
import 'pages/add_time_entry_page.dart';
import 'pages/project_list_page.dart';
import 'pages/dashboard_tab.dart';
import 'utils.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimesheetModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timesheet Tracker',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);

    final List<Widget> pages = [
      const DashboardTab(),
      const ProjectListPage(),
      const EntriesPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Entries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 2)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTimeEntryPage(),
                  ),
                );
              },
              tooltip: 'Add Time Entry',
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Text(
          'Settings Page',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class EntriesPage extends StatelessWidget {
  const EntriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final List<TimeEntry> timeEntries = timesheet.timeEntries;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Time Entries'),
      ),
      body: timeEntries.isEmpty
          ? const Center(
              child: Text(
                'No time entries yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(standardPadding),
              itemCount: timeEntries.length,
              itemBuilder: (context, index) {
                final entry = timeEntries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(
                      Icons.work,
                      color: colorScheme.primary,
                      size: 30,
                    ),
                    title: Text(
                      entry.project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.date.year}-${twoDigits(entry.date.month)}-${twoDigits(entry.date.day)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time,
                            size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${formatDateTime(entry.startTime)} - ${formatDateTime(entry.endTime)}',
                          style: const TextStyle(fontSize: 14),
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
                            Icon(Icons.timer,
                                size: 16, color: colorScheme.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.billableHours.toStringAsFixed(2)} hrs',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_money,
                                size: 16, color: colorScheme.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '\$${entry.totalEarnings.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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
              },
            ),
    );
  }
}
