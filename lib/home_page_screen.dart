import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_list_1/src/database_connector.dart';
import 'models/task.dart';
import 'add_task_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbCon = DatabaseConnector();
  Task? _currentTask;

  @override
  Widget build(BuildContext context) {
    List<Task> _tasks = [];

    Widget _currentTaskShown({int flex = 1}) {
      if (_currentTask == null) return Container();
      return Column(
        children: [
          Text(_currentTask!.name!),
          Text(_currentTask!.desc!),
          Text("Timer will be here"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow),
              Icon(Icons.stop),
            ],
          )
        ],
      );
    }

    Widget _listViewTasksUpdatable({int flex = 1}) {
      return Expanded(
        flex: flex,
        child: Container(
          decoration: BoxDecoration(border: Border.all()),
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              return;
            },
            child: ListView(
              children: _tasks.map(_buildTaskTile).toList(),
            ),
          ),
        ),
      );
    }

    List<Widget> _showLoadingOrData(AsyncSnapshot<List<Task>> snapshot) {
      if (snapshot.hasData) {
        _tasks = snapshot.data!;
        return [
          _currentTaskShown(flex: 1),
          _listViewTasksUpdatable(flex: 5),
        ];
      }
      return const <Widget>[
        Center(
            child: SizedBox(
          child: CircularProgressIndicator(),
          width: 60,
          height: 60,
        )),
      ];
    }

    return FutureBuilder<List<Task>>(
      future: dbCon.getTasks(),
      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
        List<Widget> children = _showLoadingOrData(snapshot);
        return Scaffold(
            appBar: AppBar(title: Text(widget.title), actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  final added = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddTaskScreen()));
                  if (added == true) {
                    setState(() {});
                  }
                },
              ),
            ]),
            body: SafeArea(
              child: Column(
                children: children,
              ),
            ));
      },
    );
  }

  Widget _playTaskButton(Task task) {
    return IconButton(
        onPressed: () {
          _currentTask = task;
          setState(() {});
        },
        icon: Icon(Icons.play_circle_outlined, color: Colors.green));
  }

  Widget _stopTaskButton() {
    return IconButton(
        onPressed: () {},
        icon: Icon(Icons.stop_circle_outlined, color: Colors.red[300]));
  }

  Widget _infoTaskButton(Task task) {
    return IconButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChangeTaskScreen(task: task)));
        },
        icon: Icon(Icons.info_outline, color: Colors.blue));
  }

  Widget _deleteTaskButton(Task task) {
    return IconButton(
        onPressed: () {
          showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Are you sure you want to delete"),
                      Text("\"${task.name}\"?"),
                    ],
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text(
                        "Yes",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        dbCon.deleteTask(task.id!);
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      isDestructiveAction: true,
                      isDefaultAction: true,
                    ),
                    CupertinoDialogAction(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
              barrierDismissible: true);
        },
        icon: Icon(Icons.delete_forever, color: Colors.red));
  }

  Widget _buildTaskTile(Task task) {
    return ExpansionTile(
      key: Key("homePageTask:${task.id}"),
      title: Text(task.name!),
      children: [
        Text(task.desc!),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playTaskButton(task),
            _stopTaskButton(),
            _infoTaskButton(task),
            _deleteTaskButton(task),
          ],
        ),
      ],
    );
  }
}
