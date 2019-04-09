import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/qr_code.dart';
import 'package:morea/services/morea_firestore.dart';

abstract class BaseMergeChildParent{
  void childShowQrCode(String childUID, BuildContext context);
  void parentReadsQrCode( BuildContext context);
}
class MergeChildParent{
  QrCode qrCode = new QrCode();
  MoreaFirebase moreafire = new MoreaFirebase();
  void childShowQrCode(String childUID, BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) =>
        new Container(
          child: Card(
            child: Container(
              child: Column(
                children: <Widget>[
                  Text('Eltern/Erziehungsberechtigte koppeln'),
                  Text('Um die Kopplung abzuschliessen, muss ein Elternteil/Erziehungsberechtigte disen Code Scannen'),
                  qrCode.generate(childUID)
                ],
              ),
            ),
          ),
        )
    );
  }
  void parentReadsQrCode( BuildContext context, String parentUID, String parentName)async{
    String childUID = await qrCode.readQrCode();
    DocumentSnapshot childInfo = await moreafire.getUserInformation(childUID);
    String childName = childInfo.data['Vorname'];
    moreafire.pendParent(childUID, parentUID, parentName);
    moreafire.setChildToParent(childUID, parentUID, childName);
  }
  
}