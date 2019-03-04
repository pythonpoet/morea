import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSigedOut, this.crud});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BasecrudMethods crud;
  @override
  State<StatefulWidget> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  crudMedthods crud0bj = new crudMedthods();
  Auth auth0 = new Auth();
  final formKey = new GlobalKey<FormState>();
  String _pfadiname,_userUID;
  DocumentSnapshot qsuserInfo;
  Map<String,String> anmeldeDaten;

  void submit(String anabmelden) {
    getuserinfo();
    print(qsuserInfo.data['Pfadinamen']);
    anmeldeDaten = {
      this.qsuserInfo.data['Pfadinamen']: anabmelden
    };
    auth0.uebunganmelden(anmeldeDaten);
  }
 void getuserinfo(){
  auth0.getUserInformation().then((results){
  setState(() {
  qsuserInfo = results;
  });
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
  @override

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Teleblitz'),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Logout',
                style: new TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: _signedOut,
          )
        ],
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text('Jarvis'),
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
            )
          ],
        ),
      ),
      body: new Container(
        child: new Form(
            key: formKey,
          child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: anmeldebutton()
           )
        ),
      ),
    );
  }

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

