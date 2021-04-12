import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/services/morea_firestore.dart';

import '../../morealayout.dart';

class SingleMessagePage extends StatelessWidget {
  SingleMessagePage(this.message, this.moreaFire, this.uid);

  final DocumentSnapshot message;
  final MoreaFirebase moreaFire;
  final String uid;

  @override
  Widget build(BuildContext context) {
    this.setMessageRead();
    return Scaffold(
      appBar: AppBar(
        title: Text(message.data()['title']),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Padding(
              padding:
                  EdgeInsets.only(top: 20, bottom: 40, left: 40, right: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Von: ' + message.data()['sender'],
                    style: MoreaTextStyle.sender,
                  ),
                  MoreaDivider(),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  Text(
                    message.data()['title'],
                    textAlign: TextAlign.center,
                    style: MoreaTextStyle.title,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  Text(
                    message.data()['body'],
                    style: MoreaTextStyle.normal,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> setMessageRead() async {
    if (!(message['read'].contains(this.uid))){
      await moreaFire.setMessageRead(uid, message.id);
    }
  }
}
