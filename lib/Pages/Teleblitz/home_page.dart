import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/Widgets/home/eltern.dart';
import 'package:morea/Widgets/home/leiter.dart';
import 'package:morea/Widgets/home/teilnehmer.dart';

import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'werchunt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_stufe.dart';
import 'package:morea/Pages/Personenverzeichniss/add_child.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/Widgets/home/teleblitz.dart';

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
  Teleblitz teleblitz;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();



  final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.loading;

  Map<String, dynamic> anmeldeDaten, groupInfo;
  bool chunnt = false;
  var messagingGroups;

  void submit({@required String anabmelden, String groupnr}) {
    if (_formType != FormType.eltern) {
      String anmeldung;

      anmeldeDaten = {
        'Anmeldename': moreafire.getDisplayName,
        'Anmeldung': anabmelden
      };
      if (anabmelden == 'Chunt') {
        anmeldung = 'Du hast dich Angemolden';
        chunnt = true;
      } else {
        anmeldung = 'Du hast dich Abgemolden';
        chunnt = false;
      }
      moreafire.uebunganmelden(moreafire.getEventID, widget.auth.getUserID,
          widget.auth.getUserID, anabmelden);
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
                itemCount: moreafire.getUserMap['Kinder'].length,
                itemBuilder: (BuildContext context, int index) {
                  var namekind =
                      List.from(moreafire.getUserMap['Kinder'].keys)[index];
                  var uidkind =
                      List.from(moreafire.getUserMap['Kinder'].values)[index];
                  return ListTile(
                    title: Text(namekind),
                    onTap: () {
                      String anmeldung;
                      print(moreafire.getUserMap['Pfadinamen']);
                      anmeldeDaten = {
                        'Anmeldename': namekind,
                        'Anmeldung': anabmelden
                      };
                      if (anabmelden == 'Chunt') {
                        anmeldung = 'Du hast dich Angemolden';
                      } else {
                        anmeldung = 'Du hast dich Abgemolden';
                      }
                      moreafire.uebunganmelden(moreafire.getEventID,
                          widget.auth.getUserID, uidkind, anabmelden);
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

  Future<void> getdevtoken() async {
    var token = await firebaseMessaging.getToken();
    moreafire.uploaddevtocken(messagingGroups, token, widget.auth.getUserID);
  }

  void getuserinfo() async {
    await moreafire.getData(widget.auth.getUserID);
    await moreafire.initTeleblitz();
    forminit();
    getdevtoken();
    teleblitz = new Teleblitz(moreafire);
    setState(() {});
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
      switch (moreafire.getPos) {
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
        return teleblitz.loadingScreen(navigation);
      case FormType.leiter:
        return leiterView(
            stream: moreafire.tbz.getMapofEvents,
            groupID: moreafire.getGroupID,
            subscribedGroups: moreafire.getSubscribedGroups,
            navigation: navigation,
            teleblitzAnzeigen: teleblitz.anzeigen,
            route: routeEditTelebliz);

        break;
      case FormType.teilnehmer:
        return teilnehmerView(
            stream: moreafire.tbz.getMapofEvents,
            groupID: moreafire.getGroupID,
            navigation: navigation,
            teleblitzAnzeigen: teleblitz.anzeigen,
            anmeldebutton: anmeldebutton);
        break;
      case FormType.eltern:
        return elternView(
            stream: moreafire.tbz.getMapofEvents,
            subscribedGroups: moreafire.getSubscribedGroups,
            navigation: navigation,
            teleblitzAnzeigen: teleblitz.anzeigen,
            anmeldebutton: anmeldebutton);
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
            accountName: new Text(moreafire.getDisplayName),
            accountEmail: new Text(widget.auth.getUserEmail),
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
          ),
          //TODO eventID übertragen
          new ListTile(
              title: new Text('Wer chunt?'),
              trailing: new Icon(Icons.people),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new WerChunt(
                        firestore: widget.firestore,
                      )))),
          new ListTile(
              title: new Text('Agenda'),
              trailing: new Icon(Icons.event),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new AgendaState(
                        userInfo: moreafire.getUserMap,
                        firestore: widget.firestore,
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
            accountName: new Text(moreafire.getDisplayName),
            accountEmail: new Text(widget.auth.getUserEmail),
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
                      new AgendaState(userInfo: moreafire.getUserMap)))),
          new ListTile(
              title: new Text('Profil'),
              trailing: new Icon(Icons.person),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfilePageState(
                        profile: moreafire.getUserMap,
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
        return [
          new UserAccountsDrawerHeader(
            accountName: Text(moreafire.getDisplayName),
            accountEmail: Text(widget.auth.getUserEmail),
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
                      new AgendaState(userInfo: moreafire.getUserMap)))),
          new ListTile(
              title: new Text('Profil'),
              trailing: new Icon(Icons.person),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfilePageState(
                        profile: moreafire.getUserMap,
                      )))),
          ListTile(
            title: Text('Kind hinzufügen'),
            trailing: Icon(Icons.person_add),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => AddChild(
                    widget.auth, moreafire.getUserMap, widget.firestore))),
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

  Widget anmeldebutton(String groupnr) {
      return Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: new RaisedButton(
                  child:
                      new Text('Chume nöd', style: new TextStyle(fontSize: 20)),
                  onPressed: () => submit(
                      anabmelden: 'Chunt nöd', groupnr: moreafire.getGroupID),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
              )),
              Expanded(
                child: Container(
                  child: new RaisedButton(
                    child:
                        new Text('Chume', style: new TextStyle(fontSize: 20)),
                    onPressed: () => submit(
                        anabmelden: 'Chunt', groupnr: moreafire.getGroupID),
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

  void routeEditTelebliz() {
    Navigator.of(context)
        .push(new MaterialPageRoute(
            builder: (BuildContext context) => new SelectStufe()))
        .then((onValue) {
      setState(() {});
    });
  }
}
