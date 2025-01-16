import 'package:flutter/material.dart';
import 'project.dart';

class TimeEntry {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Project project;
  final double hourlyRate;

  TimeEntry({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.project,
    required this.hourlyRate,
  });

  double get billableHours {
    final start = DateTime(date.year, date.month, date.day, startTime.hour,
        startTime.minute);
    final end = DateTime(date.year, date.month, date.day, endTime.hour,
        endTime.minute);
    return end.difference(start).inMinutes / 60.0;
  }

  double get totalEarnings => billableHours * hourlyRate;
}
