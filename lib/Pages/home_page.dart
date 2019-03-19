import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';
import 'werchunt.dart';
import '../services/Getteleblitz.dart';
import 'Agenda_page.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_stufe.dart';

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
        // ignore: deprecated_member_use
        child: new AlertDialog(

                title: new Text("Teleblitz"),

                content: new Text(anmeldung),

              ));
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
  void initState() {
    print('init Start:${DateTime.now()}');
    super.initState();
    getuserinfo();
    print('init End:${DateTime.now()}');
  }

  @override
  Widget build(BuildContext context) {
    print('Build Start:${DateTime.now()}');
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Teleblitz'),
          backgroundColor: Color(0xff7a62ff),
        ),
        drawer: new Drawer(
          child: new ListView(children: navigation()),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 6,
                child: LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    print('SingleChildScollView Start:${DateTime.now()}');
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
                              height: 800,
                              child: tlbz.anzeigen(_stufe),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )),
            Expanded(
              flex: 1,
              child: Column(
                children: anmeldebutton(),
              ),
            )
          ],
        ));
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
            title: new Text("Teleblitz ändern"),
            trailing: new Icon(Icons.flash_on),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new SelectStufe()))),
        new ListTile(
            title: new Text('Wer chunt?'),
            trailing: new Icon(Icons.people),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new WerChunt()))),
        new ListTile(
            title: new Text('Agenda'),
            trailing: new Icon(Icons.event),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new AgendaState(
                      userInfo: qsuserInfo.data,
                    )))),
        new ListTile(
            title: new Text('Profil'),
            trailing: new Icon(Icons.person),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new ProfilePage()))),
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
                builder: (BuildContext context) =>
                    new AgendaState(userInfo: qsuserInfo.data)))),
        new ListTile(
            title: new Text('Profil'),
            trailing: new Icon(Icons.person),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new ProfilePage()))),
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

  List<Widget> anmeldebutton() {
    return [
      Container(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                  child: Container(
                child: new RaisedButton(
                  child:
                      new Text('Chume nöd', style: new TextStyle(fontSize: 20)),
                  onPressed: () => submit('Chunt nöd'),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  highlightColor: Color(0xff614ecc),
                ),
              )),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Container(
                  child: new RaisedButton(
                    child:
                        new Text('Chume', style: new TextStyle(fontSize: 20)),
                    onPressed: () => submit('Chunt'),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xff7a62ff),
                    highlightColor: Color(0xff614ecc),
                    textColor: Colors.white,
                  ),
                ),
              )
            ],
          ))
    ];
  }
}
