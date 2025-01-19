import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../styles.dart';
import '../widgets/project_card.dart';
import '../utils.dart';

class SummaryTab extends StatefulWidget {
  const SummaryTab({super.key});

  @override
  _SummaryTabState createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  Future<void> _selectDateRange(BuildContext context) async {
    final timesheet = Provider.of<TimesheetModel>(context, listen: false);
    final initialDateRange = timesheet.startDate != null && timesheet.endDate != null
        ? DateTimeRange(start: timesheet.startDate!, end: timesheet.endDate!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              onSurface: colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: colorScheme.onPrimary, // i CANNOT get this fucking thing to change colors
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      timesheet.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timesheet = Provider.of<TimesheetModel>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(standardPadding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Summary',
              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _selectDateRange(context),
              icon: Icon(Icons.date_range, color: colorScheme.onPrimary),
              label: Text(
                timesheet.startDate != null && timesheet.endDate != null
                    ? '${twoDigits(timesheet.startDate!.month)}/${twoDigits(timesheet.startDate!.day)}/${timesheet.startDate!.year} - ${twoDigits(timesheet.endDate!.month)}/${twoDigits(timesheet.endDate!.day)}/${timesheet.endDate!.year}'
                    : 'Select Date Range',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                      style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${timesheet.totalHoursLogged.toStringAsFixed(2)} hrs',
                      style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary),
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
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${timesheet.totalEarnings.toStringAsFixed(2)}',
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
        const SizedBox(height: 24),
        Text(
          'Projects Overview',
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        timesheet.projectMetrics.isEmpty
            ? Center(
                child: Text(
                  'No projects to display.',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: timesheet.projectMetrics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  mainAxisSpacing: standardPadding,
                  crossAxisSpacing: standardPadding,
                  childAspectRatio: 3 / 2,
                ),
                itemBuilder: (context, index) {
                  final metrics = timesheet.projectMetrics[index];
                  return ProjectCard(
                    project: metrics.project,
                    hoursLogged: metrics.hoursLogged,
                    earnings: metrics.earnings,
                  );
                },
              ),
      ],
    );
  }
}