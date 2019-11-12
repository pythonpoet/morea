import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/Pages/Profil/profil.dart';
import 'package:morea/services/Getteleblitz.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'werchunt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_stufe.dart';
import 'package:morea/Pages/Personenverzeichniss/add_child.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSigedOut, this.crud, this.userInfo});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BaseCrudMethods crud;
  final Map<String, dynamic> userInfo;

  @override
  State<StatefulWidget> createState() => HomePageState(this.userInfo);
}

enum FormType { leiter, teilnehmer, eltern, loading }

enum Anmeldung { angemolden, abgemolden, verchilt }

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  HomePageState(this.userInfo);

  AnimationController _loadingController;
  Animation<int> loadingAnimation;
  AnimationController _controller;
  Animation curve;
  Animation<double> animation;
  List<String> loadingList = [
    'Loading.',
    'Loading..',
    'Loading...',
    'Loading...'
  ];
  CrudMedthods crud0bj = new CrudMedthods();
  Auth auth0 = new Auth();
  MoreaFirebase moreafire = new MoreaFirebase();
  Teleblitz tlbz = new Teleblitz();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  Info teleblitzinfo = new Info();

  final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.loading;
  Anmeldung _anmeldung = Anmeldung.verchilt;

  String _pfadiname = 'Loading...',
      _userUID = ' ',
      _stufe = '@',
      _email = 'Loading...';
  Map<String, dynamic> userInfo;
  Map<String, String> anmeldeDaten;
  bool chunnt = false;
  var messagingGroups;

  void submit({@required String anabmelden, String stufe}) {
    if (_formType != FormType.eltern) {
      String anmeldung;
      anmeldeDaten = {'Anmeldename': _pfadiname, 'Anmeldung': anabmelden};
      if (anabmelden == 'Chunt') {
        anmeldung = 'Du hast dich Angemolden';
        chunnt = true;
      } else {
        anmeldung = 'Du hast dich Abgemolden';
        chunnt = false;
      }
      moreafire.uebunganmelden(_stufe, _userUID, _pfadiname, chunnt);
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
                itemCount: userInfo['Kinder'].length,
                itemBuilder: (BuildContext context, int index) {
                  var namekind = List.from(userInfo['Kinder'].keys)[index];
                  var uidkind = List.from(userInfo['Kinder'].values)[index];
                  return ListTile(
                    title: Text(namekind),
                    onTap: () {
                      String anmeldung;
                      anmeldeDaten = {
                        'Anmeldename': namekind,
                        'Anmeldung': anabmelden
                      };
                      if (anabmelden == 'Chunt') {
                        anmeldung = 'Du hast dich Angemolden';
                      } else {
                        anmeldung = 'Du hast dich Abgemolden';
                      }
                      //moreafire.uebunganmelden(stufe, uidkind, anmeldeDaten);
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
    _userUID = await auth0.currentUser();
    var results = await moreafire.getUserInformation(_userUID);
    setState(() {
      this.userInfo = results.data;
      _pfadiname = userInfo['Pfadinamen'];
      _stufe = userInfo['Stufe'];
      _email = userInfo['Email'];
      messagingGroups = userInfo['messagingGroups'];
      try {
        if (_pfadiname == '') {
          _pfadiname = userInfo['Vorname'];
        }
      } catch (e) {
        print(e);
      }
      forminit();
      getdevtoken();
    });
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
      switch (userInfo['Pos']) {
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
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    animation = Tween<double>(begin: -0.5, end: 18 * math.pi).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    loadingAnimation = IntTween(begin: 0, end: 2).animate(_loadingController);
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
                          widget.userInfo, widget.auth, widget.onSigedOut)));
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
          builder: (BuildContext context) =>
              MessagesPage(widget.userInfo, widget.auth, widget.onSigedOut)));
    }, onLaunch: (Map<String, dynamic> message) async {
      print(message);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MessagesPage(
                  widget.userInfo, widget.auth, widget.onSigedOut)));
    });
    getuserinfo();
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return teleblitzwidget();
  }

  Widget teleblitzwidget() {
    switch (_formType) {
      case FormType.loading:
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedBuilder(
                animation: _controller,
                child: Image(image: AssetImage('assets/icon/logo_loading.png')),
                builder: (BuildContext context, Widget child) {
                  return Transform.rotate(
                    angle: animation.value,
                    child: child,
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15),
              ),
              AnimatedBuilder(
                animation: _loadingController,
                child: Text('Loading'),
                builder: (BuildContext context, Widget child) {
                  return Text(
                    loadingList[loadingAnimation.value],
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Raleway',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.left,
                  );
                },
              )
            ],
          ),
          color: Colors.white,
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
                bottomNavigationBar: BottomAppBar(
                  child: Container(
                    color: Color.fromRGBO(43, 16, 42, 0.9),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            onPressed: (() {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => MessagesPage(userInfo,
                                      widget.auth, widget.onSigedOut)));
                            }),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.message, color: Colors.white),
                                Text(
                                  'Nachrichten',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.white),
                                )
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),
                          ),
                          flex: 1,
                        ),
                        Expanded(
                          child: FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            onPressed: (() {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AgendaState(
                                        userInfo,
                                        widget.auth,
                                        widget.onSigedOut
                                      )));
                            }),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.event, color: Colors.white),
                                Text(
                                  'Agenda',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.white),
                                )
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),
                          ),
                          flex: 1,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              'Teleblitz ändern',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          flex: 1,
                        ),
                        Expanded(
                          child: FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            onPressed: null,
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.flash_on, color: Colors.white),
                                Text(
                                  'Teleblitz',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.white),
                                )
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),
                          ),
                          flex: 1,
                        ),
                        Expanded(
                          child: FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Profile(userInfo, widget.auth, widget.onSigedOut)
                              )
                            ),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.person, color: Colors.white),
                                Text(
                                  'Profil',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.white),
                                )
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),
                          ),
                          flex: 1,
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  shape: CircularNotchedRectangle(),
                ),
                body: TabBarView(children: [
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return Container(
                        padding: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: MoreaColors.orange,
                          image: DecorationImage(
                              image: AssetImage('assets/images/background.png'),
                              alignment: Alignment.bottomCenter),
                        ),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: viewportConstraints.maxHeight,
                              ),
                              child: Column(
                                key: ObjectKey(tlbz.anzeigen(
                                    'Biber',
                                    _controller,
                                    animation,
                                    _loadingController,
                                    loadingAnimation)),
                                children: <Widget>[
                                  tlbz.anzeigen('Biber', _controller, animation,
                                      _loadingController, loadingAnimation),
                                ],
                              )),
                        ),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return Container(
                        padding: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: MoreaColors.orange,
                          image: DecorationImage(
                              image: AssetImage('assets/images/background.png'),
                              fit: BoxFit.cover),
                        ),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: viewportConstraints.maxHeight,
                              ),
                              child: Column(
                                key: ObjectKey(tlbz.anzeigen(
                                    'Wombat (Wölfe)',
                                    _controller,
                                    animation,
                                    _loadingController,
                                    loadingAnimation)),
                                children: <Widget>[
                                  tlbz.anzeigen(
                                      'Wombat (Wölfe)',
                                      _controller,
                                      animation,
                                      _loadingController,
                                      loadingAnimation),
                                ],
                              )),
                        ),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return Container(
                        padding: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: MoreaColors.orange,
                          image: DecorationImage(
                              image: AssetImage('assets/images/background.png'),
                              fit: BoxFit.cover),
                        ),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: viewportConstraints.maxHeight,
                              ),
                              child: Column(
                                key: ObjectKey(tlbz.anzeigen(
                                    'Nahani (Meitli)',
                                    _controller,
                                    animation,
                                    _loadingController,
                                    loadingAnimation)),
                                children: <Widget>[
                                  tlbz.anzeigen(
                                      'Nahani (Meitli)',
                                      _controller,
                                      animation,
                                      _loadingController,
                                      loadingAnimation),
                                ],
                              )),
                        ),
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return Container(
                        padding: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: MoreaColors.orange,
                          image: DecorationImage(
                              image: AssetImage('assets/images/background.png'),
                              fit: BoxFit.cover),
                        ),
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: viewportConstraints.maxHeight,
                              ),
                              child: Column(
                                key: ObjectKey(tlbz.anzeigen(
                                    'Drason (Buebe)',
                                    _controller,
                                    animation,
                                    _loadingController,
                                    loadingAnimation)),
                                children: <Widget>[
                                  tlbz.anzeigen(
                                      'Drason (Buebe)',
                                      _controller,
                                      animation,
                                      _loadingController,
                                      loadingAnimation),
                                ],
                              )),
                        ),
                      );
                    },
                  ),
                ]),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: new FloatingActionButton(
                    elevation: 1.0,
                    child: new Icon(Icons.edit),
                    backgroundColor: MoreaColors.violett,
                    shape: CircleBorder(side: BorderSide(color: Colors.white)),
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
                    child: Column(
                      children: <Widget>[
                        tlbz.anzeigen(_stufe, _controller, animation,
                            _loadingController, loadingAnimation),
                        anmeldebutton()
                      ],
                    )),
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
                          child: Column(
                            children: <Widget>[
                              tlbz.anzeigen('Biber', _controller, animation,
                                  _loadingController, loadingAnimation),
                              anmeldebutton(stufe: 'Biber')
                            ],
                          )),
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
                          child: Column(
                            children: <Widget>[
                              tlbz.anzeigen(
                                  'Wombat (Wölfe)',
                                  _controller,
                                  animation,
                                  _loadingController,
                                  loadingAnimation),
                              anmeldebutton(stufe: 'Wombat (Wölfe)')
                            ],
                          )),
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
                          child: Column(
                            children: <Widget>[
                              tlbz.anzeigen(
                                  'Nahani (Meitli)',
                                  _controller,
                                  animation,
                                  _loadingController,
                                  loadingAnimation),
                              anmeldebutton(stufe: 'Nahani (Meitli)')
                            ],
                          )),
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
                          child: Column(
                            children: <Widget>[
                              tlbz.anzeigen(
                                  'Drason (Buebe)',
                                  _controller,
                                  animation,
                                  _loadingController,
                                  loadingAnimation),
                              anmeldebutton(stufe: 'Drason (Buebe)')
                            ],
                          )),
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
              color: MoreaColors.orange,
            ),
          ),
          new ListTile(
              title: new Text('Wer chunt?'),
              trailing: new Icon(Icons.people),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new WerChunt(
                        userInfo: userInfo,
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
              title: new Text('Profil'),
              trailing: new Icon(Icons.person),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfilePageState(
                        profile: userInfo,
                      )))),
          /*ListTile(
            title: Text('Eltern bestätigen'),
            trailing: Icon(Icons.pregnant_woman),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    Parents(profile: userInfo))),
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
            accountName: Text(this._pfadiname),
            accountEmail: Text(this._email),
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
          ),
          new ListTile(
              title: new Text('Profil'),
              trailing: new Icon(Icons.person),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfilePageState(
                        profile: userInfo,
                      )))),
          ListTile(
            title: Text('Kind hinzufügen'),
            trailing: Icon(Icons.person_add),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => AddChild(auth0, userInfo))),
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
