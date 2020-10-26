import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/Group/group_data.dart';
import 'package:morea/services/user.dart';
import 'package:morea/services/utilities/moreaInputValidator.dart';

abstract class BaseRegister {}

class Register implements BaseRegister {
  String get getPassword => _password;
  String _alter = "[Datum auswählen]",
      _selectedstufe = 'Stufe wählen',
      _selectedverwandtschaft = 'Verwandtschaftsgrad wählen',
      _password,
      _passwordneu,
      userId,
      error,
      _geschlecht = 'Geschlecht wählen';
  GroupData groupdata;
  List<String> _verwandtschaft = [
    'Mutter',
    'Vater',
    'Erziehungsberechtigter',
    'Erziehungsberechtigte'
  ];
  User moreaUser;
  Future<DocumentSnapshot> docSnapAbteilung;

  Register({@required this.moreaUser, @required this.docSnapAbteilung});

  validateTeilnehmer(BuildContext context) async {
    try {
      if (_password.length < 6)
        return await showDialog(
            context: context,
            child: new AlertDialog(
              title:
                  new Text("Passwort muss aus mindistens 6 Zeichen bestehen"),
            ));
      else if (_password != _passwordneu)
        return await showDialog(
            context: context,
            child: new AlertDialog(
              title: new Text("Passwörter sind nicht identisch"),
            ));
      else if (_geschlecht == 'Bitte wählen')
        return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Bitte Geschlecht wählen'),
              );
            });
      else if (_selectedstufe == "Stufe wählen")
        return await showDialog(
            context: context,
            child: new AlertDialog(
              title: new Text("Bitte eine Stufe wählen!"),
            ));
      else
        return moreaUser;
    } catch (e) {
      throw (e);
    }
  }

  dynamic validateParent(BuildContext context) async {
    if (_password.length < 6)
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Passwort muss aus mindistens 6 Zeichen bestehen"),
          ));
    else if (_password != _passwordneu)
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Passwörter sind nicht identisch"),
          ));
    else if (_geschlecht == 'Bitte wählen')
      return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Bitte Geschlecht wählen'),
            );
          });
    else if (_selectedverwandtschaft == "Verwandtschaftsgrad wählen")
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Bitte eine Stufe wählen!"),
          ));
    else
      return moreaUser;
  }

  dynamic validateParentRegistersChild(BuildContext context) async {
    if (_geschlecht == 'Bitte wählen')
      return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Bitte Geschlecht wählen'),
            );
          });
    else if (_selectedstufe == "Stufe wählen")
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Bitte eine Stufe wählen!"),
          ));
    else
      return moreaUser;
  }

  dynamic validateUpgradeChild(BuildContext context) async {
    if (_password.length < 6)
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Passwort muss aus mindistens 6 Zeichen bestehen"),
          ));
    else if (_password != _passwordneu)
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Passwörter sind nicht identisch"),
          ));
    else
      return moreaUser;
  }

  Widget registerParentWidget(BuildContext context, Function setState,
      bool mailchimp, Function changeMailchimp) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          registerSection(icon: Icon(Icons.person), widgets: [
            registerVorName(),
            registerNachName(),
            registerGeschlecht(setState),
            registerVerwandtschaft(setState)
          ]),
          registerSection(
              icon: Icon(Icons.home),
              widgets: [registerAdresse(), registerPLZandOrt()]),
          registerSection(
              icon: Icon(Icons.phone), widgets: [registerHandyNummer()]),
          registerSection(icon: Icon(Icons.email), widgets: [registerEmail()]),
          registerSection(
              icon: Icon(Icons.vpn_key),
              widgets: [registerPassword(), registerPasswordNew()]),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: CheckboxListTile(
              title: Text(
                'Ich akzeptiere, dass ich in den E-Mail-Verteiler aufgenommen werde.',
                style: MoreaTextStyle.normal,
              ),
              value: mailchimp,
              onChanged: (bool value) {
                mailchimp = value;
                changeMailchimp(mailchimp);
                print(mailchimp);
              },
            ),
          ),
          SizedBox(
            height: 24,
          )
        ],
      ),
    );
  }

  Widget registerTeilnehmerWidget(BuildContext context, Function setState,
      bool mailchimp, Function changeMailchimp) {
    return FutureBuilder(
        future: docSnapAbteilung,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
          if (!snap.hasData) return simpleMoreaLoadingIndicator();
          print("type= " + snap.data.data.runtimeType.toString());
          Map<String, dynamic> groupData2 = snap.data.data();
          this.groupdata = new GroupData(groupData: groupData2);

          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                registerSection(icon: Icon(Icons.person), widgets: [
                  registerPfadiName(),
                  registerVorName(),
                  registerNachName(),
                  registerGeschlecht(setState),
                  registerGeburtsTag(context, setState),
                  registerStufe(setState)
                ]),
                registerSection(
                    icon: Icon(Icons.home),
                    widgets: [registerAdresse(), registerPLZandOrt()]),
                registerSection(
                    icon: Icon(Icons.phone), widgets: [registerHandyNummer()]),
                registerSection(
                    icon: Icon(Icons.email), widgets: [registerEmail()]),
                registerSection(
                    icon: Icon(Icons.vpn_key),
                    widgets: [registerPassword(), registerPasswordNew()]),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CheckboxListTile(
                    title: Text(
                      'Ich akzeptiere, dass ich in den E-Mail-Verteiler aufgenommen werde.',
                      style: MoreaTextStyle.normal,
                    ),
                    value: mailchimp,
                    onChanged: (bool value) {
                      mailchimp = value;
                      changeMailchimp(mailchimp);
                      print(mailchimp);
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                )
              ],
            ),
          );
        });
  }

  Widget parentRegisterNewChild(setState) {
    return FutureBuilder(
      future: docSnapAbteilung,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
        if (!snap.hasData) return simpleMoreaLoadingIndicator();
        this.groupdata = new GroupData(groupData: snap.data.data());
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              registerSection(icon: Icon(Icons.person), widgets: [
                registerPfadiName(),
                registerVorName(),
                registerNachName(),
                registerGeschlecht(setState),
                registerGeburtsTag(context, setState),
                registerStufe(setState)
              ]),
              SizedBox(
                height: 24,
              )
            ],
          ),
        );
      },
    );
  }

  Widget parentUpgradeChild() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          registerSection(
              icon: Icon(Icons.person), widgets: [registerHandyNummer()]),
          registerSection(icon: Icon(Icons.email), widgets: [registerEmail()]),
          registerSection(
              icon: Icon(Icons.vpn_key),
              widgets: [registerPassword(), registerPasswordNew()]),
          SizedBox(
            height: 24,
          )
        ],
      ),
    );
  }

  Widget registerSection(
      {@required Icon icon, @required List<Widget> widgets}) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: icon,
          ),
          Expanded(
            flex: 9,
            child: Container(
                alignment: Alignment.center, //
                decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.black, width: 2),
                  borderRadius: new BorderRadius.all(
                    Radius.circular(4.0),
                  ),
                ),
                child: Column(children: widgets)),
          )
        ],
      ),
    );
  }

  Widget registerPfadiName() {
    return new TextFormField(
      decoration: new InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        labelText: 'Pfadiname',
      ),
      onSaved: (value) => moreaUser.pfadiName = value,
    );
  }

  Widget registerVorName() {
    return new TextFormField(
      decoration: new InputDecoration(
          border: UnderlineInputBorder(), filled: true, labelText: 'Vorname'),
      validator: (value) =>
          value.isEmpty ? 'Vornamen darf nicht leer sein' : null,
      keyboardType: TextInputType.text,
      onSaved: (value) => moreaUser.vorName = value,
    );
  }

  Widget registerNachName() {
    return new TextFormField(
      decoration: new InputDecoration(
          border: UnderlineInputBorder(), filled: true, labelText: 'Nachname'),
      validator: (value) =>
          value.isEmpty ? 'Nachname darf nicht leer sein' : null,
      keyboardType: TextInputType.text,
      onSaved: (value) => moreaUser.nachName = value,
    );
  }

  Widget registerGeschlecht(setState) {
    return Column(
      children: <Widget>[
        divider(),
        new Container(
          padding: EdgeInsets.only(left: 12),
          width: 1000,
          height: 55,
          color: Colors.grey[200],
          child: Center(
            child: Row(
              children: <Widget>[
                new DropdownButton<String>(
                    underline: SizedBox(),
                    items: [
                      DropdownMenuItem(
                          value: "Weiblich", child: Text('weiblich')),
                      DropdownMenuItem(
                          value: 'Männlich', child: Text('männlich'))
                    ],
                    hint: Text(_geschlecht),
                    onChanged: (newVal) {
                      moreaUser.geschlecht = newVal;
                      if (newVal == 'Weiblich') {
                        _geschlecht = 'weiblich';
                      } else {
                        _geschlecht = 'männlich';
                      }
                      setState();
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget registerGeburtsTag(BuildContext context, Function setState) {
    return Column(children: [
      divider(),
      Container(
        padding: EdgeInsets.only(left: 12),
        color: Colors.grey[200],
        height: 55,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: new Text(
                "Geburtstag",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            Expanded(
              flex: 1,
              child: new FlatButton(
                child: Text(_alter,
                    style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                onPressed: () async {
                  await DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      theme: DatePickerTheme(
                          doneStyle: TextStyle(
                              color: MoreaColors.violett,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      minTime:
                          DateTime.now().add(new Duration(days: -365 * 100)),
                      maxTime: DateTime.now().add(new Duration(days: -365 * 3)),
                      onConfirm: (date) {
                    moreaUser.geburtstag =
                        DateFormat('dd.MM.yyy', 'de').format(date).toString();
                    _alter =
                        DateFormat('dd.MM.yyy', 'de').format(date).toString();
                  }, currentTime: DateTime.now(), locale: LocaleType.de);

                  setState();
                },
              ),
            )
          ],
        ),
      ),
    ]);
  }

  Widget registerStufe(Function setState) {
    return Column(children: [
      divider(),
      Container(
        padding: EdgeInsets.only(left: 12),
        width: 1000,
        height: 55,
        color: Colors.grey[200],
        child: Center(
          child: Row(
            children: <Widget>[
              new DropdownButton<String>(
                  underline: SizedBox(),
                  items: this
                      .groupdata
                      .groupOption
                      .groupLowerClass
                      .values
                      .map((GroupLowerHirarchyEntry entry) =>
                          DropdownMenuItem<String>(
                              value: entry.groupID,
                              child: Text(entry.groupNickName)))
                      .toList(),
                  hint: Text(_selectedstufe),
                  onChanged: (newVal) {
                    _selectedstufe = this
                        .groupdata
                        .groupOption
                        .groupLowerClass[newVal]
                        .groupNickName;
                    moreaUser.groupIDs = [newVal];
                    setState();
                  }),
            ],
          ),
        ),
      )
    ]);
  }

  Widget registerVerwandtschaft(Function setState) {
    return Column(
      children: <Widget>[
        divider(),
        Container(
          padding: EdgeInsets.only(left: 12),
          width: 1000,
          height: 55,
          color: Colors.grey[200],
          child: Center(
            child: Row(
              children: <Widget>[
                new DropdownButton<String>(
                    underline: SizedBox(),
                    items: _verwandtschaft.map((String val) {
                      return new DropdownMenuItem<String>(
                        value: val,
                        child: new Text(val),
                      );
                    }).toList(),
                    hint: Text(_selectedverwandtschaft),
                    onChanged: (newVal) {
                      _selectedverwandtschaft = newVal;
                      moreaUser.pos = newVal;
                      setState();
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget registerAdresse() {
    return new TextFormField(
      decoration: new InputDecoration(
          border: UnderlineInputBorder(), filled: true, labelText: 'Adresse'),
      keyboardType: TextInputType.text,
      onSaved: (value) => moreaUser.adresse = value,
      validator: (value) => value.isEmpty ? 'Bitte nicht leer lassen' : null,
    );
  }

  Widget registerPLZandOrt() {
    return new Row(
      children: <Widget>[
        Expanded(
            child: new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(), filled: true, labelText: 'PLZ'),
          keyboardType: TextInputType.number,
          onSaved: (value) => moreaUser.plz = value,
          validator: (value) {
            if (value.isEmpty) {
              return 'Bitte nicht leer lassen';
            } else if (!MoreaInputValidator.number(value)) {
              return 'Bitte gülitge PLZ verwenden';
            } else {
              return null;
            }
          },
        )),
        Expanded(
          child: new TextFormField(
            decoration: new InputDecoration(
                border: UnderlineInputBorder(), filled: true, labelText: 'Ort'),
            keyboardType: TextInputType.text,
            onSaved: (value) => moreaUser.ort = value,
            validator: (value) =>
                value.isEmpty ? 'Bitte nicht leer lassen' : null,
          ),
        ),
      ],
    );
  }

  Widget registerHandyNummer() {
    return new TextFormField(
      decoration: new InputDecoration(
          border: UnderlineInputBorder(),
          filled: true,
          helperText: 'Format "+4179xxxxxxx" oder "004179xxxxxxx"',
          labelText: 'Handynummer'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Bitte nicht leer lassen';
        } else if (!MoreaInputValidator.phoneNumber(value)) {
          return 'Bitte gültige Telefonnummer verwenden';
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.phone,
      onSaved: (value) => moreaUser.handynummer = value,
    );
  }

  Widget registerEmail() {
    return new TextFormField(
      decoration: new InputDecoration(filled: true, labelText: 'Email'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Bitte nicht leer lassen';
        } else if (!MoreaInputValidator.email(value)) {
          return 'Bitte gültige E-Mail verwenden';
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) => moreaUser.email = value,
    );
  }

  Widget registerPassword() {
    return new TextFormField(
      decoration: new InputDecoration(
          border: UnderlineInputBorder(), filled: true, labelText: 'Passwort'),
      validator: (value) =>
          value.isEmpty ? 'Passwort darf nicht leer sein' : null,
      obscureText: true,
      onSaved: (value) => _password = value,
    );
  }

  Widget registerPasswordNew() {
    return new TextFormField(
      decoration: new InputDecoration(
          border: UnderlineInputBorder(),
          filled: true,
          labelText: 'Passwort erneut eingeben'),
      validator: (value) =>
          value.isEmpty ? 'Passwort darf nicht leer sein' : null,
      obscureText: true,
      onSaved: (value) => _passwordneu = value,
    );
  }

  Widget divider() {
    return Container(
      color: Colors.grey[700],
      height: 0.9,
      width: 1000,
    );
  }
}
