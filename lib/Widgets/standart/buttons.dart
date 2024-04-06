import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';

FloatingActionButton moreaEditActionbutton({required Function route, Key? key}) {
  return new FloatingActionButton(
    key: key == null ? null : key,
    elevation: 1.0,
    child: new Icon(Icons.edit),
    backgroundColor: MoreaColors.violett,
    onPressed: () => route(),
    shape: CircleBorder(side: BorderSide(color: Colors.white)),
  );
}

Widget moreaRaisedButton(String text, void Function() action){
  return ElevatedButton(
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(MoreaColors.violett),
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))))),
    onPressed: action,
    child: Text(
      text,
      style: MoreaTextStyle.raisedButton,
    ),
  );
}

Widget moreaRaisedIconButton(String text, void Function() action, Icon icon) {
  return ElevatedButton.icon(
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(MoreaColors.violett),
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))))),
    onPressed: action,
    label: Text(
      text,
      style: MoreaTextStyle.raisedButton,
    ),
    icon: icon,
  );
}

Widget moreaFlatRedButton(String text, void Function() action) {
  return TextButton(
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            side: BorderSide(color: Colors.red)))),
    onPressed: action,
    child: Text(
      text,
      style: MoreaTextStyle.warningButton,
    ),
  );
}

Widget moreaFlatIconButton(String text, void Function() action, Icon icon) {
  return TextButton.icon(
    onPressed: action,
    icon: icon,
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        text,
        style: MoreaTextStyle.flatButton,
      ),
    ),
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            side: BorderSide(color: MoreaColors.violett)))),
  );
}

Widget moreaFlatButton(String text, void Function() action) {
  return TextButton(
    onPressed: action,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        text,
        style: MoreaTextStyle.flatButton,
      ),
    ),
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            side: BorderSide(color: MoreaColors.violett)))),
  );
}
