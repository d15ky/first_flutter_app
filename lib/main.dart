import 'package:flutter/material.dart';
import 'home_page_screen.dart';
import 'package:provider/provider.dart';
import 'tasks_data_provider.dart';
// import 'day_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
          create: (context) => TasksListData(),
          child: MyHomePage(title: 'Task List OM')),
    );
  }
}
