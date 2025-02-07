import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../models/time_entry.dart';
import '../utils.dart';

class RecentEntriesTab extends StatelessWidget {
  const RecentEntriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    List<TimeEntry> recentEntries = List.from(timesheet.timeEntries);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                color: colorScheme.primary,
                size: 30,
              ),
              title: Text(
                entry.project.name,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
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
