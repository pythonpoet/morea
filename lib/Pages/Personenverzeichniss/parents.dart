import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/services/qr_code.dart';
import 'package:morea/services/morea_firestore.dart';

abstract class BaseMergeChildParent{
  Widget childShowQrCode(String childUID, BuildContext context);
  void parentReadsQrCode( BuildContext context, String parentUID, String parentName);
  
}
class test{
  ProfilePageStatePage profilePageStatePage = new ProfilePageStatePage();
}
class MergeChildParent extends Object with test implements BaseMergeChildParent {
  QrCode qrCode = new QrCode();
  MoreaFirebase moreafire = new MoreaFirebase();
  //ProfilePageStatePage profilePageStatePage = new ProfilePageStatePage();

  BuildContext showDialogcontext;
  

  Widget childShowQrCode(String childUID, BuildContext context){
        return new Container(
          color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.only(
        top: 40,
        left: 20,
        right: 20,
        bottom: 40
      ),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Text('Eltern/Erziehungsberechtigte koppeln',
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 20),),
                  SizedBox(height: 30,),
                  Text('Um die Kopplung abzuschliessen, muss ein Elternteil/Erziehungsberechtigte disen Code Scannen'),
                  SizedBox(height: 30,),
                  qrCode.generate(childUID),
                  SizedBox(height: 30,),
                  new RaisedButton(
                  child: new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                  onPressed: () => profilePageStatePage.aktuallisieren(),
                  shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
                  color: Color(0xff7a62ff),
                  textColor: Colors.white,
                  ),
                ],
              ),
            ),
      ),
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