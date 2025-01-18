import '../models/project.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectResponse {
  final List<Project> projects;

  ProjectResponse({
    required this.projects,
  });

  factory ProjectResponse.fromJson(List<dynamic> json) {
    return ProjectResponse(
      projects: json.map((record) => Project.fromJson(record)).toList(),
    );
  }
}

class ProjectService {
  final supabase = Supabase.instance.client;

  ProjectService._();

  static Future<ProjectService> create() async {
    return ProjectService._();
  }

  Future<ProjectResponse> getProjects() async {
    try {
      final response = await supabase
          .from('projects')
          .select('id, name, hourly_rate, created_at')
          .limit(500);

      return ProjectResponse.fromJson(response as List);
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  Future<void> createProject(Project project) async {
    try {
      await supabase.from('projects').insert({
        'name': project.name,
        'hourly_rate': project.hourlyRate,
      });
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await supabase.from('projects').delete().eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }
}
