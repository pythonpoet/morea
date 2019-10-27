import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/services/Teleblitz/Getteleblitz.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'werchunt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_stufe.dart';
import 'package:morea/Pages/Personenverzeichniss/add_child.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSigedOut, this.firestore});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

enum FormType { leiter, teilnehmer, eltern, loading }

enum Anmeldung { angemolden, abgemolden, verchilt }

class HomePageState extends State<HomePage> {
  CrudMedthods crud0;
  MoreaFirebase moreafire;
  Teleblitz tlbz;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  Info teleblitzinfo = new Info();

  final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.loading;
  Anmeldung _anmeldung = Anmeldung.verchilt;

  String _pfadiname = 'Loading...',
      _userUID = ' ',
      _groupID = '@',
      _email = 'Loading...',
      _eventID;
  DocumentSnapshot qsuserInfo, groupInfo;
  Map<String, dynamic> anmeldeDaten;
  bool chunnt = false;
  var messagingGroups;

  

  void submit({@required String anabmelden, String groupnr}) {
    _eventID = tlbz.getEventID();
    if (_formType != FormType.eltern) {
      String anmeldung;
      print(qsuserInfo.data['Pfadinamen']);
      anmeldeDaten = {'Anmeldename': _pfadiname, 'Anmeldung': anabmelden};
      if (anabmelden == 'Chunt') {
        anmeldung = 'Du hast dich Angemolden';
        chunnt = true;
      } else {
        anmeldung = 'Du hast dich Abgemolden';
        chunnt = false;
      }                       
      moreafire.uebunganmelden(_eventID, _userUID, _userUID, anabmelden);
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
                      moreafire.uebunganmelden(_eventID ,_userUID , uidkind , anabmelden );
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
    moreafire.uploaddevtocken(messagingGroups, token, _userUID);
  }

  void getuserinfo() async {
    _userUID = await widget.auth.currentUser();
    var results = await moreafire.getUserInformation(_userUID);
    setState(() {
      qsuserInfo = results;
      _pfadiname = qsuserInfo.data['Pfadinamen'];
      _groupID = qsuserInfo.data['groupID'];
      _email = qsuserInfo.data['Email'];
      messagingGroups = qsuserInfo.data['messagingGroups'];
    
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
    groupInfo = await moreafire.getGroupInformation(_groupID);
    tlbz = new Teleblitz(widget.firestore, groupInfo.data);
    //submit(anabmelden: "Chunt");
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
        case 'Teilnehmer':
          _formType = FormType.teilnehmer;
          break;
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

  void check4anmeldung() {}

  @override
  void initState() {
    super.initState();
    moreafire = new MoreaFirebase(widget.firestore);
    crud0 = new CrudMedthods(widget.firestore);
    

    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print(message);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Neue Nachricht'),
            actions: <Widget>[
              RaisedButton(
                color: MoreaColors.violett,
                onPressed: () {
                  return Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => MessagesPage()));
                },
                child: Text(
                  'Ansehen',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              RaisedButton(
                color: MoreaColors.violett,
                child: Text(
                  'Später',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }, onResume: (Map<String, dynamic> message) async {
      print(message);
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => MessagesPage()));
    }, onLaunch: (Map<String, dynamic> message) async {
      print(message);
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => MessagesPage()));
    });
    getuserinfo();
    
  }

  @override
  Widget build(BuildContext context) {
    return teleblitzwidget();
  }

  Widget teleblitzwidget() {
    switch (_formType) {
      case FormType.loading:
        return Scaffold(
          appBar: AppBar(
            title: Text('Teleblitz'),
          ),
          drawer: Drawer(
            child: ListView(
              children: navigation(),
            ),
          ),
          body: Container(
            child: Center(
                child: Container(
              padding: EdgeInsets.all(120),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: new Text('Loading...'),
                  ),
                  Expanded(child: new CircularProgressIndicator())
                ],
              ),
            )),
          ),
        );
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
                        tlbz.anzeigen(_groupID),
                        Text("Teleblitz"),
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
                              anmeldebutton(groupnr: 'Biber')
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
                              anmeldebutton(groupnr: 'Wombat (Wölfe)')
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
                              anmeldebutton(groupnr: 'Nahani (Meitli)')
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
                              anmeldebutton(groupnr: 'Drason (Buebe)')
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
      case FormType.loading:
        return [
          ListTile(
            leading: Text('Loading...'),
          )
        ];
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
                        userInfo: qsuserInfo.data,firestore: widget.firestore,
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
                  builder: (BuildContext context) => MessagesPage()))),
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
          ListTile(
              title: Text('Profil'),
              trailing: Icon(Icons.message),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => MessagesPage()))),
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
                    AddChild(widget.auth, qsuserInfo.data, widget.firestore))),
          ),
          ListTile(
              title: Text('Profil'),
              trailing: Icon(Icons.message),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => MessagesPage()))),
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

  Widget anmeldebutton({String groupnr}) {
    if (groupnr == null) {
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
                      submit(anabmelden: 'Chunt nöd', groupnr: _groupID),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
              )),
              Expanded(
                child: Container(
                  child: new RaisedButton(
                    child:
                        new Text('Chume', style: new TextStyle(fontSize: 20)),
                    onPressed: () => submit(anabmelden: 'Chunt', groupnr: _groupID),
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
