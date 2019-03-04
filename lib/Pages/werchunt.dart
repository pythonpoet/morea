import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';

class WerChunt extends StatefulWidget {
  WerChunt({this.auth, this.onSigedOut, this.crud});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BasecrudMethods crud;
  @override
  State<StatefulWidget> createState() => _WerChuntState();
}
enum FormType {
  leiter,
  teilnemer,
  eltern
}
class _WerChuntState extends State<WerChunt> {
  Auth auth0 = new Auth();
  final formKey = new GlobalKey<FormState>();
  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.teilnemer;

  String _pfadiname,_userUID,_stufe;
  DocumentSnapshot qsuserInfo, dsanmeldedat;
  Map<String,String> anmeldeDaten;
  String TNS;



  void getuserinfo(){
    auth0.getUserInformation().then((results){
      setState(() {
        qsuserInfo = results;
        _pfadiname = qsuserInfo.data['Pfadinamen'];
        _stufe = qsuserInfo.data['Stufe'];
      });
    });
  }
  void gettns(){
  auth0.getTNs(_stufe).then((results){
    dsanmeldedat = results;
  });
   TNS = dsanmeldedat.data.toString();

}

  @override
  Widget build(BuildContext context) {
    getuserinfo();
    gettns();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Werchunt'),
      ),
      body: new Container(
        child: new Form(
            key: formKey,
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: TNanzeigen()
            )
        ),
      ),
    );
  }

  List<Widget>TNanzeigen(){
    return [
      new Text(TNS)
    ];
  }
  }

