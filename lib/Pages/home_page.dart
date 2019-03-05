import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';
import 'werchunt.dart';
import '../services/Getteleblitz.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSigedOut, this.crud});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BasecrudMethods crud;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}
enum FormType {
leiter,
  teilnemer,
  eltern
}
class _HomePageState extends State<HomePage> {

  crudMedthods crud0bj = new crudMedthods();
  Auth auth0 = new Auth();
  Teleblitz tlbz = new Teleblitz();

  final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.teilnemer;

  String _pfadiname,_userUID,_stufe;
  DocumentSnapshot qsuserInfo;
  Map<String,String> anmeldeDaten;



  void submit(String anabmelden) {
    print(qsuserInfo.data['Pfadinamen']);
    anmeldeDaten = {
      'Anmeldename' : this.qsuserInfo.data['Pfadinamen'],
      'Anmeldung': anabmelden
    };
    auth0.uebunganmelden(anmeldeDaten, _stufe,_userUID);
  }
 void getuserinfo(){
   widget.auth.currentUser().then((userId){
       _userUID = userId;
   });
  auth0.getUserInformation().then((results){
  setState(() {
  qsuserInfo = results;
  });
  try {
    _pfadiname = qsuserInfo.data['Pfadinamen'];
    _stufe = qsuserInfo.data['Stufe'];
  }catch(e){
    print(e);
  }
  });
}
  void _signedOut() async {
    try {
      await widget.auth.signOut();
      widget.onSigedOut();
    } catch (e) {
      print(e);
    }
  }
  void forminit(){
    try{
      switch(qsuserInfo.data['Pos']){
        case 'Leiter':
          _formType = FormType.leiter;
          break;
      }
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    getuserinfo();
    forminit();
    var futureBuilder = new FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){
          switch (snapshot.connectionState) {
            case ConnectionState.waiting: return new Text('Loading....');
            case ConnectionState.none: return new Text('Awaitig results');
            default:
              if (snapshot.hasError)
                return new Text('Error:');
              else
                return new Text('Result:');
          }
        }
    );
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Teleblitz'),
      ),
      drawer: new Drawer(
        child: new ListView(
          children: Navigation()
        ),
      ),
      body: Container(
        child: tlbz.anzeigen(_stufe),
      ),

    );
  }

  List<Widget> Navigation(){
    if(_formType == FormType.leiter){
      return [
        new UserAccountsDrawerHeader(
          accountName: new Text(_pfadiname),
          accountEmail: new Text('jarvis@morea.ch'),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA')
              )
          ),
        ),
        new ListTile(
          title: new Text('Teleblitz'),
          trailing: new Icon(Icons.flash_on),
        ),
        new ListTile(
          title: new Text('Wer chunt?'),
          trailing: new Icon(Icons.people),
          onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=> new WerChunt()))
        ),
        new ListTile(
          title: new Text('Events'),
          trailing: new Icon(Icons.event),
        ),
        new ListTile(
          title: new Text('Profil'),
          trailing: new Icon(Icons.person),
        ),
        new Divider(),
        new ListTile(
          title: new Text('Logout'),
          trailing: new Icon(Icons.cancel),
          onTap: _signedOut,

        )
      ];
    }else{
        return[
        new UserAccountsDrawerHeader(
          accountName: new Text(_pfadiname),
          accountEmail: new Text('jarvis@morea.ch'),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA')
              )
          ),
        ),
      new ListTile(
      title: new Text('Teleblitz'),
      trailing: new Icon(Icons.flash_on),
      ),
      new ListTile(
      title: new Text('Events'),
      trailing: new Icon(Icons.event),
      ),
      new ListTile(
      title: new Text('Profil'),
      trailing: new Icon(Icons.person),
      ),
      new Divider(),
      new ListTile(
      title: new Text('Logout'),
      trailing: new Icon(Icons.cancel),
      onTap: _signedOut,

      )
      ];
    }

  }
//Hier soll der Teleblitz angezeigt werden


  List<Widget> anmeldebutton(){
    return [
      new RaisedButton(
          child: new Text('Chume',style: new TextStyle(fontSize: 20)),
          onPressed: () => submit('Chunt')
      ),
      new RaisedButton(
          child: new Text('Chume nöd',style: new TextStyle(fontSize: 20)),
          onPressed: () => submit('Chunt nöd')
      ),
    ];
}
}


