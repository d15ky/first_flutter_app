import '../models/task.dart';

const MaxTaskNameLength = 50;
const MaxTaskDescLength = 10000;

// class Task {
//   final int id;
//   final String name;
//   final String desc;
//   final Duration estimate;
//   final DateTime date;
//   DateTime? startTime;
//   DateTime? endTime;

//   Task(this.id, this.name, this.desc, this.estimate, this.date, this.startTime,
//       this.endTime);
// }

final tasks = [
  Task(
      id: 0,
      name: "Поснідати",
      desc: "З'їсти там овочей, риби, хліба",
      estimate: Duration(hours: 1),
      date: DateTime.utc(2021, 06, 30, 18, 30)),
  Task(
      id: 1,
      name: "Погуляти",
      desc: "Можна по парку КПІ, можна ще кудись сходити",
      estimate: Duration(hours: 1, minutes: 30),
      date: DateTime.utc(2021, 06, 30, 20, 00),
      startTime: DateTime.utc(2021, 06, 30, 20, 00),
      endTime: DateTime.utc(2021, 06, 30, 21, 30)),
  Task(
      id: 3,
      name: "Подивитись туторіали",
      desc: "Флаттер чи реакт чи щось нормальне",
      estimate: Duration(hours: 3),
      date: DateTime.utc(2021, 06, 30, 22, 30)),
  Task(
      id: 4,
      name: "Зарядку зробити",
      desc: "Розтяжка, біг, анжуманя",
      estimate: Duration(hours: 1),
      date: DateTime.utc(2021, 07, 01, 09, 30)),
  Task(
      id: 5,
      name: "Подивитись фильм",
      desc: "Ну цей, про В'єтнам",
      estimate: Duration(hours: 4),
      date: DateTime.utc(2021, 07, 01, 18, 30)),
];
