import 'package:flutter/material.dart';

class TimeEntry {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String projectName;
  final double hourlyRate;

  TimeEntry({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.projectName,
    required this.hourlyRate,
  });

  /// Calculates the total hours worked based on start and end times.
  double get billableHours {
    final start = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
    final end = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
    return end.difference(start).inMinutes / 60.0;
  }

  /// Calculates the total earnings based on billable hours and hourly rate.
  double get totalEarnings => billableHours * hourlyRate;
}