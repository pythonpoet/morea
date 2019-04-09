
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/services/Getteleblitz.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'werchunt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_stufe.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:share/share.dart';


class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSigedOut, this.crud});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BaseCrudMethods crud;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

enum FormType { leiter, teilnehmer, eltern }

enum Anmeldung {angemolden, abgemolden, verchilt}

class HomePageState extends State<HomePage>{
  CrudMedthods crud0bj = new CrudMedthods();
  Auth auth0 = new Auth();
  MoreaFirebase moreafire = new MoreaFirebase();
  Teleblitz tlbz = new Teleblitz();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  Info teleblitzinfo = new Info();



  final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.teilnehmer;
  Anmeldung _anmeldung = Anmeldung.verchilt;

  String _pfadiname = ' ', _userUID = ' ', _stufe = '@', _email = ' ';
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
    moreafire.uebunganmelden(_stufe, _userUID, anmeldeDaten);
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Teleblitz"),
          content: new Text(anmeldung),

        ));
  }

void getdevtoken()async{
  var token = await firebaseMessaging.getToken();
  moreafire.uploaddevtocken(_stufe, token, _userUID);
}
void forminit() {
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
void getuserinfo() async {
     _userUID = await auth0.currentUser();
    var results = await moreafire.getUserInformation(_userUID);
    setState(() {
      qsuserInfo = results;
      _pfadiname = qsuserInfo.data['Pfadinamen'];
      _stufe = qsuserInfo.data['Stufe'];
      _email = qsuserInfo.data['Email'];
      try {
      if (_pfadiname == '') {
          _pfadiname = qsuserInfo.data['Vorname'];
        }
      } catch (e) {
        print(e);
      }
      forminit();
      getdevtoken();
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
  void initState(){
    super.initState();
     getuserinfo();
  }

  @override
  Widget build(BuildContext context) {
    return teleblitzwidget();
  }

  Widget teleblitzwidget(){
    print("rebuilding...");
    if(_formType == FormType.leiter){    
     return Scaffold(
        appBar: new AppBar(
          title: new Text('Teleblitz'),
          backgroundColor: Color(0xff7a62ff),
          actions: <Widget>[
            FlatButton(
              child: Icon(Icons.share, color: Colors.white,),
              onPressed: (){
                Share.share('Chum au id Pfadi https://www.morea.ch/ ');
              },
            )
          ],
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
          builder: (BuildContext context) => new SelectStufe())).then((onValue){
            setState((){});
          }))
    
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
            trailing: new Icon(Icons.thumbs_up_down),
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
 


