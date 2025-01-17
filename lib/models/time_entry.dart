import 'package:flutter/material.dart';
import 'package:timesheettracker/models/project.dart';

class TimeEntry {
  final String? id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Project project;
  final String projectName;
  final double? rate;

  TimeEntry({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.project,
    required this.rate,
    required this.projectName,
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    if (json['start_time'] == null) {
      throw Exception("Time Entry JSON missing 'start_time' field.");
    }
    if (json['end_time'] == null) {
      throw Exception("Time Entry JSON missing 'end_time' field.");
    }
    if (json['project'] == null) {
      throw Exception("Time Entry JSON missing 'project' field.");
    }
    if (json['project']['name'] == null) {
      throw Exception("Time Entry JSON 'project' missing 'name' field.");
    }

    final startDateTime = DateTime.parse(json['start_time']);
    final endDateTime = DateTime.parse(json['end_time']);

    return TimeEntry(
      id: json['id'],
      date: startDateTime,
      startTime: TimeOfDay(
        hour: startDateTime.hour,
        minute: startDateTime.minute,
      ),
      endTime: TimeOfDay(
        hour: endDateTime.hour,
        minute: endDateTime.minute,
      ),
      project:
          Project.fromJson(json['project']),
      projectName: json['project']?['name'],
      rate: json['rate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    ).toUtc();

    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    ).toUtc();

    return {
      'start_time': startDateTime.toIso8601String(),
      'end_time': endDateTime.toIso8601String(),
      'project': project.id,
      'rate': rate,
      'project_name': projectName,
    };
  }

  double get billableHours {
    final start = DateTime(
        date.year, date.month, date.day, startTime.hour, startTime.minute);
    final end =
        DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
    return end.difference(start).inMinutes / 60.0;
  }

  double get totalEarnings => billableHours * (rate ?? 0);
}
