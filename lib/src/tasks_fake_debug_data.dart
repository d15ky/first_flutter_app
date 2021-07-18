import 'package:task_list_1/models/task.dart';
import 'package:task_list_1/models/task_execution.dart';

final tasks = [
  Task(
    id: 0,
    name: "Поснідати",
    desc: "З'їсти там овочей, риби, хліба",
    estimate: Duration(hours: 1),
  ),
  Task(
    id: 1,
    name: "Погуляти",
    desc: "Можна по парку КПІ, можна ще кудись сходити",
    estimate: Duration(hours: 1, minutes: 30),
    // date: DateTime.utc(2021, 06, 30, 20, 00),
    // startTime: DateTime.utc(2021, 06, 30, 20, 00),
    // endTime: DateTime.utc(2021, 06, 30, 21, 30),
  ),
  Task(
    id: 3,
    name: "Подивитись туторіали",
    desc: "Флаттер чи реакт чи щось нормальне",
    estimate: Duration(hours: 3),
  ),
  Task(
    id: 4,
    name: "Зарядку зробити",
    desc: "Розтяжка, біг, анжуманя",
    estimate: Duration(hours: 1),
  ),
  Task(
    id: 5,
    name: "Подивитись фильм",
    desc: "Ну цей, про В'єтнам",
    estimate: Duration(hours: 4),
  ),
];

final taskExecutions = [
  TaskExec(
    id: 0,
    taskId: 0,
    date: DateTime.now().add(Duration(hours: 3)),
  ),
  TaskExec(
    id: 1,
    taskId: 1,
    date: DateTime.now().add(Duration(hours: 4)),
  ),
  TaskExec(
    id: 2,
    taskId: 2,
    date: DateTime.now().add(Duration(hours: 5)),
  ),
  TaskExec(
    id: 3,
    taskId: 3,
    date: DateTime.now().add(Duration(hours: 6)),
  ),
  TaskExec(
    id: 4,
    taskId: 4,
    date: DateTime.now().add(Duration(hours: 7)),
  ),
  TaskExec(
    id: 5,
    taskId: 5,
    date: DateTime.now().add(Duration(hours: 8)),
  ),
];
