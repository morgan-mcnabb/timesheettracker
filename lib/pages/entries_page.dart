import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timesheet_model.dart';
import '../styles.dart';
import '../utils.dart';
import '../models/project.dart';
import 'time_entry_detail_page.dart';

class EntriesPage extends StatefulWidget {
  const EntriesPage({super.key});

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  Project? _selectedProject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timesheet = Provider.of<TimesheetModel>(context, listen: false);
      if (timesheet.startDate == null && timesheet.endDate == null) {
        final now = DateTime.now();
        final last30days = now.subtract(const Duration(days: 30));
        timesheet.setDateRange(last30days, now);
      }
    });
  }

  Future<void> _pickDateRange(BuildContext context) async {
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
                foregroundColor: colorScheme.onPrimary,
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
    final projects = timesheet.projects;
    final timeEntries = timesheet.getSortedEntries();
    final colorScheme = Theme.of(context).colorScheme;

    String dateRangeText = 'Last 30 Days';
    if (timesheet.startDate != null && timesheet.endDate != null) {
      final start = timesheet.startDate!;
      final end = timesheet.endDate!;
      dateRangeText =
          '${twoDigits(start.month)}/${twoDigits(start.day)}/${start.year} - '
          '${twoDigits(end.month)}/${twoDigits(end.day)}/${end.year}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Time Entries'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<Project?>(
              value: _selectedProject,
              hint: const Text('Filter by Project', style: TextStyle(color: Colors.white)),
              dropdownColor: colorScheme.primary,
              underline: Container(),
              iconEnabledColor: Colors.white,
              items: [
                const DropdownMenuItem<Project?>(
                  value: null,
                  child: Text('All Projects', style: TextStyle(color: Colors.white)),
                ),
                ...projects.map((project) {
                  return DropdownMenuItem<Project?>(
                    value: project,
                    child: Text(project.name, style: const TextStyle(color: Colors.white)),
                  );
                }),
              ],
              onChanged: (selected) {
                setState(() => _selectedProject = selected);
                timesheet.setProjectFilter(selected);
              },
            ),
          ),
        ],
      ),
      body: timesheet.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(standardPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickDateRange(context),
                        icon: Icon(Icons.date_range, color: colorScheme.onPrimary),
                        label: Text(dateRangeText, style: const TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Switch(
                            value: timesheet.showUninvoicedOnly,
                            onChanged: (value) {
                              timesheet.setShowUninvoicedOnly(value);
                            },
                            activeColor: colorScheme.primary,
                          ),
                          const Text('Uninvoiced Only'),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: timeEntries.isEmpty
                      ? const Center(
                          child: Text(
                            'No time entries found matching your filters.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.center,
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
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12.0),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TimeEntryDetailPage(timeEntryId: entry.id!),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Project name row
                                      Row(
                                        children: [
                                          Icon(Icons.work, color: colorScheme.primary, size: 30),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              entry.projectName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 16, color: colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${entry.date.year}-${twoDigits(entry.date.month)}-${twoDigits(entry.date.day)}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(Icons.access_time,
                                              size: 16, color: colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${formatDateTime(entry.startTime)} - ${formatDateTime(entry.endTime)}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
