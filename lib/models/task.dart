const MaxTaskNameLength = 50;
const MaxTaskDescLength = 10000;

class Task {
  final int? id;
  final String? name;
  final String? desc;
  final Duration? estimate;

  Task({this.id, this.name, this.desc, this.estimate});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'estimate_seconds': estimate?.inSeconds,
    };
  }

  @override
  String toString() {
    return 'Task{id: $id, name: $name}';
  }
}
