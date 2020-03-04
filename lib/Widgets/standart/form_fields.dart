import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';

class MoreaSingleLineTextField extends StatelessWidget {
  MoreaSingleLineTextField({
    Key key,
    @required this.controller,
    @required this.validator,
    @required this.keyboardType,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        key: key,
        controller: controller,
        maxLines: 1,
        keyboardType: keyboardType,
        style: MoreaTextStyle.textField,
        cursorColor: MoreaColors.violett,
        decoration: InputDecoration(
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MoreaColors.violett)),
        ),
        validator: validator);
  }
}
