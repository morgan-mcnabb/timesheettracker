import 'package:timesheettracker/models/time_entry.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'dart:convert';

class TimeEntryResponse {
  final List<TimeEntry> records;
  final bool hasMore;
  final String? nextCursor;
  final int pageSize;

  TimeEntryResponse({
    required this.records,
    required this.hasMore,
    this.nextCursor,
    required this.pageSize,
  });

  factory TimeEntryResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta']['page'];
    final records = (json['records'] as List)
        .map((record) => TimeEntry.fromJson(record))
        .toList();

    return TimeEntryResponse(
      records: records,
      hasMore: meta['more'] ?? false,
      nextCursor: meta['cursor'],
      pageSize: meta['size'],
    );
  }
}

class TimeEntryService {
  final String apiKey;
  final String databaseUrl;

  TimeEntryService._({
    required this.apiKey,
    required this.databaseUrl,
  });

  static Future<TimeEntryService> create() async {
    var env = DotEnv()..load();

    final apiKey = env['XATA_API_KEY'];
    final databaseURL = env['XATA_DATABASE_URL'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("XATA_API_KEY is missing in environment variables");
    }

    if (databaseURL == null || databaseURL.isEmpty) {
      throw Exception("XATA_DATABASE_URL is missing in environment variables");
    }

    return TimeEntryService._(
      apiKey: apiKey,
      databaseUrl: databaseURL,
    );
  }

  Future<TimeEntryResponse> getTimeEntries() async {
    final response = await http.post(
      Uri.parse('$databaseUrl/db/time-tracking:main/tables/time_entries/query'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "columns": [
          "start_time",
          "end_time",
          "project.*",
          "rate",
          "project_name"
        ],
        "page": {"size": 500}
      }),
    );

    if (response.statusCode == 200) {
      return TimeEntryResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load time entries: ${response.statusCode}');
    }
  }

  Future<void> createTimeEntry(TimeEntry timeEntry) async {
    final response = await http.post(
      Uri.parse('$databaseUrl/db/time-tracking:main/tables/time_entries/data'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(timeEntry.toJson()),
    );

    print(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create time entry: ${response.statusCode}');
    }
  }
}
