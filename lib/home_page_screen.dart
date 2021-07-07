import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'models/task.dart';
import 'add_task_screen.dart';
// import 'src/database_connector.dart';
import 'package:provider/provider.dart';
import 'tasks_data_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    List<Task> _tasks = [];

    Widget _listViewTasksUpdatable({int flex = 1}) {
      return Expanded(
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
        flex: flex,
      );
    }

    List<Widget> _showLoadingOrData(AsyncSnapshot<List<Task>> snapshot) {
      if (snapshot.hasData) {
        _tasks = snapshot.data!;
        return [
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

    // Future<List<Task>> _tasksFuture = DatabaseConnector().getTasks();

    return Consumer<TasksListData>(
      builder: (context, tasksData, _) => FutureBuilder<List<Task>>(
        future: tasksData.getTasks(),
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          List<Widget> children = _showLoadingOrData(snapshot);
          return Scaffold(
              appBar: AppBar(title: Text(widget.title), actions: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddTaskScreen()));
                  },
                ),
              ]),
              body: SafeArea(
                child: Column(
                  children: children,
                ),
              ));
        },
      ),
    );
  }

  Widget _playTaskButton() {
    return IconButton(
        onPressed: () {},
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
                        Provider.of<TasksListData>(context)
                            .deleteTask(task.id!);
                        // DatabaseConnector().deleteTask();
                        Navigator.of(context).pop();
                        // setState(() {});
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
            _playTaskButton(),
            _stopTaskButton(),
            _infoTaskButton(task),
            _deleteTaskButton(task),
          ],
        ),
      ],
    );
  }
}
