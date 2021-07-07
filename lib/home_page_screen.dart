import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'src/tasks.dart';
import 'models/task.dart';
import 'add_task_screen.dart';
import 'src/database_connector.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // Future<List<Task>> _tasks = Future<List<Task>>.delayed(
    //   const Duration(seconds: 5),
    //   () => tasks,
    // );
    Future<List<Task>> _tasksFuture = DatabaseConnector().getTasks();
    List<Task> _tasks = [];

    return FutureBuilder<List<Task>>(
      future: _tasksFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          _tasks = snapshot.data!;
          children = [
            Expanded(
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
              flex: 5,
            ),
          ];
        } else {
          children = const <Widget>[
            Center(
                child: SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            )),
          ];
        }
        return Scaffold(
            appBar: AppBar(title: Text(widget.title), actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddTaskScreen()));
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

  Widget _buildTaskTile(Task task) {
    void _checkDone() {
      setState(() {
        if (task.endTime == null) {
          task.endTime = DateTime.now();
        } else {
          task.endTime = null;
        }
      });
    }

    return ExpansionTile(
      key: Key("homePageTask:${task.id}"),
      title: Text(task.name!),
      children: [
        Text(task.desc!),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.play_circle_outlined, color: Colors.green)),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.stop_circle_outlined, color: Colors.red[300])),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangeTaskScreen(task: task)));
                },
                icon: Icon(Icons.info_outline, color: Colors.blue)),
            IconButton(
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
                                DatabaseConnector().deleteTask(task.id!);
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
                icon: Icon(Icons.delete_forever, color: Colors.red)),
          ],
        ),
      ],
    );
  }
}
