import 'package:flutter/material.dart';

Widget simpleMoreaLoadingIndicator() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Expanded(
        child: new Text('Loading...'),
      ),
      Expanded(child: new CircularProgressIndicator())
    ],
  );
}
