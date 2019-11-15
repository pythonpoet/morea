import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

Widget moreaEditActionbutton(Function route){
  return new FloatingActionButton(
                    elevation: 1.0,
                    child: new Icon(Icons.edit),
                    backgroundColor: MoreaColors.violett,
                    onPressed: () => route()
                            );
}