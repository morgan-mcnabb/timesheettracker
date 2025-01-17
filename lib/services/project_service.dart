import '../models/project.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'dart:convert';

class ProjectResponse {
  final List<Project> records;
  final bool hasMore;
  final String? nextCursor;
  final int pageSize;

  ProjectResponse({
    required this.records,
    required this.hasMore,
    this.nextCursor,
    required this.pageSize,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta']['page'];
    final records = (json['records'] as List)
        .map((record) => Project.fromJson(record))
        .toList();

    return ProjectResponse(
      records: records,
      hasMore: meta['more'] ?? false,
      nextCursor: meta['cursor'],
      pageSize: meta['size'],
    );
  }
}

class ProjectService {
  final String apiKey;
  final String databaseUrl;

  ProjectService._({
    required this.apiKey,
    required this.databaseUrl,
  });

  static Future<ProjectService> create() async {
    var env = DotEnv()..load();

    final apiKey = env['XATA_API_KEY'];
    final databaseURL = env['XATA_DATABASE_URL'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("XATA_API_KEY is missing in environment variables");
    }

    if (databaseURL == null || databaseURL.isEmpty) {
      throw Exception("XATA_DATABASE_URL is missing in environment variables");
    }

    return ProjectService._(
      apiKey: apiKey,
      databaseUrl: databaseURL,
    );
  }

  Future<ProjectResponse> getProjects() async {
    final response = await http.post(
      Uri.parse('$databaseUrl/db/time-tracking:main/tables/projects/query'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "columns": ["xata_id", "name", "hourly_rate"],
        "page": {"size": 500}
      }),
    );

    if (response.statusCode == 200) {
      final projectResponse =
          ProjectResponse.fromJson(jsonDecode(response.body));
      return projectResponse;
    } else {
      throw Exception('Failed to load projects');
    }
  }

  Future<void> createProject(Project project) async {
    print('Creating project with data: ${project.toJson()}');

    final response = await http.post(
      Uri.parse('$databaseUrl/db/time-tracking:main/tables/projects/data'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(project.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Failed to create project: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteProject(String projectId) async {
    final response = await http.delete(
      Uri.parse(
          '$databaseUrl/db/time-tracking:main/tables/projects/data/$projectId'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete project: ${response.statusCode} - ${response.body}');
    }
  }
}
