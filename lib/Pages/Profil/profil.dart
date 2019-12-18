import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Profil/change_phone_number.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/morea_firestore.dart';

import 'change_address.dart';
import 'change_email.dart';
import 'change_message_groups.dart';
import 'change_name.dart';
import 'change_password.dart';

class Profile extends StatefulWidget {
  final auth;
  final MoreaFirebase moreaFire;
  final Map<String, Function> navigationMap;

  Profile(
      {@required this.auth,
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
  String oldEmail;
  String newPassword;

  _ProfileState();

  @override
  void initState() {
    super.initState();
    this.userInfo = widget.moreaFire.getUserMap;
    this._getNachrichtenGruppen();
    this.oldEmail = userInfo['Email'];
  }

  @override
  void dispose() async {
    super.dispose();
    password.dispose();
    newPassword = null;
    await widget.moreaFire.getData(userInfo['UID']);
    this.userInfo = widget.moreaFire.getUserMap;
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
      floatingActionButtonLocation: _locationFloatingActionButton(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: MoreaColors.violett,
        shape: CircleBorder(side: BorderSide(color: Colors.white)),
        onPressed: _changeProfil,
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
                            userInfo['Email'], this._changeEmail)))),
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
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ChangePassword(this._changePassword))),
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
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ChangePhoneNumber(
                          userInfo['Handynummer'], _changePhoneNumber))),
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
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ChangeAddress(
                          userInfo['Adresse'],
                          userInfo['PLZ'],
                          userInfo['Ort'],
                          _changeAddress))),
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
                    physics: NeverScrollableScrollPhysics(),
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
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ChangeMessageGroups(
                          userInfo['messageGroups']['Biber'],
                          userInfo['messageGroups']['Wombat (Wölfe)'],
                          userInfo['messageGroups']['Nahani (Meitli)'],
                          userInfo['messageGroups']['Drason (Buebe)'],
                          this._changeMessageGroups))),
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
                child: Text('Änderungen speichern'),
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
      await widget.auth.signOut();
      widget.navigationMap[signedOut](this.dispose);
    } catch (e) {
      print(e);
    }
  }

  void _changeName(String vorname, String nachname, String pfadiname) {
    this.userInfo['Vorname'] = vorname;
    this.userInfo['Nachname'] = nachname;
    if (pfadiname == null) {
      this.userInfo['Pfadinamen'] = "";
    } else {
      this.userInfo['Pfadinamen'] = pfadiname;
    }
    setState(() {});
  }

  void _changeEmail(String email) {
    setState(() {
      this.userInfo['Email'] = email;
    });
  }

  void _changePassword(String password) {
    this.newPassword = password;
  }

  void _changePhoneNumber(String phoneNumber) {
    setState(() {
      this.userInfo['Handynummer'] = phoneNumber;
    });
  }

  void _changeAddress(String address, String plz, String ort) {
    setState(() {
      this.userInfo['Adresse'] = address;
      this.userInfo['PLZ'] = plz;
      this.userInfo['Ort'] = ort;
    });
  }

  void _changeMessageGroups(bool biber, bool wombat, bool nahani, bool drason) {
    setState(() {
      this.userInfo['messageGroups'] = {
        'Biber': biber,
        'Drason (Buebe)': drason,
        'Nahani (Meitli)': nahani,
        'Wombat (Wölfe)': wombat
      };
      this._getNachrichtenGruppen();
    });
  }

  Future<bool> _validateAndSave(String email) async {
    final form = _passwordKey.currentState;
    if (form.validate()) {
      var result = await auth0.reauthenticate(email, password.text);
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
    List<String> neuNachrichtenGruppen = [];
    for (var u in userInfo['messageGroups'].keys) {
      if (userInfo['messageGroups'][u]) {
        neuNachrichtenGruppen.add(u);
      }
    }
    nachrichtenGruppen = neuNachrichtenGruppen;
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
                      'Aus Sicherheitsgründen müssen sie ihr Passwort erneut eingeben, um ihre E-Mail oder ihr Passwort zu ändern.'),
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
                      var result = await _validateAndSave(email);
                      if (result) {
                        if (oldEmail != userInfo['Email']) {
                          await auth0.changeEmail(userInfo['Email']);
                        }
                        if (newPassword != null) {
                          await auth0.changePassword(newPassword);
                        }
                        await widget.moreaFire
                            .updateUserInformation(userInfo['UID'], userInfo);
                        if (oldEmail != userInfo['Email'] ||
                            newPassword != null) {
                          _showSignOutInformation().then((onValue) {
                            Navigator.of(context).pop();
                            _signedOut();
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      } else {
                        _showReauthenticateError();
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

  void _changeProfil() async {
    if (oldEmail != userInfo['Email'] || newPassword != null) {
      _showReauthenticate(oldEmail);
    } else {
      await widget.moreaFire.updateUserInformation(userInfo['UID'], userInfo);
    }
  }

  void _showReauthenticateError() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Fehler',
                style: MoreaTextStyle.title,
              ),
              content: Text(
                  'Leider hat etwas mit dem Neuanmelden nicht geklappt. Überprüfen sie das Password nochmals.'),
              actions: <Widget>[
                RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    color: MoreaColors.violett,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
              ],
            ));
  }

  Future<void> _showSignOutInformation() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Abmeldung',
                style: MoreaTextStyle.title,
              ),
              content: Text(
                  'Weil sie ihre E-Mail oder das Passwort geändert haben, werden sie nun ausgeloggt.'),
              actions: <Widget>[
                RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    color: MoreaColors.violett,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
              ],
            )).then((onValue) {
      return null;
    });
  }

  FloatingActionButtonLocation _locationFloatingActionButton() {
    if(widget.moreaFire.getPos == "Leiter"){
      return FloatingActionButtonLocation.centerDocked;
    } else {
      return FloatingActionButtonLocation.endFloat;
    }
  }
}
