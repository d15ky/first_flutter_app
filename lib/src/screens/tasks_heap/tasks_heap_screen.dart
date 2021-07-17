import 'package:flutter/material.dart';

class TasksHeapList extends StatelessWidget {
  const TasksHeapList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TasksHeapScreen extends StatelessWidget {
  const TasksHeapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks heap"),
      ),
      body: SafeArea(child: TasksHeapList()),
    );
  }
}
