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
    final List<TimeEntry> timeEntries = timesheet.timeEntries;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Time Entries'),
      ),
      body: timeEntries.isEmpty
          ? Center(
              child: Text(
                'No time entries yet.',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(standardPadding),
              itemCount: timeEntries.length,
              itemBuilder: (context, index) {
                final entry = timeEntries[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.business,
                      color: Colors.blue,
                      size: 30,
                    ),
                    title: Text(
                      entry.project.name,
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold,),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.date.year}-${twoDigits(entry.date.month)}-${twoDigits(entry.date.day)}',
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time,
                            size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${formatDateTime(entry.startTime)} - ${formatDateTime(entry.endTime)}',
                          style: textTheme.bodySmall,
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
                              style: textTheme.bodySmall,
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
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
