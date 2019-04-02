import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/services/Getteleblitz.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'werchunt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_stufe.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/Pages/Personenverzeichniss/parents.dart';
import 'package:morea/Pages/Grundbausteine/to_child_navigation.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSigedOut, this.crud});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BasecrudMethods crud;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

enum FormType { leiter, teilnehmer, eltern }

enum Anmeldung { angemolden, abgemolden, verchilt }

class HomePageState extends State<HomePage> {
  crudMedthods crud0bj = new crudMedthods();
  Auth auth0 = new Auth();
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
    auth0.uebunganmelden(anmeldeDaten, _stufe, _userUID);
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Teleblitz"),
          content: new Text(anmeldung),
        ));
  }

  void getdevtoken() async {
    var token = await firebaseMessaging.getToken();
    auth0.uploaddevtocken(_stufe, token, _userUID);
  }

  getuserinfo() async {
    await widget.auth.currentUser().then((userId) {
      _userUID = userId;
    });
    await auth0.getUserInformation(_userUID).then((results) async {
      setState(() {
        qsuserInfo = results;
        _pfadiname = qsuserInfo.data['Pfadinamen'];
        if (qsuserInfo.data['Stufe'] != null) {
          _stufe = qsuserInfo.data['Stufe'];
        }
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
  }

  @override
  Widget build(BuildContext context) {
    return teleblitzwidget();
  }

  Widget teleblitzwidget() {
    switch (_formType) {
      case FormType.leiter:
        return Scaffold(
            appBar: new AppBar(
                title: new Text('Teleblitz'),
                backgroundColor: Color(0xff7a62ff)),
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
                onPressed: () => Navigator.of(context)
                        .push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new SelectStufe()))
                        .then((onValue) {
                      setState(() {});
                    })));
        break;
      case FormType.teilnehmer:
        return Scaffold(
          appBar: new AppBar(
            title: new Text('Teleblitz'),
            backgroundColor: Color(0xff7a62ff),
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
        return selectStufe();
        break;
    }
  }

  Widget selectStufe() {
    return Scaffold(
      appBar: AppBar(
          title: Text("Kind auswählen/hinzufügen"), backgroundColor: Color(0xff7a62ff)),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Logout"),
              onTap: _signedOut,
            )
          ],
        ),
      ),
      body: Container(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Kind auswählen",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              checkIfChildren(),
            ],
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black26),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          margin: EdgeInsets.all(50),
          constraints: BoxConstraints(maxWidth: 250, maxHeight: 350),
        ),
        alignment: Alignment.topCenter,
      ),
    );
  }

  Widget checkIfChildren() {
    if (qsuserInfo.data['Kinder'] != null) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: qsuserInfo.data['Kinder'].length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: FlatButton(
                child: Text(
                  List.from(qsuserInfo.data['Kinder'].keys)[index],
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () =>
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => HomePage(
                            ))),
              ),
            );
          });
    } else {
      return Container(
        height: 200,
      );
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
            title: Text('Eltern bestätigen'),
            trailing: Icon(Icons.pregnant_woman),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    Parents(profile: qsuserInfo.data))),
          ),
          new Divider(),
          new ListTile(
            title: new Text('Logout'),
            trailing: new Icon(Icons.cancel),
            onTap: _signedOut,
          )
        ];
        break;
      case FormType.eltern:
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
