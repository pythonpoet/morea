import 'package:flutter/material.dart';

/*
This Widget is ment to restart the app.
***Usage**
type: "RestartWidget.restartApp(context)" to restart the app from anywhere

ref: https://stackoverflow.com/questions/50115311/flutter-how-to-force-an-application-restart-in-production-mode
Date: 05.02.2020
Author: David Wild
*/
class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});
  final Widget child;
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  State<StatefulWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}
