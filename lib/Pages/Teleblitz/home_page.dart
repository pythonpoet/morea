import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/About/about.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/Widgets/Action/scan.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'select_stufe.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/Widgets/home/teleblitz.dart';
import 'package:morea/Widgets/home/elternpend.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.firestore, this.navigationMap, this.moreafire});

  final BaseAuth auth;
  final Firestore firestore;
  final Map<String, Function> navigationMap;
  final MoreaFirebase moreafire;

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
    moreafire = widget.moreafire;
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
                            firestore: widget.firestore,
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
                firestore: widget.firestore,
                navigationMap: widget.navigationMap,
              )));
    }, onLaunch: (Map<String, dynamic> message) async {
      print(message);
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => MessagesPage(
                moreaFire: moreafire,
                firestore: widget.firestore,
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
    if (_formType == FormType.loading)
      return Scaffold(
          appBar: AppBar(
            title: Text('Teleblitz'),
          ),
          drawer: new Drawer(
            child: new ListView(children: navigation()),
          ),
          body: moreaLoading.loading());
    if ((moreafire.getSubscribedGroups.length > 0) ||
        (moreafire.getGroupID != null)) {
      List<Widget> anzeige = new List();
      if (moreafire.getGroupID != null)
        anzeige.add(teleblitz.displayContent(
            moreaLoading.loading, moreafire.getGroupID));
      moreafire.getSubscribedGroups.forEach((groupID) {
        anzeige.add(teleblitz.displayContent(moreaLoading.loading, groupID));
      });

      return DefaultTabController(
        length: moreafire.getSubscribedGroups.length +
            ((moreafire.getGroupID != null) ? 1 : 0),
        child: Scaffold(
          appBar: new AppBar(
            title: new Text('Teleblitz'),
            bottom: TabBar(
                tabs: getTabList(((moreafire.getGroupID == null)
                    ? moreafire.getSubscribedGroups
                    : [
                        moreafire.getGroupID,
                        ...moreafire.getSubscribedGroups
                      ]))),
          ),
          drawer: moreaDrawer(moreafire.getPos, moreafire.getDisplayName,
              moreafire.getEmail, context, moreafire, crud0, _signedOut),
          body: TabBarView(children: anzeige),
          floatingActionButton: (moreafire.getPos == "Leiter")
              ? moreaEditActionbutton(routeEditTelebliz)
              : SizedBox(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: (moreafire.getPos == "Leiter")
              ? moreaLeiterBottomAppBar(widget.navigationMap, "Ändern")
              : moreaChildBottomAppBar(widget.navigationMap),
        ),
      );
    } else
      return Scaffold(
          appBar: AppBar(
            title: Text('Teleblitz'),
          ),
          drawer: new Drawer(
            child: new ListView(children: navigation()),
          ),
          body: requestPrompttoParent());
  }

  List<Widget> getTabList(List<String> subscribedGroups) {
    List<Widget> tabList = new List();
    for (String groupID in subscribedGroups) {
      tabList.add(new Tab(
        text: convMiDatatoWebflow(groupID),
      ));
    }
    return tabList;
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
          new ListTile(
            title: new Text("TN zu Leiter machen"),
            trailing: new Icon(Icons.enhanced_encryption),
            onTap: () => makeLeiterWidget(context,
                moreafire.getUserMap[userMapUID], moreafire.getGroupID),
          ),
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
                        moreaFire: moreafire,
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
