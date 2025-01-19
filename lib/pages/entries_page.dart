import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../models/time_entry.dart';
import '../styles.dart';
import '../utils.dart';

class EntriesPage extends StatelessWidget {
  const EntriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final List<TimeEntry> timeEntries = timesheet.getSortedEntries();
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
                      entry.projectName,
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