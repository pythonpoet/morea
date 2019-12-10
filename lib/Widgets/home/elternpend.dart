/* 
  The elten-pend widget requests the User when he is a parent and he has no childs pend to him
*/

import 'package:flutter/cupertino.dart';
import 'package:morea/Widgets/standart/buttons.dart';

Widget requestPrompttoParent(Function createAccount, Function pendAccount){
  return new Column(
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(message),
      Row(
        children: <Widget>[
          moreaButton("Ein Account erstellen", createAccount),
          moreaButton("Mit einem Account verbinden", pendAccount)
        ],
      )
    ],
  );
}

final String message = "Wir können dir noch keine Inhalte anzeigen, da dein Account noch nicht mit deinem Kind verbunden ist.";