import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget moreaLoadingIndicator(){
  return Container(
            child: Center(
                child: Container(
              padding: EdgeInsets.all(120),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Loading...'),
                  ),
                  Expanded(child: new CircularProgressIndicator())
                ],
              ),
            )),
          );
}