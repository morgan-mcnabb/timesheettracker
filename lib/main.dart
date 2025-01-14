import 'package:flutter/material.dart';
import 'time_entry.dart';
import 'add_time_entry_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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


 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
    ),
    body: _timeEntries.isEmpty
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
                leading: Icon(Icons.work),
                title: Text(entry.projectName),
                subtitle: Text(
                  '${_formatDate(entry.date)} | ${entry.startTime.format(context)} - ${entry.endTime.format(context)}',
                ),
                trailing: Text('${entry.billableHours} hrs'),
              );
            },
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTimeEntryPage(
              onAdd: (newEntry) {
                setState(() {
                  _timeEntries.add(newEntry);
                });
              },
            ),
          ),
        );
      },
      tooltip: 'Add Time Entry',
      child: const Icon(Icons.add),
    ),
  );
}

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

}
