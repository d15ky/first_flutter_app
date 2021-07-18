import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_list_1/models/task_execution.dart';
import '../home_page/providers/tasks_data_provider.dart';

class TasksHeapList extends StatelessWidget {
  const TasksHeapList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksViewData = Provider.of<TasksViewData>(context, listen: false);

    Widget _buildTaskTile(TaskExec task) {
      return Container(
        decoration: BoxDecoration(color: Colors.amber),
      );
    }

    Widget _showLoadingOrData(AsyncSnapshot<List<TaskExec>> snapshot) {
      if (snapshot.hasData) {
        final _tasksExecs = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            tasksViewData.updateListeners();
            return;
          },
          child: Column(
            children: [
              Flexible(
                child: ListView(
                  children: _tasksExecs.map(_buildTaskTile).toList(),
                ),
              ),
            ],
          ),
        );
      }
      return const Center(
          child: SizedBox(
        child: CircularProgressIndicator(),
        width: 60,
        height: 60,
      ));
    }

    return FutureBuilder<List<TaskExec>>(
        future: TasksViewData.dbCon.getTasksExecutions(),
        builder:
            (BuildContext context, AsyncSnapshot<List<TaskExec>> snapshot) {
          return _showLoadingOrData(snapshot);
        });
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
