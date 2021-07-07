import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_week_view/flutter_week_view.dart';

class DayView extends StatelessWidget {
  const DayView({Key? key}) : super(key: key);

  static const _startHour = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.amber),
        child: Stack(
          children: [
            ListView.builder(
              itemBuilder: _listBuilder,
              // physics: ClampingScrollPhysics(),
              itemCount: 49,
              controller: ScrollController(
                  initialScrollOffset: 10 * 50, keepScrollOffset: true),
            ),
          ],
        ));
  }

  Widget _listBuilder(BuildContext context, int index) {
    final _startTime = DateTime(1999, 12, 12, _startHour, 30 * index);
    return _timeRow(_startTime);
  }

  Widget _timeRow(DateTime startTime) {
    final hourString = DateFormat('HH:mm').format(startTime);
    final double elementHeight = 50;
    final timeRow = Row(
      children: [
        Expanded(
          child: Container(
              child: Center(
                  child: Text(
                hourString,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              height: elementHeight),
          flex: 1,
        ),
        Expanded(
          child: Divider(),
          flex: 5,
        )
      ],
    );

    var stackChildren = <Widget>[
      Container(
        child: Row(
          children: [
            Expanded(flex: 1, child: Container()),
            Expanded(flex: 5, child: Container())
          ],
        ),
        // decoration: BoxDecoration(color: Colors.blueGrey),
        height: elementHeight,
      ),
      // timeRow,
    ];
    if (startTime.minute == 0) {
      stackChildren.add(timeRow);
    }
    return Stack(
      // fit: StackFit.passthrough,
      children: stackChildren,
    );
  }
}
