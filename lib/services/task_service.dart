import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/auth_service.dart';

class TaskService {
  final SupabaseClient _supabase = Supabase.instance.client;

  TaskService._();

  static Future<TaskService> create() async {
    return TaskService._();
  }

  Future<Task> createTask(Task task) async {
    try {
      final user = AuthService.getCurrentUser();
      final response = await _supabase
          .from('tasks')
          .insert(task.toJson()..['user_id'] = user.id)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }
}