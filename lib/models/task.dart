class Task {
  final String? id;
  final String timeEntryId;
  final String taskName;
  final String? notes;
  final String? userId;

  Task({
    this.id,
    required this.timeEntryId,
    required this.taskName,
    this.notes,
    this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString(),
      timeEntryId: json['time_entry_id']?.toString() ?? '',
      taskName: json['task_name'] ?? '',
      notes: json['notes'],
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_entry_id': timeEntryId,
      'task_name': taskName,
      'notes': notes,
      'user_id': userId,
    };
  }
}