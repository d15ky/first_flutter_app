import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_list_1/src/database_connector.dart';
import 'models/task.dart';
import 'add_task_screen.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _dbCon = DatabaseConnector();
  final _stopWatchTimer = StopWatchTimer();
  Task? _currentTask;

  @override
  Widget build(BuildContext context) {
    List<Task> _tasks = [];

    Widget _timer() {
      Widget _timerPlayButton() => IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              _stopWatchTimer.onExecute.add(StopWatchExecute.start);
              setState(() {});
            },
          );

      Widget _timerPauseButton() => IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {
              _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
              setState(() {});
            },
          );

      Widget _timerPlayPauseButton() {
        if (_stopWatchTimer.isRunning) return _timerPauseButton();
        return _timerPlayButton();
      }

      Widget _timerStopButton() => IconButton(
            icon: Icon(Icons.stop),
            onPressed: () {
              if (_stopWatchTimer.isRunning)
                _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
              _currentTask = null;
              setState(() {});
            },
          );

      return StreamBuilder<int>(
        stream: _stopWatchTimer.rawTime,
        initialData: _stopWatchTimer.rawTime.value,
        builder: (context, snapshot) {
          final value = snapshot.data!;
          final displayTime =
              StopWatchTimer.getDisplayTime(value, milliSecond: false);
          return Column(children: [
            Text(displayTime),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timerPlayPauseButton(),
                _timerStopButton(),
              ],
            )
          ]);
        },
      );
    }

    Widget _currentTaskShown({int flex = 1}) {
      if (_currentTask == null) return Container();
      return Column(
        children: [
          Text(_currentTask!.name!),
          Text(_currentTask!.desc!),
          _timer(),
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
      future: _dbCon.getTasks(),
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

  Widget _playPauseTaskButton(Task task) {
    Widget _playTaskButton() {
      return IconButton(
          onPressed: () {
            _currentTask = task;
            _stopWatchTimer.onExecute.add(StopWatchExecute.start);
            setState(() {});
          },
          icon: Icon(Icons.play_circle_outlined, color: Colors.green));
    }

    Widget _pauseTaskButton() {
      return IconButton(
          onPressed: () {
            _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
            setState(() {});
          },
          icon: Icon(Icons.pause_circle_outlined, color: Colors.amber));
    }

    if (_stopWatchTimer.isRunning) return _pauseTaskButton();
    return _playTaskButton();
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
                        _dbCon.deleteTask(task.id!);
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
      onExpansionChanged: (isOpening) {
        if (!isOpening) return;
        _currentTask = task;
        setState(() {});
      },
      children: [
        Text(task.desc!),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playPauseTaskButton(task),
            // _stopTaskButton(),
            _infoTaskButton(task),
            _deleteTaskButton(task),
          ],
        ),
      ],
    );
  }
}
