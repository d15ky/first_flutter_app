const MaxTaskNameLength = 50;
const MaxTaskDescLength = 10000;

class Task {
  final int? id;
  final String? name;
  final String? desc;
  final Duration? estimate;
  final DateTime? date;
  DateTime? startTime;
  DateTime? endTime;

  Task(
      {this.id,
      this.name,
      this.desc,
      this.estimate,
      this.date,
      this.startTime,
      this.endTime});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'desc': this.desc,
      'estimate_seconds': this.estimate?.inSeconds,
      'planned_date': date?.toString(),
      'start_time': startTime?.toString(),
      'end_time': endTime?.toString(),
    };
  }

  @override
  String toString() {
    return 'Task{id: $id, name: $name}';
  }
}
