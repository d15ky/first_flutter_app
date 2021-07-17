import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tasks_list_view.dart';
import 'timer_view.dart';

import 'providers/tasks_data_provider.dart';
import 'providers/timer_provider.dart';
import 'package:task_list_1/src/screens/change_task/change_task_screen.dart';

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksDataProvider = TasksViewData();
    final timerProvider = TimerViewData();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: tasksDataProvider,
        ),
        ChangeNotifierProvider.value(value: timerProvider)
      ],
      child: Scaffold(
          appBar: AppBar(title: Text(title), actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider.value(
                            value: tasksDataProvider, child: AddTaskScreen())));
              },
            ),
          ]),
          body: SafeArea(
            child: Column(
              children: [
                Consumer<TimerViewData>(
                    builder: (context, data, child) => TimerView()),
                Consumer<TasksViewData>(
                    builder: (context, data, child) => TaskListView(flex: 5)),
              ],
            ),
          )),
    );
  }
}
