import 'package:timesheettracker/models/time_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class TimeEntryResponse {
  final List<TimeEntry> records;

  TimeEntryResponse({
    required this.records,
  });

  factory TimeEntryResponse.fromJson(List<dynamic> json) {
    return TimeEntryResponse(
      records: json.map((record) => TimeEntry.fromJson(record)).toList(),
    );
  }
}

class TimeEntryService {
  final supabase = Supabase.instance.client;

  TimeEntryService._();

  static Future<TimeEntryService> create() async {
    return TimeEntryService._();
  }

  Future<TimeEntryResponse> getTimeEntries() async {
    try {
      final user = AuthService.getCurrentUser();
      
      final response = await supabase.from('time_entries').select('''
            id,
            start_time,
            end_time,
            project:projects (
              id,
              name,
              hourly_rate,
              created_at
            ),
            rate,
            project_name
          ''')
            .eq('user_id', user.id) 
            .limit(500);

      print('Raw Time Entries Response: $response');

      final timeEntries = TimeEntryResponse.fromJson(response as List);
      print('Parsed Time Entries:');
      for (var entry in timeEntries.records) {
        print('''
          ID: ${entry.id}
          Date: ${entry.date}
          Start Time: ${entry.startTime}
          End Time: ${entry.endTime}
          Project: ${entry.project.name}
          Project Name: ${entry.projectName}
          Rate: ${entry.rate}
          ----------------------------------------
        ''');
      }

      return timeEntries;
    } catch (e) {
      throw Exception('Failed to load time entries: $e');
    }
  }

  Future<void> createTimeEntry(TimeEntry timeEntry) async {
    try {
      final user = AuthService.getCurrentUser();
      await supabase.from('time_entries').insert({
        'start_time': timeEntry.startTime.toIso8601String(),
        'end_time': timeEntry.endTime.toIso8601String(),
        'project_id': timeEntry.project.id,
        'rate': timeEntry.rate,
        'project_name': timeEntry.project.name,
        'user_id': user.id,
      });
    } catch (e) {
      throw Exception('Failed to create time entry: $e');
    }
  }
}
