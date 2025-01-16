import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';

class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    double totalEarnings =
        timesheet.timeEntries.fold(0.0, (sum, entry) => sum + entry.totalEarnings);
    double totalHoursLogged =
        timesheet.timeEntries.fold(0.0, (sum, entry) => sum + entry.billableHours);

    const double standardPadding = 16.0;

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
            color: Colors.blue[50],
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
                      color: Colors.blue[700], size: 40),
                  const SizedBox(height: 16),
                  const Text(
                    'Total Hours Logged',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
          Card(
            color: Colors.green[50],
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
                      color: Colors.green[700], size: 40),
                  const SizedBox(height: 16),
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}
