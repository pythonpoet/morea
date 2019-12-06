import 'package:flutter/material.dart';

import 'package:morea/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Personenverzeichniss/parents.dart';


class AddChild extends StatefulWidget {
  Auth auth;
  var profile;

  AddChild(Auth this.auth, var this.profile, this.firestore);
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {

  MergeChildParent mergeChildParent;
  bool allowScanner = false;
  _AddChildState(){
    mergeChildParent = new MergeChildParent(widget.firestore);
  }

  @override
  Widget build(BuildContext context) {
    /*return Container(
      child: new Card(
        child: Container(
          child: Column(
            children: <Widget>[
              Text('Scanne den Qr-Code, auf dem Display deines Kindes, um die Kopplung abzuschliessen'),
              RaisedButton(
                child: Text('Verstanden'),
                onPressed: () => mergeChildParent.parentReadsQrCode(context, widget.profile['UID'], widget.profile['Vorname']),
              )
            ],
          ),
        ),
      ),
    );*/
    print('jdhfkajls');
    if (mergeChildParent.parentReaderror) {
      setState(() {
        print('jdhfkajls');
      });
    }
    return mergeChildParent.parentScannsQrCode(
        widget.profile);
  }
}
