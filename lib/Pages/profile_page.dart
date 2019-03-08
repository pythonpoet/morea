import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfilePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}
enum FormType {
  leiter,
  teilnehmer,
  eltern
}
class _ProfilePageState extends State<ProfilePage> {
  Auth auth0 = new Auth();
  String _pfadiname = ' ',_userUID = ' ',_stufe = ' ', _email=' ',_vorname=' ', _nachname=' ', _adresse= ' ', _plz= ' ', _ort=' ', _handynummer=' ';

  DocumentSnapshot qsuserInfo;

  void getuserinfo()async {
    auth0.currentUser().then((userId) {
      _userUID = userId;
    });
    await auth0.getUserInformation().then((results) async{
      setState(() {
        qsuserInfo = results;
      });
      try {
        _pfadiname = qsuserInfo.data['Pfadinamen'];
        _vorname = qsuserInfo.data['Vorname'];
        _nachname = qsuserInfo.data['Nachname'];
        _adresse = qsuserInfo.data['Adresse'];
        _stufe = qsuserInfo.data['Stufe'];
        _plz = qsuserInfo.data['PLZ'];
        _ort = qsuserInfo.data['Ort'];
        _handynummer = qsuserInfo.data['Handynummer'];
        await auth0.userEmail().then((onValue){
          _email = onValue;
        });

        if (_pfadiname == ' ') {
          _pfadiname = qsuserInfo.data['Vorname'];
        }
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getuserinfo();
    return new Container(
        child: new Scaffold(
          appBar: new AppBar(
            title: Text('Profil Informationen'),
          ),body: new Container(
          padding: EdgeInsets.all(15),
          child: Column(
        children: <Widget>[
              new SizedBox(height: 20,),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Vorname:'),
                  ),
                  Expanded(
                    child: new Text(_vorname),
                  )
                ],
              ),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Nachname:'),
                  ),
                  Expanded(
                    child: new Text(_nachname),
                  )
                ],
              ),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Pfadiname:'),
                  ),
                  Expanded(
                    child: new Text(_pfadiname),
                  )
                ],
              ),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Stufe:'),
                  ),
                  Expanded(
                    child: new Text(_stufe),
                  )
                ],
              ),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Adresse:'),
                  ),
                  Expanded(
                    child: new Text(_adresse),
                  )
                ],
              ),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('PLZ:'),
                  ),
                  Expanded(
                    child: new Text(_plz),
                  )
                ],
              ),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Ort:'),
                  ),
                  Expanded(
                    child: new Text(_ort),
                  )
                ],
              ),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Handynummer:'),
                  ),
                  Expanded(
                    child: new Text(_handynummer),
                  )
                ],
              ),
              new Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Email:'),
                  ),
                  Expanded(
                    child: new Text(_email),
                  )
                ],
              )
        ],
      ),
        )
        )
    );
  }
}
