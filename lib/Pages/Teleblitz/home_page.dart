import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/About/about.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/Pages/test/test_mailchimp.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/home/eltern.dart';
import 'package:morea/Widgets/home/elternpend.dart';
import 'package:morea/Widgets/home/leiter.dart';
import 'package:morea/Widgets/home/teilnehmer.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
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

  //final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.loading;

  Map<String, dynamic> anmeldeDaten, groupInfo;
  bool chunnt = false;
  var messagingGroups;

  void getuserinfo() async {
    await moreafire.getData(widget.auth.getUserID);
    await moreafire.initTeleblitz();
    forminit();
    teleblitz = new Teleblitz(moreafire, crud0);
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
      default:
        return Scaffold(
            appBar: AppBar(
              title: Text('Teleblitz'),
            ),
            drawer: new Drawer(
              child: new ListView(children: navigation()),
            ),
            body: moreaLoading.loading());
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
                      new PersonenVerzeichnisState(
                        moreaFire: moreafire,
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
                        moreaFire: moreafire,
                        crud0: crud0,
                      )))),
          ListTile(
              title: new Text('Test Mailchimp'),
              trailing: new Icon(Icons.add),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new TestMailchimp(moreafire)))),
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
      default:
        return [
          ListTile(
            leading: Text('Loading...'),
          )
        ];
    }
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
