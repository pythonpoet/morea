
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';
import 'werchunt.dart';
import '../services/Getteleblitz.dart';
import 'Agenda_page.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'change_teleblitz.dart';
import 'personen_verzeichniss_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSigedOut, this.crud});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BasecrudMethods crud;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

enum FormType { leiter, teilnehmer, eltern }

class _HomePageState extends State<HomePage> {
  crudMedthods crud0bj = new crudMedthods();
  Auth auth0 = new Auth();
  Teleblitz tlbz = new Teleblitz();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();



  final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.teilnehmer;

  String _pfadiname = ' ', _userUID = ' ', _stufe = ' ', _email = ' ';
  DocumentSnapshot qsuserInfo;
  Map<String, String> anmeldeDaten;

  void submit(String anabmelden) {
    String anmeldung;
    print(qsuserInfo.data['Pfadinamen']);
    anmeldeDaten = {'Anmeldename': _pfadiname, 'Anmeldung': anabmelden};
    if (anabmelden == 'Chunt') {
      anmeldung = 'Du hast dich Angemolden';
    } else {
      anmeldung = 'Du hast dich Abgemolden';
    }
    auth0.uebunganmelden(anmeldeDaten, _stufe, _userUID);
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Teleblitz"),
          content: new Text(anmeldung),

        ));
  }
  
void getdevtoken()async{
  var token = await firebaseMessaging.getToken();
  auth0.uploaddevtocken(_stufe, token, _userUID);
}

  getuserinfo() async {
    widget.auth.currentUser().then((userId) {
      _userUID = userId;
    });
    await auth0.getUserInformation().then((results) async {
        setState(() {
          qsuserInfo = results;
          _pfadiname = qsuserInfo.data['Pfadinamen'];
          _stufe = qsuserInfo.data['Stufe'];
          forminit();
          getdevtoken();
        });
      try {
        await auth0.userEmail().then((onValue) {
          _email = onValue;
        });

        if (_pfadiname == '') {
          _pfadiname = qsuserInfo.data['Vorname'];
        }
      } catch (e) {
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

 forminit() {
    try {
      switch (qsuserInfo.data['Pos']) {
        case 'Leiter':
        print('leiter');
          _formType = FormType.leiter;
          break;
      }
    } catch (e) {
      print(e);
    }
  }
  
  @override
  void initState(){
    super.initState();
     getuserinfo();
  }

  @override
  Widget build(BuildContext context) {
    return teleblitzwidget();
  }

  Widget teleblitzwidget(){
    if(_formType == FormType.leiter){    
     return Scaffold(
        appBar: new AppBar(
          title: new Text('Teleblitz'),
          backgroundColor: Color(0xff7a62ff),
        ),
        drawer: new Drawer(
          child: new ListView(children: navigation()),
        ),
        body:  LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: tlbz.anzeigen(_stufe),
                            )
                          ],
                        ),
                      ),
                    );
                  },
        ),
        floatingActionButton: new FloatingActionButton(
          elevation: 1.0,
          child: new Icon(Icons.edit),
          backgroundColor: Color(0xff7a62ff),
          onPressed: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new ChangeTeleblitz(stufe: _stufe))))
    
        );
    }else{
      return Scaffold(
        appBar: new AppBar(
          title: new Text('Teleblitz'),
          backgroundColor: Color(0xff7a62ff),
        ),
        drawer: new Drawer(
          child: new ListView(children: navigation()),
        ),
        body: LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                               tlbz.anzeigen(_stufe),
                               anmeldebutton()
                            ],
                          )
                        )
                      ),
                    );
                  },
                ),
        );
    }
  }

  List<Widget> navigation() {
    if (_formType == FormType.leiter) {
      return [
        new UserAccountsDrawerHeader(
          accountName: new Text(_pfadiname),
          accountEmail: new Text(_email),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
        ),
        new ListTile(
            title: new Text('Wer chunt?'),
            trailing: new Icon(Icons.people),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new WerChunt(userInfo: qsuserInfo.data,)))),
        new ListTile(
            title: new Text('Agenda'),
            trailing: new Icon(Icons.event),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new AgendaState(userInfo: qsuserInfo.data,)))),
        new ListTile(
            title: new Text('Personen'),
            trailing: new Icon(Icons.people),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new PersonenVerzeichnisState()))),
        new Divider(),
        new ListTile(
          title: new Text('Logout'),
          trailing: new Icon(Icons.cancel),
          onTap: _signedOut,
        )
      ];
    } else {
      return [
        new UserAccountsDrawerHeader(
          accountName: new Text(_pfadiname),
          accountEmail: new Text(_email),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
        ),
        new ListTile(
            title: new Text('Agenda'),
            trailing: new Icon(Icons.event),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new AgendaState(userInfo: qsuserInfo.data)))),
        new ListTile(
            title: new Text('Profil'),
            trailing: new Icon(Icons.person),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new ProfilePageState(profile: qsuserInfo.data,)))),
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

 Widget anmeldebutton() {
    return Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: new RaisedButton(
                  child:
                      new Text('Chume nöd', style: new TextStyle(fontSize: 20)),
                  onPressed: () => submit('Chunt nöd'),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
              )),
              Expanded(
                child: Container(
                  child: new RaisedButton(
                    child: new Text('Chume', style: new TextStyle(fontSize: 20)),
                    onPressed: () => submit('Chunt'),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xff7a62ff),
                    textColor: Colors.white,
                  ),
                ),
              )
            ],
          ));
  }
}
