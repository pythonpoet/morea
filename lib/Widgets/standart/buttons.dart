import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

Widget moreaEditActionbutton(Function route) {
  return new FloatingActionButton(
    elevation: 1.0,
    child: new Icon(Icons.edit),
    backgroundColor: MoreaColors.violett,
    onPressed: () => route(),
    shape: CircleBorder(side: BorderSide(color: Colors.white)),
  );
}

Widget moreaButton(String text, Function action) {
  return new RaisedButton(
    color: MoreaColors.violett,
    onPressed: action,
    child: Text(
      text,
      style: TextStyle(color: Colors.white),
    ),
  );
}
