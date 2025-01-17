import 'xata_metadata.dart';

class Project {
  final String id;
  final String name;
  final double hourlyRate;
  final XataMetadata  xata;

  Project({
    required this.id,
    required this.name,
    required this.hourlyRate,
    required this.xata,
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
    if (json['xata'] == null) {
      throw Exception("Project JSON missing 'xata' field.");
    }
    return Project(
      id: json['id'],
      name: json['name'],
      hourlyRate: (json['hourly_rate'] is int)
          ? (json['hourly_rate'] as int).toDouble()
          : json['hourly_rate'].toDouble(),
      xata: XataMetadata.fromJson(json['xata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hourly_rate': hourlyRate,
      'id': id,
    };
  }
}
