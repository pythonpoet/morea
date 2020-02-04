import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class BlockedByAppVersion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
        color: MoreaColors.orange,
        child: Center(
          child: Container(
            color: MoreaColors.orange,
            padding: EdgeInsets.all(15),
            child: Text(
              "Diese Version wird nicht mehr unterstützt. Update diese App um Pfadi Morea wieder nützen können. Vielen Dank für dein Verständniss.",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }
}
