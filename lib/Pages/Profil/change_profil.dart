import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:morea/Pages/Profil/change_phone_number.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/cloud_functions.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/mailchimp_api_manager.dart';

import 'change_address.dart';
import 'change_email.dart';
import 'change_name.dart';
import 'change_password.dart';

class ChangeProfile extends StatefulWidget {
  final auth;
  final MoreaFirebase moreaFire;
  final Map<String, Function> navigationMap;
  final Function updateProfile;
  final CrudMedthods crud0;

  ChangeProfile(
      {@required this.auth,
      @required this.moreaFire,
      @required this.navigationMap,
      @required this.updateProfile,
      @required this.crud0});

  @override
  _ChangeProfileState createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile>
    with TickerProviderStateMixin {
  Map userInfo;
  List nachrichtenGruppen = [];
  Auth auth0 = Auth();
  TextEditingController password = TextEditingController();
  final _passwordKey = GlobalKey<FormState>();
  String oldEmail;
  String newPassword;
  MailChimpAPIManager mailChimpAPIManager = MailChimpAPIManager();
  MoreaLoading moreaLoading;
  bool loading = true;

  _ChangeProfileState();

  @override
  void initState() {
    super.initState();
    moreaLoading = MoreaLoading(this);
    this.userInfo = widget.moreaFire.getUserMap;
    this.oldEmail = userInfo['Email'];
    loading = false;
  }

  @override
  void dispose() {
    password.dispose();
    newPassword = null;
    moreaLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this.userInfo['Pfadinamen'] == null) {
      this.userInfo['Pfadinamen'] = '';
    }
    if (loading) {
      return Container(
        color: Colors.white,
        child: moreaLoading.loading(),
      );
    } else {
      return Scaffold(
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
                  ListTile(
                    title: Text(
                      'Name',
                      style: MoreaTextStyle.lable,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        userInfo['Pfadinamen'] == ''
                            ? userInfo['Vorname'] + ' ' + userInfo['Nachname']
                            : userInfo['Vorname'] +
                                ' ' +
                                userInfo['Nachname'] +
                                ' v/o ' +
                                userInfo['Pfadinamen'],
                        style: MoreaTextStyle.subtitle,
                      ),
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
                    contentPadding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 5,
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
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            userInfo['Adresse'],
                            style: MoreaTextStyle.subtitle,
                          ),
                          Text(
                            userInfo['PLZ'] + ' ' + userInfo['Ort'],
                            style: MoreaTextStyle.subtitle,
                          )
                        ],
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
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
                        'E-Mail-Adresse',
                        style: MoreaTextStyle.lable,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          userInfo['Email'],
                          style: MoreaTextStyle.subtitle,
                        ),
                      ),
                      contentPadding: EdgeInsets.only(
                          left: 15, right: 15, bottom: 5, top: 5),
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
                      'Handynummer',
                      style: MoreaTextStyle.lable,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        userInfo['Handynummer'],
                        style: MoreaTextStyle.subtitle,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
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
                      'Geschlecht',
                      style: MoreaTextStyle.lable,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        userInfo['Geschlecht'],
                        style: MoreaTextStyle.subtitle,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                    ),
                    onTap: () => _changeGeschlecht(),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        thickness: 1,
                        color: Colors.black26,
                      )),
                  userInfo.containsKey("Geburtstag")
                      ? Column(children: [
                          ListTile(
                            title: Text(
                              'Geburtstag',
                              style: MoreaTextStyle.lable,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                userInfo['Geburtstag'],
                                style: MoreaTextStyle.subtitle,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 5, top: 5),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                            onTap: () => _changeGeburtstag(),
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Divider(
                                thickness: 1,
                                color: Colors.black26,
                              )),
                        ])
                      : Container(),
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
                  Padding(padding: EdgeInsets.only(top: 20)),
                  Center(
                      child: moreaFlatRedButton('ACCOUNT LÖSCHEN',
                          () => this.deleteaccount(context))),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                  )
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(
          title: Text('Profil ändern'),
        ),
      );
    }
  }

  void _signedOut() async {
    try {
      await widget.auth.signOut();
      Navigator.of(context).pop();
      widget.navigationMap[signedOut]();
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

  void _changeGeschlecht() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Geschlecht ändern'),
            content: DropdownButton<String>(
                items: [
                  DropdownMenuItem(value: "Weiblich", child: Text('weiblich')),
                  DropdownMenuItem(value: 'Männlich', child: Text('männlich'))
                ],
                hint: Text(this.userInfo['Geschlecht']),
                onChanged: (newVal) {
                  this.userInfo['Geschlecht'] = newVal;
                  this.setState(() {});
                  Navigator.of(context).pop();
                }),
            actions: <Widget>[
              moreaRaisedIconButton(
                  'Abbrechen',
                  this.navigatorPop,
                  Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 15,
                  ))
            ],
          );
        });
  }

  void navigatorPop() {
    Navigator.of(context).pop();
  }

  void _changeGeburtstag() async {
    await DatePicker.showDatePicker(context,
        showTitleActions: true,
        theme: DatePickerTheme(
            doneStyle: TextStyle(
                color: MoreaColors.violett,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        minTime: DateTime.now().add(new Duration(days: -365 * 100)),
        maxTime: DateTime.now().add(new Duration(days: -365 * 3)),
        onConfirm: (date) {
      userInfo['Geburtstag'] =
          DateFormat('dd.MM.yyy', 'de').format(date).toString();
    },
        currentTime: DateTime.now().add(Duration(days: -365 * 4)),
        locale: LocaleType.de);

    setState(() {});
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
                moreaRaisedIconButton("Abbrechen", () {
                  password.clear();
                  Navigator.of(context).pop();
                },
                    Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 16,
                    )),
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
                        List<String> groupIDs =
                            List<String>.from(userInfo['groupIDs']);
                        await mailChimpAPIManager.updateUserInfo(
                            userInfo['Email'],
                            userInfo['Vorname'],
                            userInfo['Nachname'],
                            userInfo['Geschlecht'],
                            groupIDs,
                            widget.moreaFire);
                        if (oldEmail != userInfo['Email'] ||
                            newPassword != null) {
                          _showSignOutInformation().then((onValue) {
                            Navigator.of(context).pop();
                            _signedOut();
                          });
                        } else {
                          widget.updateProfile();
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
    setState(() {
      loading = true;
    });
    if (oldEmail != userInfo['Email'] || newPassword != null) {
      setState(() {
        loading = false;
      });
      _showReauthenticate(oldEmail);
    } else {
      await widget.moreaFire.updateUserInformation(userInfo['UID'], userInfo);
      List<String> groupIDs = List<String>.from(userInfo['groupIDs']);
      await mailChimpAPIManager.updateUserInfo(
          userInfo['Email'],
          userInfo['Vorname'],
          userInfo['Nachname'],
          userInfo['Geschlecht'],
          groupIDs,
          widget.moreaFire);
      setState(() {
        loading = false;
      });
      widget.updateProfile();
      Navigator.pop(context);
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

  void deleteaccount(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Achtung',
              style: MoreaTextStyle.warningTitle,
            ),
            content: Text(
                'Du bist dabei dein Account vollständig zu löschen.\nBist du sicher, dass du fortfahren willst?'),
            actions: <Widget>[
              moreaFlatButton('NEIN', () => Navigator.of(context).pop()),
              moreaFlatRedButton('JA', this.delete)
            ],
          );
        });
  }

  void delete() async {
    Navigator.of(context).pop();
    setState(() {
      this.loading = true;
    });
    if (this.userInfo[userMapEltern] != null) {
      for (var elternUID in this.userInfo[userMapEltern].keys.toList()) {
        var elternMap =
            (await widget.crud0.getDocument(pathUser, elternUID)).data();
        elternMap[userMapKinder].remove(this.userInfo[userMapUID]);
        await widget.moreaFire
            .updateUserInformation(elternMap[userMapUID], elternMap);
      }
    }
    if (this.userInfo[userMapKinder] != null) {
      for (var childUID in this.userInfo[userMapKinder].keys.toList()) {
        Map childMap =
            (await widget.crud0.getDocument(pathUser, childUID)).data();
        if (childMap[userMapChildUID] == null) {
          childMap[userMapEltern].remove(this.userInfo[userMapUID]);
          await widget.moreaFire
              .updateUserInformation(childMap[userMapUID], childMap);
        } else {
          if (childMap[userMapEltern].length == 1) {
            await callFunction(getcallable('deleteUserMap'), param: {
              'UID': childUID,
              'groupIDs': childMap[userMapGroupIDs]
            });
          } else {
            childMap[userMapEltern].remove(this.userInfo[userMapUID]);
            await widget.moreaFire.updateUserInformation(childUID, childMap);
          }
        }
      }
    }
    if (this.userInfo['UID'] == null) {
      this.userInfo['UID'] = this.userInfo['childUID'];
    }
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
    await widget.navigationMap[signedOut]();
    if (this.userInfo[userMapGroupIDs] != null) {
      await callFunction(getcallable('deleteUserMap'), param: {
        'UID': this.userInfo['UID'],
        'groupID': this.userInfo[userMapGroupIDs],
      });
    } else if (this.userInfo[userMapSubscribedGroups] != null) {
      if (this.userInfo[userMapSubscribedGroups].length == 1) {
        await callFunction(getcallable('deleteUserMap'), param: {
          'UID': this.userInfo['UID'],
          'groupID': this.userInfo[userMapSubscribedGroups][0],
        });
      } else {
        for (int i = this.userInfo[userMapSubscribedGroups].length - 1;
            i > 0;
            i--) {
          await callFunction(getcallable('desubFromGroup'), param: {
            'UID': this.userInfo[userMapUID],
            'groupID': this.userInfo[userMapSubscribedGroups][i],
          });
        }
        await callFunction(getcallable('deleteUserMap'), param: {
          'UID': this.userInfo['UID'],
          'groupID': this.userInfo[userMapSubscribedGroups][0],
        });
      }
    } else {
      await callFunction(getcallable('deleteChildMap'), param: {
        'UID': this.userInfo['UID'],
      });
    }
  }
}
