import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/home/eltern.dart';
import 'package:morea/Widgets/home/leiter.dart';
import 'package:morea/Widgets/home/teilnehmer.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'werchunt.dart';
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

class HomePageState extends State<HomePage> with TickerProviderStateMixin{
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

  void submit(String anabmelden, String groupnr, String eventID, String uid) {
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
      crud0.waitOnDocumentChanged("$pathEvents/$eventID/Anmeldungen", uid).then((onValue){
        if(onValue)
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text("Teleblitz"),
            content: new Text(anmeldung),
          ));
      });
      if (_formType != FormType.eltern) {
      moreafire.childAnmelden(eventID, widget.auth.getUserID,
          widget.auth.getUserID, anabmelden);
      }else{
        moreafire.parentAnmeldet(eventID, widget.auth.getUserID,
          widget.auth.getUserID, anabmelden);
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
      if(Navigator.of(context).canPop()){
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      }
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
                          userInfo: moreafire.getUserMap,
                          firestore: widget.firestore,
                          auth: widget.auth,
                          moreaFire: moreafire,
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
                          userInfo: moreafire.getUserMap,
                          firestore: widget.firestore,
                          auth: widget.auth,
                          moreaFire: moreafire,
                          )));
    }, onLaunch: (Map<String, dynamic> message) async {
      print(message);
      Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => MessagesPage(
                          userInfo: moreafire.getUserMap,
                          firestore: widget.firestore,
                          auth: widget.auth,
                          moreaFire: moreafire,
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
          body: moreaLoading.loading()
        );
      case FormType.leiter:
        return leiterView(
            stream: moreafire.tbz.getMapofEvents,
            groupID: moreafire.getGroupID,
            subscribedGroups: moreafire.getSubscribedGroups,
            navigation: navigation,
            teleblitzAnzeigen: teleblitz.anzeigen,
            route: routeEditTelebliz,
            moreaLoading: moreaLoading.loading());

        break;
      case FormType.teilnehmer:
        return teilnehmerView(
            stream: moreafire.tbz.getMapofEvents,
            groupID: moreafire.getGroupID,
            navigation: navigation,
            teleblitzAnzeigen: teleblitz.anzeigen,
            anmeldebutton: this.childAnmeldeButton,
            moreaLoading: moreaLoading.loading());
        break;
      case FormType.eltern:
        if(moreafire.getSubscribedGroups.length>0)
        return elternView(
            stream: moreafire.tbz.getMapofEvents,
            subscribedGroups: moreafire.getSubscribedGroups,
            navigation: navigation,
            teleblitzAnzeigen: teleblitz.anzeigen,
            anmeldebutton: parentAnmeldeButton,
            moreaLoading: moreaLoading.loading());
        else
          return Scaffold(
          appBar: AppBar(
            title: Text('Teleblitz'),
          ),
          drawer: new Drawer(
            child: new ListView(children: navigation()),
          ),
          body: moreaLoading.loading()
        ); 
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
                        moreaFire: moreafire,
                        firestore: widget.firestore,
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
                      new AgendaState(moreaFire: moreafire,firestore: widget.firestore,)))),
          new ListTile(
              title: new Text('Profil'),
              trailing: new Icon(Icons.person),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new ProfilePageState(
                        profile: moreafire.getUserMap, firestore: widget.firestore, crud0: crud0,
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
                      new AgendaState(moreaFire: moreafire,firestore: widget.firestore,)))),
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
  Widget parentAnmeldeButton(String groupID, String eventID){
    List<Widget> anmeldebuttons = new List();
    moreafire.getChildMap[groupID].forEach((String vorname, uid){
      anmeldebuttons.add(anmeldebutton(groupID, eventID, uid, "$vorname anmelden", "$vorname abmelden"));
    });
    return Column(
      children: anmeldebuttons
    );
  }
  Widget childAnmeldeButton(String groupID, String eventID){
    return anmeldebutton( moreafire.getGroupID, eventID, widget.auth.getUserID, 'Chume','Chume nöd');
  }
  
  Widget anmeldebutton(String groupID, String eventID, String uid, String anmelden, abmelden) {
      return Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: new RaisedButton(
                  child:
                      new Text(abmelden, style: new TextStyle(fontSize: 20)),
                  onPressed: () => submit(
                      eventMapAnmeldeStatusNegativ,groupID , eventID, uid),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
              )),
              Expanded(
                child: Container(
                  child: new RaisedButton(
                    child:
                        new Text(abmelden, style: new TextStyle(fontSize: 20)),
                    onPressed: () => submit(
                        eventMapAnmeldeStatusPositiv, moreafire.getGroupID, eventID, uid),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xff7a62ff),
                    textColor: Colors.white,
                  ),
                ),
              )
            ],
          ));
  }/*
  Widget anmeldebutton(String groupID, String eventID, String uid) {
      return Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: new RaisedButton(
                  child:
                      new Text(, style: new TextStyle(fontSize: 20)),
                  onPressed: () => submit(
                      'Chunt nöd', moreafire.getGroupID, eventID, uid),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
              )),
              Expanded(
                child: Container(
                  child: new RaisedButton(
                    child:
                        new Text(, style: new TextStyle(fontSize: 20)),
                    onPressed: () => submit(
                        'Chunt nöd', moreafire.getGroupID, eventID),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Color(0xff7a62ff),
                    textColor: Colors.white,
                  ),
                ),
              )
            ],
          ));
  }*/

  void routeEditTelebliz() {
    Navigator.of(context)
        .push(new MaterialPageRoute(
            builder: (BuildContext context) => new SelectStufe( moreafire,)))
        .then((onValue) {
      setState(() {});
    });
  }
}
