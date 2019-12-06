import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/child_parent_pend.dart';
import 'package:morea/services/utilities/qr_code.dart';

abstract class BaseMergeChildParent {

  
  Widget childShowQrCode(String qrCodeString, BuildContext context);

  void parentReadsQrCode(Map<String,dynamic> userMap);
}

class test {
  ProfilePageStatePage profilePageStatePage = new ProfilePageStatePage();
}

class MergeChildParent extends Object
    with test
    implements BaseMergeChildParent {

  QrCode qrCode = new QrCode();
  MoreaFirebase moreafire;
  CrudMedthods crud0;
  ChildParendPend childParendPend = new ChildParendPend();
  bool parentReaderror = false, allowScanner = true;

  //ProfilePageStatePage profilePageStatePage = new ProfilePageStatePage();

  BuildContext showDialogcontext;

  MergeChildParent(Firestore firestore){
    this.moreafire = new MoreaFirebase(firestore);
    this.crud0 = new CrudMedthods(firestore);
  }

  Widget childShowQrCode(String qrCodeString, BuildContext context) {
    return new Container(
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(
                'Eltern/Erziehungsberechtigte koppeln',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                  'Um die Kopplung abzuschliessen, muss ein Elternteil/Erziehungsberechtigte disen Code Scannen'),
              SizedBox(
                height: 30,
              ),
              qrCode.generate(qrCodeString),
              SizedBox(
                height: 40,
              ),
              new RaisedButton(
                child:
                    new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                onPressed: () => {
                  profilePageStatePage.childaktuallisieren(),
                  profilePageStatePage.childParendPend.deleteRequest(qrCodeString)
                  },

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

  void parentReadsQrCode(Map<String,dynamic> userMap) async {
    
    await qrCode.german_scanQR();
    if (qrCode.germanError ==
        'Um den Kopplungsvorgang mit deinem Kind abzuschliessen, scanne den Qr-Code, der im Profil deines Kindes ersichtlich ist.') {
       childParendPend.parentSendsRequestString(qrCode.qrResult, userMap);
      allowScanner = false;
      parentReaderror = false;
      profilePageStatePage.parentaktuallisieren();
    } else {
     
      parentReaderror = true;
      profilePageStatePage.parentaktuallisieren();
    }
  }

  Widget parentScannsQrCode(Map<String, dynamic> userMap) {
    return new Container(
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(
                'Eltern/Erziehungsberechtigte koppeln',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              Text(qrCode.germanError),
              SizedBox(
                height: 30,
              ),
              new RaisedButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.camera_alt),
                    SizedBox(
                      width: 5,
                    ),
                    new Text('Scannen', style: new TextStyle(fontSize: 20))
                  ],
                ),
                onPressed: () => parentReadsQrCode(userMap),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xff7a62ff),
                textColor: Colors.white,
              ),
              SizedBox(
                height: 40,
              ),
              new RaisedButton(
                child:
                    new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                onPressed: () => {
                      parentReaderror = false,
                      profilePageStatePage.parentaktuallisieren()
                    },
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
}
