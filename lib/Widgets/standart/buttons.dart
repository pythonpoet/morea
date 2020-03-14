import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';

Widget moreaEditActionbutton({@required Function route, Key key}) {
  return new FloatingActionButton(
    key: key == null ? null : key,
    elevation: 1.0,
    child: new Icon(Icons.edit),
    backgroundColor: MoreaColors.violett,
    onPressed: () => route(),
    shape: CircleBorder(side: BorderSide(color: Colors.white)),
  );
}

Widget moreaRaisedButton(String text, Function action) {
  return RaisedButton(
    color: MoreaColors.violett,
    onPressed: action,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
    child: Text(
      text,
      style: MoreaTextStyle.raisedButton,
    ),
  );
}

Widget moreaRaisedIconButton(String text, Function action, Icon icon) {
  return RaisedButton.icon(
    color: MoreaColors.violett,
    onPressed: action,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
    label: Text(
      text,
      style: MoreaTextStyle.raisedButton,
    ),
    icon: icon,
  );
}

Widget moreaFlatRedButton(String text, Function action) {
  return FlatButton(
    color: Colors.transparent,
    onPressed: action,
    shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(Radius.circular(5))),
    child: Text(
      text,
      style: MoreaTextStyle.warningButton,
    ),
  );
}

Widget moreaFlatIconButton(String text, Function action, Icon icon) {
  return FlatButton.icon(
    onPressed: action,
    icon: icon,
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        text,
        style: MoreaTextStyle.flatButton,
      ),
    ),
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        side: BorderSide(color: MoreaColors.violett)),
  );
}

Widget moreaFlatButton(String text, Function action) {
  return FlatButton(
    onPressed: action,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        text,
        style: MoreaTextStyle.flatButton,
      ),
    ),
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        side: BorderSide(color: MoreaColors.violett)),
  );
}

