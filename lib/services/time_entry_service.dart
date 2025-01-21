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
            project_name,
            invoice_id
          ''')
            .eq('user_id', user.id) 
            .limit(500);

      final timeEntries = TimeEntryResponse.fromJson(response as List);
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
        'invoice_id': timeEntry.invoiceId
      });
    } catch (e) {
      throw Exception('Failed to create time entry: $e');
    }
  }
  
Future<void> updateTimeEntriesInvoiceId({
  required List<String> timeEntryIds,
  required String invoiceId,
}) async {
  try {
    final user = AuthService.getCurrentUser();
    
    // gotta format!
    final formattedIds = timeEntryIds.join(',');

    await supabase
        .from('time_entries')
        .update({'invoice_id': invoiceId})
        .eq('user_id', user.id)
        .filter('id', 'in','($formattedIds)');
  } catch (e) {
    throw Exception('Failed to update invoice_id on time entries: $e');
  }
} 
}


