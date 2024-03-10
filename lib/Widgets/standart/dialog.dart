import 'package:flutter/material.dart';

Future<dynamic> scanDialog(BuildContext context, List<Widget> widgets) {
  return showDialog(
      context: context,
      builder: (context) {
        return new Container(
          color: Colors.black.withOpacity(0.7),
          padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
          child: Card(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(children: widgets),
            ),
          ),
        );
      });
}
