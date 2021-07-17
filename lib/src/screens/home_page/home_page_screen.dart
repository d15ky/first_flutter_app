import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tasks_list_view.dart';
import 'timer_view.dart';

import 'package:task_list_1/src/database/tasks_data_provider.dart';
import 'package:task_list_1/src/screens/change_task/change_task_screen.dart';

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationProvider = TasksViewData();
    return ChangeNotifierProvider(
      create: (_) => notificationProvider,
      child: Scaffold(
          appBar: AppBar(title: Text(title), actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final added = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddTaskScreen()));
                if (added == true) {
                  notificationProvider.updateListeners();
                  // PROVIDER NOTIFY
                  // setState(() {});
                }
              },
            ),
          ]),
          body: SafeArea(
            child: Column(
              children: [
                Consumer<TasksViewData>(
                    builder: (context, data, child) => TimerView()),
                Consumer<TasksViewData>(
                    builder: (context, data, child) => TaskListView(flex: 5)),
              ],
            ),
          )),
    );
  }
}
