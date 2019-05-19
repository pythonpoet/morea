import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/services/Getteleblitz.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'werchunt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_stufe.dart';
import 'package:morea/Pages/Personenverzeichniss/parents.dart';
import 'package:morea/Pages/Personenverzeichniss/add_child.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSigedOut, this.crud});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BaseCrudMethods crud;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

enum FormType { leiter, teilnehmer, eltern }

enum Anmeldung { angemolden, abgemolden, verchilt }

class HomePageState extends State<HomePage> {
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

  String _pfadiname = 'Loading...',
      _userUID = ' ',
      _stufe = '@',
      _email = 'Loading...';
  DocumentSnapshot qsuserInfo;
  Map<String, String> anmeldeDaten;

  void submit({@required String anabmelden, String stufe}) {
    if (_formType != FormType.eltern) {
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
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Kind auswählen'),
              content: ListView.builder(
                shrinkWrap: true,
                itemCount: qsuserInfo.data['Kinder'].length,
                itemBuilder: (BuildContext context, int index) {
                  var namekind =
                      List.from(qsuserInfo.data['Kinder'].keys)[index];
                  var uidkind =
                      List.from(qsuserInfo.data['Kinder'].values)[index];
                  return ListTile(
                    title: Text(namekind),
                    onTap: () {
                      String anmeldung;
                      print(qsuserInfo.data['Pfadinamen']);
                      anmeldeDaten = {
                        'Anmeldename': namekind,
                        'Anmeldung': anabmelden
                      };
                      if (anabmelden == 'Chunt') {
                        anmeldung = 'Du hast dich Angemolden';
                      } else {
                        anmeldung = 'Du hast dich Abgemolden';
                      }
                      moreafire.uebunganmelden(stufe, uidkind, anmeldeDaten);
                      showDialog(
                          context: context,
                          child: new AlertDialog(
                            title: new Text("Teleblitz"),
                            content: new Text(anmeldung),
                          ));
                    },
                  );
                },
              ),
            );
          });
    }
  }

  void getdevtoken() async {
    var token = await firebaseMessaging.getToken();
    moreafire.uploaddevtocken(_stufe, token, _userUID);
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
//      getdevtoken();
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

  void forminit() {
    try {
      switch (qsuserInfo.data['Pos']) {
        case 'Leiter':
          _formType = FormType.leiter;
          break;
        case 'Mutter':
          _formType = FormType.eltern;
          break;
        case 'Vater':
          _formType = FormType.eltern;
          break;
        case 'Erziehungsberechtigter':
          _formType = FormType.eltern;
          break;
        case 'Erziehungsberechtigte':
          _formType = FormType.eltern;
          break;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getuserinfo();
//    firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) {
//
//      },
//      onResume: (Map<String, dynamic> message) {
//
//      },
//      onLaunch: (Map<String, dynamic> message) {
//
//      }
//    );
  }

  @override
  Widget build(BuildContext context) {
    return teleblitzwidget();
  }

  Widget teleblitzwidget() {
    switch (_formType) {
      case FormType.leiter:
        return DefaultTabController(
            length: 4,
            child: Scaffold(
                appBar: new AppBar(
                  title: new Text('Teleblitz'),
                  bottom: TabBar(tabs: [
                    Tab(text: "Biber"),
                    Tab(
                      text: 'Wölfe',
                    ),
                    Tab(
                      text: 'Meitli',
                    ),
                    Tab(text: 'Buebe')
                  ]),
                ),
                drawer: new Drawer(
                  child: new ListView(children: navigation()),
                ),
                body: TabBarView(children: [
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight,
                            ),
                            child: SingleChildScrollView(
                                child: Column(
                                  key: ObjectKey(tlbz.anzeigen('Biber')),
                              children: <Widget>[
                                tlbz.anzeigen('Biber'),
                              ],
                            ))),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight,
                            ),
                            child: SingleChildScrollView(
                                child: Column(
                                  key: ObjectKey(tlbz.anzeigen('Wombat (Wölfe)')),
                              children: <Widget>[
                                tlbz.anzeigen('Wombat (Wölfe)'),
                              ],
                            ))),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight,
                            ),
                            child: SingleChildScrollView(
                                child: Column(
                                  key: ObjectKey(tlbz.anzeigen('Nahani (Meitli)')),
                              children: <Widget>[
                                tlbz.anzeigen('Nahani (Meitli)'),
                              ],
                            ))),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight,
                            ),
                            child: SingleChildScrollView(
                                child: Column(
                                  key: ObjectKey(tlbz.anzeigen('Drason (Buebe)')),
                              children: <Widget>[
                                tlbz.anzeigen('Drason (Buebe)'),
                              ],
                            ))),
                      );
                    },
                  ),
                ]),
                floatingActionButton: new FloatingActionButton(
                    elevation: 1.0,
                    child: new Icon(Icons.edit),
                    backgroundColor: MoreaColors.violett,
                    onPressed: () => Navigator.of(context)
                            .push(new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new SelectStufe()))
                            .then((onValue) {
                          setState(() {});
                        }))));

        break;
      case FormType.teilnehmer:
        return Scaffold(
          appBar: new AppBar(
            title: new Text('Teleblitz'),
            backgroundColor: MoreaColors.violett,
          ),
          drawer: new Drawer(
            child: new ListView(children: navigation()),
          ),
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
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
                    ))),
              );
            },
          ),
        );
        break;
      case FormType.eltern:
        return DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: new AppBar(
                title: new Text('Teleblitz'),
                backgroundColor: Color(0xff7a62ff),
                bottom: TabBar(tabs: [
                  Tab(text: "Biber"),
                  Tab(
                    text: 'Wölfe',
                  ),
                  Tab(
                    text: 'Meitli',
                  ),
                  Tab(text: 'Buebe')
                ]),
              ),
              drawer: new Drawer(
                child: new ListView(children: navigation()),
              ),
              body: TabBarView(children: [
                LayoutBuilder(
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
                              tlbz.anzeigen('Biber'),
                              anmeldebutton(stufe: 'Biber')
                            ],
                          ))),
                    );
                  },
                ),
                LayoutBuilder(
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
                              tlbz.anzeigen('Wombat (Wölfe)'),
                              anmeldebutton(stufe: 'Wombat (Wölfe)')
                            ],
                          ))),
                    );
                  },
                ),
                LayoutBuilder(
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
                              tlbz.anzeigen('Nahani (Meitli)'),
                              anmeldebutton(stufe: 'Nahani (Meitli)')
                            ],
                          ))),
                    );
                  },
                ),
                LayoutBuilder(
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
                              tlbz.anzeigen('Drason (Buebe)'),
                              anmeldebutton(stufe: 'Drason (Buebe)')
                            ],
                          ))),
                    );
                  },
                ),
              ]),
            ));
        break;
    }
  }

  List<Widget> navigation() {
    switch (_formType) {
      case FormType.leiter:
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
                  builder: (BuildContext context) => new WerChunt(
                        userInfo: qsuserInfo.data,
                      )))),
          new ListTile(
              title: new Text('Agenda'),
              trailing: new Icon(Icons.event),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new AgendaState(
                        userInfo: qsuserInfo.data,
                      )))),
          new ListTile(
              title: new Text('Personen'),
              trailing: new Icon(Icons.people),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new PersonenVerzeichnisState()))),
          new ListTile(
              title: new Text('Nachrichten'),
              trailing: new Icon(Icons.message),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  MessagesPage(userInfo: qsuserInfo.data)))),
          new Divider(),
          new ListTile(
            title: new Text('Logout'),
            trailing: new Icon(Icons.cancel),
            onTap: _signedOut,
          )
        ];
        break;
      case FormType.teilnehmer:
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
                  builder: (BuildContext context) =>
                      new AgendaState(userInfo: qsuserInfo.data)))),
          new ListTile(
              title: new Text('Profil'),
              trailing: new Icon(Icons.person),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfilePageState(
                        profile: qsuserInfo.data,
                      )))),
          /*ListTile(
            title: Text('Eltern bestätigen'),
            trailing: Icon(Icons.pregnant_woman),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    Parents(profile: qsuserInfo.data))),
          ),*/
          new Divider(),
          new ListTile(
            title: new Text('Logout'),
            trailing: new Icon(Icons.cancel),
            onTap: _signedOut,
          )
        ];
        break;
      case FormType.eltern:
        print(this._pfadiname);
        print(this._email);
        return [
          new UserAccountsDrawerHeader(
            accountName: Text(this._pfadiname),
            accountEmail: Text(this._email),
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
                  builder: (BuildContext context) =>
                      new AgendaState(userInfo: qsuserInfo.data)))),
          new ListTile(
              title: new Text('Profil'),
              trailing: new Icon(Icons.person),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfilePageState(
                        profile: qsuserInfo.data,
                      )))),
          ListTile(
            title: Text('Kind hinzufügen'),
            trailing: Icon(Icons.person_add),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    AddChild(auth0, qsuserInfo.data))),
          ),
          new Divider(),
          new ListTile(
            title: new Text('Logout'),
            trailing: new Icon(Icons.cancel),
            onTap: _signedOut,
          )
        ];
        break;
    }
  }

  Widget anmeldebutton({String stufe}) {
    if (stufe == null) {
      return Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: new RaisedButton(
                  child:
                      new Text('Chume nöd', style: new TextStyle(fontSize: 20)),
                  onPressed: () => submit(anabmelden: 'Chunt nöd'),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
              )),
              Expanded(
                child: Container(
                  child: new RaisedButton(
                    child:
                        new Text('Chume', style: new TextStyle(fontSize: 20)),
                    onPressed: () => submit(anabmelden: 'Chunt'),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xff7a62ff),
                    textColor: Colors.white,
                  ),
                ),
              )
            ],
          ));
    } else {
      return Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: new RaisedButton(
                  child:
                      new Text('Chume nöd', style: new TextStyle(fontSize: 20)),
                  onPressed: () =>
                      submit(anabmelden: 'Chunt nöd', stufe: stufe),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
              )),
              Expanded(
                child: Container(
                  child: new RaisedButton(
                    child:
                        new Text('Chume', style: new TextStyle(fontSize: 20)),
                    onPressed: () => submit(anabmelden: 'Chunt', stufe: stufe),
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
}
