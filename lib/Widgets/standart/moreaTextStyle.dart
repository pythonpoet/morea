import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class MoreaTextStyle {
  static TextStyle title = TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: Color(0xff7a62ff),
      letterSpacing: 0.25,
      shadows: <Shadow>[
        Shadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 3),
            blurRadius: 6),
      ]);
  static TextStyle lable = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0.15);
  static TextStyle normal = TextStyle(
      color: Colors.black,
      fontSize: 16,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w500);
  static TextStyle htmlList = TextStyle(
      fontSize: 13,
      color: Colors.black,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w500,);
  static TextStyle textField =
      TextStyle(fontSize: 16, letterSpacing: 0.15, fontWeight: FontWeight.w500);

  static TextStyle caption = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      letterSpacing: 0.4);

  static TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    letterSpacing: 0.25,
  );

  static TextStyle sender =
      TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.normal, letterSpacing: 1.5);

  static TextStyle raisedButton = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white);

  static TextStyle flatButton = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w700, color: MoreaColors.violett);

  static TextStyle warningButton = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red);

  static TextStyle warningTitle =
      TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.red);

  static TextStyle link = TextStyle(
      fontSize: 16,
      color: MoreaColors.violett,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w700);
}
