import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/About/about.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/home/eltern.dart';
import 'package:morea/Widgets/home/elternpend.dart';
import 'package:morea/Widgets/home/leiter.dart';
import 'package:morea/Widgets/home/teilnehmer.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'werchunt.dart';
import 'select_stufe.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/Widgets/home/teleblitz.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.firestore, this.navigationMap});

  final BaseAuth auth;
  final Firestore firestore;
  final Map<String, Function> navigationMap;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

enum FormType { leiter, teilnehmer, eltern, loading }

enum Anmeldung { angemolden, abgemolden, verchilt }

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  CrudMedthods crud0;
  MoreaFirebase moreafire;
  Teleblitz teleblitz;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  MoreaLoading moreaLoading;

  final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.loading;

  Map<String, dynamic> anmeldeDaten, groupInfo;
  bool chunnt = false;
  var messagingGroups;

  void submit(String anabmelden, String groupnr, String eventID, String uid, {String name}) {
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
    crud0
        .waitOnDocumentChanged("$pathEvents/$eventID/Anmeldungen", uid)
        .then((onValue) {
      if (onValue)
        showDialog(
            context: context,
            builder: (context) => new AlertDialog(
                  title: new Text("Teleblitz"),
                  content: new Text(anmeldung),
                ));
    });
    if(name == null){
      name = moreafire.getDisplayName;
    }
    if (_formType != FormType.eltern) {
      moreafire.childAnmelden(eventID, widget.auth.getUserID,
          widget.auth.getUserID, anabmelden, name);
    } else {
      moreafire.parentAnmeldet(eventID, widget.auth.getUserID,
          widget.auth.getUserID, anabmelden, name);
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
      widget.navigationMap[signedOut]();
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
    moreaLoading = new MoreaLoading(this);
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
                      builder: (BuildContext context) => MessagesPage(
                            moreaFire: moreafire,
                            auth: widget.auth,
                            navigationMap: widget.navigationMap,
                          )));
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
          builder: (BuildContext context) => MessagesPage(
                moreaFire: moreafire,
                auth: widget.auth,
                navigationMap: widget.navigationMap,
              )));
    }, onLaunch: (Map<String, dynamic> message) async {
      print(message);
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => MessagesPage(
                moreaFire: moreafire,
                auth: widget.auth,
                navigationMap: widget.navigationMap,
              )));
    });
    getuserinfo();
  }

  @override
  void dispose() {
    moreaLoading.dispose();
    teleblitz.dispose();
    super.dispose();
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
            drawer: new Drawer(
              child: new ListView(children: navigation()),
            ),
            body: moreaLoading.loading());
      case FormType.leiter:
        return leiterView(
            stream: moreafire.tbz.getMapofEvents,
            groupID: moreafire.getGroupID,
            subscribedGroups: moreafire.getSubscribedGroups,
            navigation: navigation,
            teleblitzAnzeigen: teleblitz.anzeigen,
            route: routeEditTelebliz,
            navigationMap: widget.navigationMap,
            moreaLoading: moreaLoading.loading());

        break;
      case FormType.teilnehmer:
        return teilnehmerView(
            stream: moreafire.tbz.getMapofEvents,
            groupID: moreafire.getGroupID,
            navigation: navigation,
            teleblitzAnzeigen: teleblitz.anzeigen,
            anmeldebutton: this.childAnmeldeButton,
            navigationMap: widget.navigationMap,
            moreaLoading: moreaLoading.loading());
        break;
      case FormType.eltern:
        if (moreafire.getSubscribedGroups.length > 0)
          return elternView(
              stream: moreafire.tbz.getMapofEvents,
              subscribedGroups: moreafire.getSubscribedGroups,
              navigation: navigation,
              teleblitzAnzeigen: teleblitz.anzeigen,
              anmeldebutton: parentAnmeldeButton,
              navigationMap: widget.navigationMap,
              moreaLoading: moreaLoading.loading());
        else
          return Scaffold(
              appBar: AppBar(
                title: Text('Teleblitz'),
              ),
              drawer: new Drawer(
                child: new ListView(children: navigation()),
              ),
              body: requestPrompttoParent());
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
              color: MoreaColors.orange,
            ),
          ),
          new ListTile(
              title: new Text('Personen'),
              trailing: new Icon(Icons.people),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new PersonenVerzeichnisState()))),
          new Divider(),
          new ListTile(
              title: new Text("Über dieses App"),
              trailing: new Icon(Icons.info),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new AboutThisApp()))),
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
            decoration: new BoxDecoration(color: MoreaColors.orange),
          ),
          ListTile(
              title: new Text('Eltern hinzufügen'),
              trailing: new Icon(Icons.add),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfilePageState(
                        profile: moreafire.getUserMap,
                        firestore: widget.firestore,
                        crud0: crud0,
                      )))),
          Divider(),
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
            decoration: new BoxDecoration(color: MoreaColors.orange),
          ),
          new ListTile(
              title: new Text('Kinder hinzufügen'),
              trailing: new Icon(Icons.add),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfilePageState(
                        profile: moreafire.getUserMap,
                        firestore: widget.firestore,
                        crud0: crud0,
                      )))),
          new Divider(),
          new ListTile(
              title: new Text("Über dieses App"),
              trailing: new Icon(Icons.info),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new AboutThisApp()))),
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

  Widget parentAnmeldeButton(String groupID, String eventID) {
    List<Widget> anmeldebuttons = new List();
    moreafire.getChildMap[groupID].forEach((String vorname, uid) {
      anmeldebuttons.add(anmeldebutton(
          groupID, eventID, uid, "$vorname anmelden", "$vorname abmelden",
          name: vorname));
    });
    return Column(children: anmeldebuttons);
  }

  Widget childAnmeldeButton(String groupID, String eventID) {
    return anmeldebutton(moreafire.getGroupID, eventID, widget.auth.getUserID,
        'Chume', 'Chume nöd');
  }

  Widget anmeldebutton(
      String groupID, String eventID, String uid, String anmelden, abmelden,
      {String name}) {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: Container(
              child: new RaisedButton(
                child: new Text(abmelden, style: new TextStyle(fontSize: 20)),
                onPressed: () {
                  if (name == null) {
                    submit(eventMapAnmeldeStatusNegativ, moreafire.getGroupID, eventID, uid);
                  } else {
                    submit(eventMapAnmeldeStatusNegativ, moreafire.getGroupID, eventID, uid,
                        name: name);
                  }
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
              ),
            )),
            Expanded(
              child: Container(
                child: new RaisedButton(
                  child: new Text(anmelden, style: new TextStyle(fontSize: 20)),
                  onPressed: () {
                    if (name == null) {
                      submit(eventMapAnmeldeStatusPositiv, moreafire.getGroupID, eventID, uid);
                    } else {
                      submit(eventMapAnmeldeStatusPositiv, moreafire.getGroupID, eventID, uid,
                          name: name);
                    }
                  },
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
            builder: (BuildContext context) => new SelectStufe(moreafire)))
        .then((onValue) {
      setState(() {});
    });
  }
}
