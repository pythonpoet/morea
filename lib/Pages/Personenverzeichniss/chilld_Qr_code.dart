import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/qr_code.dart';
import 'package:morea/services/morea_firestore.dart';

class ChildShowsQrCodeState extends StatefulWidget{
  ChildShowsQrCodeState({this.childUID});
  String childUID;
  @override
  State<StatefulWidget> createState() => ChildShowsQrCodeStatePage();
}

class ChildShowsQrCodeStatePage extends State<ChildShowsQrCodeState>{

  void waitOnHandshake()async{

  }

  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  QrCode qrCode = new QrCode();
  MoreaFirebase moreafire = new MoreaFirebase();
    return Container(
      padding: EdgeInsets.all(20),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Text('Eltern/Erziehungsberechtigte koppeln',
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 20),),
                  Text('Um die Kopplung abzuschliessen, muss ein Elternteil/Erziehungsberechtigte disen Code Scannen'),
                  qrCode.generate(widget.childUID)
                ],
              ),
            ),
      ),
    );
  }
}