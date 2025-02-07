import 'package:timesheettracker/models/client.dart';

class Project {
  final String id;
  final String name;
  final double hourlyRate;
  final DateTime createdAt;
  final Client client;

  Project({
    required this.id,
    required this.name,
    required this.hourlyRate,
    required this.createdAt,
    required this.client,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw Exception("Project JSON missing 'id' field.");
    }
    if (json['name'] == null) {
      throw Exception("Project JSON missing 'name' field.");
    }
    if (json['hourly_rate'] == null) {
      throw Exception("Project JSON missing 'hourly_rate' field.");
    }
    if (json['created_at'] == null) {
      throw Exception("Project JSON missing 'created_at' field.");
    }

    return Project(
      id: json['id'].toString(), // Convert to string since Supabase returns int
      name: json['name'],
      hourlyRate: (json['hourly_rate'] is int)
          ? (json['hourly_rate'] as int).toDouble()
          : json['hourly_rate'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      client: Client.fromJson(json['client']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hourly_rate': hourlyRate,
      'client_id': client.id,
    };
  }
}
