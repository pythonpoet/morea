import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/morea_firestore.dart';

import 'change_email.dart';
import 'change_name.dart';

class Profile extends StatefulWidget {
  final auth;
  final onSignedOut;
  final MoreaFirebase moreaFire;
  final Map<String, Function> navigationMap;

  Profile(
      {@required this.auth,
      @required this.onSignedOut,
      @required this.moreaFire,
      @required this.navigationMap});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map userInfo;
  List nachrichtenGruppen = [];
  Auth auth0 = Auth();
  TextEditingController password = TextEditingController();
  final _passwordKey = GlobalKey<FormState>();

  _ProfileState();

  @override
  void initState() {
    super.initState();
    this.userInfo = widget.moreaFire.getUserMap;
    this._getNachrichtenGruppen();
  }

  @override
  void dispose() {
    super.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this.userInfo['Pfadinamen'] == null) {
      this.userInfo['Pfadinamen'] = this.userInfo['Name'];
    }
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(this.userInfo['Pfadinamen']),
              accountEmail: Text(this.userInfo['Email']),
              decoration: new BoxDecoration(color: MoreaColors.orange),
            ),
            ListTile(
              title: new Text('Logout'),
              trailing: new Icon(Icons.cancel),
              onTap: _signedOut,
            )
          ],
        ),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Profil ändern',
                    style: MoreaTextStyle.title,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Name',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Text(
                    userInfo['Vorname'] +
                        ' ' +
                        userInfo['Nachname'] +
                        ' v/o ' +
                        userInfo['Pfadinamen'],
                    style: MoreaTextStyle.normal,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ChangeName(
                          userInfo['Vorname'],
                          userInfo['Nachname'],
                          userInfo['Pfadinamen'],
                          _changeName))),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                    title: Text(
                      'E-Mail-Adresse',
                      style: MoreaTextStyle.lable,
                    ),
                    subtitle: Text(
                      userInfo['Email'],
                      style: MoreaTextStyle.normal,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ChangeEmail(
                            userInfo['Email'], this._showReauthenticate)))),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Passwort',
                    style: MoreaTextStyle.lable,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Handynummer',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Text(
                    userInfo['Handynummer'],
                    style: MoreaTextStyle.normal,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Adresse',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Text(
                    userInfo['Adresse'] +
                        ', ' +
                        userInfo['PLZ'] +
                        ' ' +
                        userInfo['Ort'],
                    style: MoreaTextStyle.normal,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Nachrichtengruppen',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: ListView.builder(
                    shrinkWrap: true,
                    itemCount: nachrichtenGruppen.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          nachrichtenGruppen[index],
                          style: MoreaTextStyle.normal,
                        ),
                      );
                    },
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                )
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Profil'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Color.fromRGBO(43, 16, 42, 0.9),
          child: Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  onPressed: widget.navigationMap[toMessagePage],
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
                  onPressed: widget.navigationMap[toAgendaPage],
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
                ),
                flex: 1,
              ),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  onPressed: widget.navigationMap[toHomePage],
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
                  onPressed: null,
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
    );
  }

  void _signedOut() async {
    try {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      }
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  void _changeName(String vorname, String nachname, String pfadiname) async {
    this.userInfo['Vorname'] = vorname;
    this.userInfo['Nachname'] = nachname;
    if (pfadiname == null) {
      this.userInfo['Pfadinamen'] = vorname;
    } else {
      this.userInfo['Pfadinamen'] = pfadiname;
    }
    await widget.moreaFire.createUserInformation(userInfo);
    setState(() {});
  }

  void _changeEmail(String email) async {
    this.userInfo['Email'] = email;
    await widget.moreaFire.createUserInformation(userInfo);
    await auth0.changeEmail(email);
    await widget.auth.signOut();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
    widget.onSignedOut();
  }

  Future<bool> _validateAndSave() async {
    final form = _passwordKey.currentState;
    if (form.validate()) {
      var result = await auth0.reauthenticate(userInfo['Email'], password.text);
      print(result);
      if (result) {
        form.save();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void _getNachrichtenGruppen() {
    for (var u in userInfo['messageGroups'].keys) {
      if (userInfo['messageGroups'][u]) {
        nachrichtenGruppen.add(u);
      }
    }
  }

  void _showReauthenticate(String email) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Achtung',
                style: MoreaTextStyle.title,
              ),
              content: Column(
                children: <Widget>[
                  Text(
                      'Aus Sicherheitsgründen müssen sie ihr Passwort erneut eingeben, um ihre E-Mail-Adresse zu ändern.'),
                  Form(
                    key: _passwordKey,
                    child: TextFormField(
                      controller: password,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 18),
                      cursorColor: MoreaColors.violett,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Bitte nicht leer lassen';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                RaisedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text(
                      "Abbrechen",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    color: MoreaColors.violett,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
                RaisedButton.icon(
                    onPressed: () async {
                      var result = await _validateAndSave();
                      if (result) {
                        this._changeEmail(email);
                      }
                    },
                    icon: Icon(
                      Icons.input,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text(
                      "Anmelden",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    color: MoreaColors.violett,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
              ],
            ));
  }
}
