/* 
  The elten-pend widget requests the User when he is a parent and he has no childs pend to him
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/Event/event_Widget.dart';

Widget requestPrompttoParent() {
  return new Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Center(
          child: Container(
              padding: EdgeInsets.all(15),
              child: Text(
                message,
                style: new TextStyle(fontSize: 20),
              ))),
    ],
  );
}

final String message =
    "Wir können dir noch keine Inhalte anzeigen, da dein Account noch nicht mit deinem Kind verbunden ist. In deinem Profil kannst du deine Kinder verwalten.";
