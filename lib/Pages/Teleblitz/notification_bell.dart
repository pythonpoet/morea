import 'package:flutter/material.dart';

class NotificationBell extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotificationBellState();
  }
}

class _NotificationBellState extends State<NotificationBell> {
  bool unRead = true;

  @override
  Widget build(BuildContext context) {
    if (unRead) {
      return Padding(
        child: IconButton(
            icon: Stack(
              children: <Widget>[
                Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                Positioned(
                  child: Icon(Icons.brightness_1, color: Colors.red, size: 10),
                  left: 12,
                  bottom: 13,
                )
              ],
            ),
            onPressed: () {
              setState(() {
                unRead = !(unRead);
              });
            }),
        padding: EdgeInsets.all(5),
      );
    } else {
      return Padding(child: IconButton(
          icon: Icon(
            Icons.notifications,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              unRead = !(unRead);
            });
          }),
        padding: EdgeInsets.all(5),
      );
    }
  }

  void activateNotification(){
    unRead = true;
  }

  void deactivateNotification(){
    unRead = false;
  }
}
