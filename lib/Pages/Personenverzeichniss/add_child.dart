import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/services/Getteleblitz.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/Pages/Personenverzeichniss/parents.dart';
import 'package:morea/Pages/Personenverzeichniss/add_child.dart';
import 'package:morea/services/morea_firestore.dart';

class AddChild extends StatefulWidget {
  Auth auth;
  var profile;

  AddChild(Auth this.auth, var this.profile, this.firestore);
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {
  Info teleblitzinfo = new Info();
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
        widget.profile['UID'], widget.profile['Vorname']);
  }
}
