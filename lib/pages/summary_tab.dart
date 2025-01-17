import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../styles.dart';

class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    double totalEarnings =
        timesheet.timeEntries.fold(0.0, (sum, entry) => sum + entry.totalEarnings);
    double totalHoursLogged =
        timesheet.timeEntries.fold(0.0, (sum, entry) => sum + entry.billableHours);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(standardPadding),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              MediaQuery.of(context).size.width > 600 ? 3 : 2,
          mainAxisSpacing: standardPadding,
          crossAxisSpacing: standardPadding,
          childAspectRatio: 3 / 2,
        ),
        children: [
          Card(
            color: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(standardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.access_time,
                      color: colorScheme.primary, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'Total Hours Logged',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalHoursLogged.toStringAsFixed(2)} hrs',
                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(standardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.attach_money,
                      color: colorScheme.primary, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'Total Earnings',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold,),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalEarnings.toStringAsFixed(2)}',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
