import 'package:flutter/material.dart';
import 'package:timesheettracker/models/client.dart';

class TimeEntry {
  final String? id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Client client;
  final double hourlyRate;

  TimeEntry({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.client,
    required this.hourlyRate,
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
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
      client: Client.fromJson(json['client']),
      hourlyRate: json['client']['hourly_rate']?.toDouble() ?? 0.0,
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
      'client': client.id,
    };
  }

  double get billableHours {
    final start = DateTime(
        date.year, date.month, date.day, startTime.hour, startTime.minute);
    final end =
        DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
    return end.difference(start).inMinutes / 60.0;
  }

  double get totalEarnings => billableHours * hourlyRate;
}
