class TaskExec {
  final int? id;
  final int? taskId;
  final DateTime? date;
  DateTime? startTime;
  DateTime? endTime;
  Duration? duration;

  TaskExec(
      {this.id,
      this.taskId,
      this.date,
      this.startTime,
      this.endTime,
      this.duration});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'planned_date': date?.toString(),
      'start_time': startTime?.toString(),
      'end_time': endTime?.toString(),
      'duration_seconds': duration?.inSeconds,
    };
  }

  @override
  String toString() {
    return 'TaskExec{id: $id, task_id: $taskId}';
  }
}
