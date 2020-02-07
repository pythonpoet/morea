import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:showcaseview/showcaseview.dart';
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
  GlobalKey _changeTeleblitzKey = GlobalKey();
  GlobalKey _bottomAppBarLeiterKey = GlobalKey();
  GlobalKey _drawerKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _bottomAppBarTNKey = GlobalKey();

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
          backgroundColor: MoreaColors.bottomAppBar,
          key: _scaffoldKey,
          appBar: new AppBar(
            elevation: 0,
            backgroundColor: MoreaColors.orange,
            title: new Text('Teleblitz'),
            bottom: TabBar(
                tabs: getTabList(((moreafire.getGroupID == null)
                    ? moreafire.getSubscribedGroups
                    : [
                        moreafire.getGroupID,
                        ...moreafire.getSubscribedGroups
                      ]))),
            actions: tutorialButton(),
            leading: Showcase.withWidget(
              key: _drawerKey,
              disableAnimation: true,
              height: 300,
              width: 150,
              container: Container(
                padding: EdgeInsets.all(5),
                constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
                child: Column(
                  children: [
                    Text(
                      tutorialDrawer(),
                    ),
                  ],
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState.openDrawer(),
              ),
            ),
          ),
          drawer: moreaDrawer(moreafire.getPos, moreafire.getDisplayName,
              moreafire.getEmail, context, moreafire, crud0, _signedOut),
          body: TabBarView(children: anzeige),
          floatingActionButton: (moreafire.getPos == "Leiter")
              ? Showcase(
                  key: _changeTeleblitzKey,
                  disableAnimation: true,
                  description: 'Hier kannst du den Teleblitz ändern',
                  child: moreaEditActionbutton(
                    route: routeEditTelebliz,
                  ))
              : SizedBox(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: (moreafire.getPos == "Leiter")
              ? Showcase.withWidget(
                  key: _bottomAppBarLeiterKey,
                  disableAnimation: true,
                  height: 500,
                  width: 150,
                  container: Container(
                    padding: EdgeInsets.all(5),
                    constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white),
                    child: Column(
                      children: [
                        Text(
                          'Hier kannst du zu den verschiedenen Screens wechseln. Wechsle zum nächsten Screen und drücke dort den Hilfeknopf oben rechts.',
                        ),
                      ],
                    ),
                  ),
                  child:
                      moreaLeiterBottomAppBar(widget.navigationMap, "Ändern"))
              : Showcase.withWidget(
                  key: _bottomAppBarTNKey,
                  height: 300,
                  width: 150,
                  disableAnimation: true,
                  container: Container(
                    padding: EdgeInsets.all(5),
                    constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white),
                    child: Column(
                      children: [
                        Text(
                          'Hier kannst du zu den verschiedenen Screens wechseln. Wechsle zum nächsten Screen und drücke dort den Hilfeknopf oben rechts.',
                        ),
                      ],
                    ),
                  ),
                  child: moreaChildBottomAppBar(
                    widget.navigationMap,
                  )),
        ),
      );
    } else
      return Scaffold(
          appBar: AppBar(
            title: Text('Teleblitz'),
          ),
          drawer: moreaDrawer(moreafire.getPos, moreafire.getDisplayName,
              moreafire.getEmail, context, moreafire, crud0, _signedOut),
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
    return [
      ListTile(
        leading: Text('Loading...'),
      )
    ];
  }

  void routeEditTelebliz() {
    Navigator.of(context)
        .push(new MaterialPageRoute(
            builder: (BuildContext context) => new SelectStufe(moreafire)))
        .then((onValue) {
      setState(() {});
    });
  }

  List<Widget> tutorialButton() {
    switch (_formType) {
      case FormType.leiter:
        return [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => tutorialLeiter(),
          )
        ];
        break;
      case FormType.teilnehmer:
        return [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => tutorialTN(),
          )
        ];
        break;
      case FormType.eltern:
        return [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => tutorialEltern(),
          )
        ];
        break;
      case FormType.loading:
        return [];
        break;
      default:
        return [];
    }
  }

  void tutorialLeiter() {
    ShowCaseWidget.of(context).startShowCase(
        [_changeTeleblitzKey, _drawerKey, _bottomAppBarLeiterKey]);
  }

  void tutorialTN() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(
                  'Auf diesem Screen kannst du den Teleblitz deines Fähnlis sehen und dich dafür anmelden (ist nur möglich wenn eine Aktivität stattfindet)'),
            )).then((value) => ShowCaseWidget.of(context)
        .startShowCase([_drawerKey, _bottomAppBarTNKey]));
  }

  void tutorialEltern() {
    ShowCaseWidget.of(context).startShowCase([_drawerKey, _bottomAppBarTNKey]);
  }

  String tutorialDrawer() {
    switch (_formType) {
      case FormType.leiter:
        return 'Hier kannst du als Leiter das Profil deiner TNs ändern, TNs zu Leitern machen und dich ausloggen.';
        break;
      case FormType.teilnehmer:
        return 'Hier kannst du das Konto deiner Eltern verlinken, damit sie dich für Aktivitäten anmelden können, und dich ausloggen.';
        break;
      case FormType.eltern:
        return 'Hier kannst du das Konto deiner Kinder verlinken, damit du sie für Aktivitäten anmelden kannst, und dich ausloggen.';
        break;
      case FormType.loading:
        return 'Loading';
        break;
      default:
        return 'Loading';
    }
  }
}
