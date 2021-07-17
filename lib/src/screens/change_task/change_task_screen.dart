import 'package:task_list_1/models/task.dart';
import 'package:task_list_1/src/database/database_connector.dart';
import 'package:task_list_1/src/custom_lib/timer_picker_formfield.dart';
import 'package:task_list_1/src/screens/home_page/providers/tasks_data_provider.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class TimerFormatter extends DurationFormat {
  @override
  String format(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Duration parse(String string) {
    int hours = 0;
    int minutes = 0;
    List<String> parts = string.split(':');
    if (parts.length > 1) {
      hours = int.parse(parts[parts.length - 2]);
    }
    if (parts.length > 0) {
      minutes = int.parse(parts[parts.length - 1]);
    }
    return Duration(hours: hours, minutes: minutes);
  }
}

class ChangeTaskForm extends StatefulWidget {
  final Task? task;
  final bool isCreate;

  const ChangeTaskForm({
    Key? key,
    this.task,
    bool createForm = false,
  })  : this.isCreate = createForm,
        super(key: key);

  @override
  _ChangeTaskFormState createState() => _ChangeTaskFormState();
}

class _ChangeTaskFormState extends State<ChangeTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _dbCon = DatabaseConnector();

  String? _name;
  String? _desc;
  Duration? _est;
  Map<String, DateTime?> _dates = {};
  final _requiredDateTimeFields = ["date"];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _name = widget.task?.name;
      _desc = widget.task?.desc;
      _est = widget.task?.estimate;
      _dates["date"] = widget.task?.date;
      _dates["start_time"] = widget.task?.startTime;
      _dates["end_time"] = widget.task?.endTime;
    }
  }

  Task? getTask() {
    if (_name == null ||
        _desc == null ||
        _est == null ||
        _dates["date"] == null) {
      print(_name);
      print(_desc);
      print(_est);
      print(_dates["date"]);
      return null;
    }
    return Task(
        id: widget.task?.id,
        name: _name,
        desc: _desc,
        estimate: _est,
        date: _dates["date"],
        startTime: _dates["start_time"],
        endTime: _dates["end_time"]);
  }

  Widget buildName() {
    return TextFormField(
      initialValue: _name,
      decoration: const InputDecoration(
          hintText: "A short title for your task", labelText: "Name"),
      validator: (String? value) {
        if (value == null || value.isEmpty)
          return "Name is required";
        else if (value.length > MaxTaskNameLength)
          return "Name should be shorter than $MaxTaskNameLength characters";
      },
      onSaved: (String? value) {
        _name = value;
      },
    );
  }

  Widget buildDesc() {
    return TextFormField(
      initialValue: _desc,
      maxLines: null,
      decoration: const InputDecoration(
          hintText: "Here you can write a long description",
          labelText: "Description"),
      validator: (String? value) {
        if (value != null && value.length > MaxTaskDescLength)
          return "Description should be shorter than $MaxTaskDescLength characters";
      },
      onSaved: (String? value) {
        _desc = value;
      },
    );
  }

  Widget buildEstimate() {
    Duration? tempValue;
    Duration? value = _est;

    return TimerField(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: "Estimated duration",
        labelStyle: TextStyle(fontSize: 16),
      ),
      formatter: TimerFormatter(),
      validator: (Duration? value) {
        if (value == null) return "Estimated time is required";
        if (value == Duration.zero)
          return "Estimated time should be 1 minute or more";
        // check format
      },
      style: TextStyle(fontSize: 50),
      textAlign: TextAlign.center,
      onSaved: (Duration? value) {
        _est = value;
      },
      onShowPicker: (context, currentValue) async {
        await showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return BottomSheet(
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: CupertinoTimerPicker(
                          initialTimerDuration: currentValue ?? Duration.zero,
                          mode: CupertinoTimerPickerMode.hm,
                          minuteInterval: 1, // might be 5
                          onTimerDurationChanged: (Duration duration) {
                            tempValue = duration;
                          }),
                    ),
                    TextButton(
                        onPressed: () {
                          value = tempValue ?? value ?? Duration.zero;
                          Navigator.pop(context);
                        },
                        child: Text('Ok')),
                  ],
                ),
                onClosing: () {},
              );
            });
        setState(() {});
        return value;
      },
    );
  }

  Widget buildDate(String name, String dateDesc) {
    final format = DateFormat("yyyy-MM-dd HH:mm");
    DateTime? tempValue;
    DateTime? value = _dates[name];

    return DateTimeField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: dateDesc,
      ),
      validator: (DateTime? value) {
        if (value == null && _requiredDateTimeFields.contains(name))
          return "$dateDesc is required";
        // check format
      },
      format: format,
      onShowPicker: (context, currentValue) async {
        await showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return BottomSheet(
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: CupertinoDatePicker(
                        initialDateTime: currentValue,
                        onDateTimeChanged: (DateTime date) {
                          tempValue = date;
                        },
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          value = tempValue ?? DateTime.now();
                          Navigator.pop(context);
                        },
                        child: Text('Ok')),
                  ],
                ),
                onClosing: () {},
              );
            });
        setState(() {});
        return value;
      },
      textAlign: TextAlign.center,
      onSaved: (DateTime? value) {
        _dates[name] = value;
      },
    );
  }

  void _submitAction() async {
    if (!_formKey.currentState!.validate()) return null;
    _formKey.currentState!.save();

    final _task = getTask();
    if (_task != null) {
      if (widget.isCreate)
        await _dbCon.insertTask(_task);
      else {
        await _dbCon.updateTask(_task);
      }
      Navigator.of(context).pop();
      Provider.of<TasksViewData>(context, listen: false).updateListeners();
    } else {
      return null;
    }
  }

  List<Widget> _buildFormFields() {
    final _startTimeField =
        widget.isCreate ? Container() : buildDate("start_time", "Start time");
    final _endTimeField =
        widget.isCreate ? Container() : buildDate("end_time", "End time");
    return [
      Expanded(
        child: Container(),
        flex: 3,
      ),
      buildName(),
      buildDesc(),
      buildEstimate(),
      buildDate("date", "Date"),
      _startTimeField,
      _endTimeField,
      Expanded(
        child: Container(),
      ),
      ElevatedButton(
          onPressed: _submitAction,
          child: Text("Submit", style: TextStyle(fontSize: 18))),
      Expanded(
        child: Container(),
        flex: 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: LayoutBuilder(builder: (context, viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: _buildFormFields(),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task"),
      ),
      body: SafeArea(
          child: ChangeTaskForm(
        createForm: true,
      )),
    );
  }
}

class ChangeTaskScreen extends StatelessWidget {
  final Task task;

  const ChangeTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [Text("Change Task"), Text(task.name ?? "null")],
        ),
      ),
      body: SafeArea(
          child: ChangeTaskForm(
        task: task,
      )),
    );
  }
}
