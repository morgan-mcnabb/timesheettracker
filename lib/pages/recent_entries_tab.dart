import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../models/time_entry.dart';

class RecentEntriesTab extends StatelessWidget {
  const RecentEntriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    List<TimeEntry> recentEntries = List.from(timesheet.timeEntries);

    recentEntries.sort((a, b) {
      DateTime aStart = DateTime(a.date.year, a.date.month, a.date.day,
          a.startTime.hour, a.startTime.minute, a.startTime.minute);
      DateTime bStart = DateTime(b.date.year, b.date.month, b.date.day,
          b.startTime.hour, b.startTime.minute, b.startTime.minute);
      return bStart.compareTo(aStart);
    });

    recentEntries = recentEntries.take(5).toList();

    if (recentEntries.isEmpty) {
      return const Center(
        child: Text(
          'No recent time entries.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    const double standardPadding = 16.0;

    return Padding(
      padding: const EdgeInsets.all(standardPadding),
      child: ListView.builder(
        itemCount: recentEntries.length,
        itemBuilder: (context, index) {
          final entry = recentEntries[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 3,
            child: ListTile(
              leading: Icon(
                Icons.work,
                color: Colors.deepPurple[700],
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
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.date.year}-${_twoDigits(entry.date.month)}-${_twoDigits(entry.date.day)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDateTime(entry.startTime)} - ${_formatDateTime(entry.endTime)}',
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
                          size: 16, color: Colors.grey[700]),
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
                          size: 16, color: Colors.green[700]),
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

  static String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  static String _formatDateTime(DateTime dt) {
    final hours = dt.hour.toString().padLeft(2, '0');
    final minutes = dt.minute.toString().padLeft(2, '0');
    final seconds = dt.second.toString().padLeft(2, '0');
    return '$hours:$minutes:${seconds == "00" ? "00" : seconds}';
  }
}
