import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/mailchimp_api_manager.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/crud.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/MiData.dart';

class EditUserProfilePage extends StatefulWidget {
  EditUserProfilePage({this.profile, this.moreaFire, this.crud0});

  final MoreaFirebase moreaFire;
  final CrudMedthods crud0;
  final Map profile;

  @override
  State<StatefulWidget> createState() => new EditUserPoriflePageState();
}

class EditUserPoriflePageState extends State<EditUserProfilePage> {
  MoreaFirebase moreafire;
  CrudMedthods crud0;

  final formKey = new GlobalKey<FormState>();
  final resetkey = new GlobalKey<FormState>();

  MailChimpAPIManager mailchimpApiManager = MailChimpAPIManager();

  String _email,
      _pfadinamen = ' ',
      _vorname,
      _nachname,
      _alter = "[Datum auswählen]",
      _selectedstufe = 'Stufe wählen',
      _selectedverwandtschaft = 'Verwandtschaftsgrad wählen';
  String _password,
      _adresse,
      _ort,
      _plz,
      _handynummer,
      _passwordneu,
      userId,
      error,
      selectedrolle,
      _geschlecht,
      oldGroup;
  List<Map> _stufenselect = new List();
  List<String> _rollenselect = ['Teilnehmer', 'Leiter'];

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_selectedstufe != 'Stufe wählen') {
          Map<String, dynamic> userdata = mapUserData();
          await moreafire.updateUserInformation(userdata['UID'], userdata);
          await moreafire
              .goToNewGroup(
                  userdata['UID'],
                  (userdata[userMapPfadiName] == " ")
                      ? userdata[userMapVorName]
                      : userdata[userMapPfadiName],
                  oldGroup,
                  userdata[userMapgroupID])
              .then((onValue) => setState);
          mailchimpApiManager.updateUserInfo(_email, _vorname, _nachname, _geschlecht, _selectedstufe, moreafire);
          Navigator.pop(context);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Bitte eine Stufe wählen!'),
              );
            },
          );
        }
      } catch (e) {
        print('$e');
      }
    }
  }

  void deleteuseraccount() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          child: Text(
              'Es werden nur die Userdaten gelöscht,\num den Account komplett zu löschen,\nkontaktiere Jarvis '),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text(
                'Löschen',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                crud0.deletedocument('user', widget.profile['UID']);
                Navigator.pop(context);
              })
        ],
      ),
    );
  }

  Map mapUserData() {
    Map<String, dynamic> userInfo = widget.profile;
    userInfo[userMapPfadiName] = this._pfadinamen;
    userInfo[userMapVorName] = this._vorname;
    userInfo[userMapNachName] = this._nachname;
    userInfo[userMapAlter] = this._alter;
    userInfo[userMapgroupID] = _selectedstufe;
    userInfo[userMapAdresse] = this._adresse;
    userInfo[userMapPLZ] = this._plz;
    userInfo[userMapOrt] = this._ort;
    userInfo[userMapHandynummer] = this._handynummer;
    userInfo[userMapPos] = selectedrolle;
    userInfo[userMapEmail] = this._email;
    userInfo[userMapGeschlecht] = this._geschlecht;

    return userInfo;
  }

  @override
  void initState() {
    selectedrolle = widget.profile['Pos'];
    moreafire = widget.moreaFire;
    crud0 = widget.crud0;
    oldGroup = widget.profile[userMapgroupID];
    initSubgoup();
    super.initState();
  }

  initSubgoup() async {
    Map<String, dynamic> data =
        (await crud0.getDocument(pathGroups, "1165")).data;
    this._stufenselect = new List<Map>.from(data[groupMapSubgroup]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.profile['Vorname']),
          backgroundColor: Color(0xff7a62ff),
        ),
        body: Container(
            color: Colors.white70,
            child: new SingleChildScrollView(
              child: new Form(
                key: formKey,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: buildInputs() + buildSubmitButtons()),
              ),
            )));
  }

  List<Widget> buildInputs() {
    return [
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Icon(Icons.person),
              flex: 1,
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
                child: Column(
                  children: <Widget>[
                    new TextFormField(
                      initialValue: widget.profile['Pfadinamen'],
                      decoration: new InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        labelText: 'Pfadinamen',
                      ),
                      onSaved: (value) => _pfadinamen = value,
                    ),
                    new TextFormField(
                      initialValue: widget.profile['Vorname'],
                      decoration: new InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          labelText: 'Vorname'),
                      validator: (value) => value.isEmpty
                          ? 'Vornamen darf nicht leer sein'
                          : null,
                      keyboardType: TextInputType.text,
                      onSaved: (value) => _vorname = value,
                    ),
                    new TextFormField(
                      initialValue: widget.profile['Nachname'],
                      decoration: new InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          labelText: 'Nachname'),
                      validator: (value) => value.isEmpty
                          ? 'Nachname darf nicht leer sein'
                          : null,
                      keyboardType: TextInputType.text,
                      onSaved: (value) => _nachname = value,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 12),
                      width: 1000,
                      color: Colors.grey[200],
                      child: new DropdownButton<String>(
                          items: [
                            DropdownMenuItem(
                                value: "Weiblich", child: Text('weiblich')),
                            DropdownMenuItem(
                                value: 'Männlich', child: Text('männlich'))
                          ],
                          hint: Text(_geschlecht),
                          onChanged: (newVal) {
                            _geschlecht = newVal;
                            this.setState(() {});
                          }),
                    ),
                    Container(
                      color: Colors.grey[200],
                      height: 55,
                      width: 1000,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            "   Geburtstag",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16),
                          ),
                          new FlatButton(
                            child: Text(_alter,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 16)),
                            onPressed: () async {
                              await DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  theme: DatePickerTheme(
                                      doneStyle: TextStyle(
                                          color: MoreaColors.violett,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  minTime: DateTime.now()
                                      .add(new Duration(days: -365 * 25)),
                                  maxTime: DateTime.now()
                                      .add(new Duration(days: -365 * 3)),
                                  onConfirm: (date) {
                                _alter =
                                    DateFormat.yMd().format(date).toString();
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.de);

                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey[800],
                      height: 0.5,
                      width: 1000,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 12),
                      width: 1000,
                      color: Colors.grey[200],
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Stufe:',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.only(left: 12),
                            width: 1000,
                            color: Colors.grey[200],
                            child: new DropdownButton<String>(
                                items: _stufenselect.map((Map group) {
                                  return new DropdownMenuItem<String>(
                                    value: group[userMapgroupID],
                                    child:
                                        new Text(group[groupMapgroupNickName]),
                                  );
                                }).toList(),
                                hint: Text(_selectedstufe),
                                onChanged: (newVal) {
                                  _selectedstufe = newVal;
                                  this.setState(() {});
                                }),
                          ))
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 12),
                      width: 1000,
                      color: Colors.grey[200],
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Rolle:',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: new DropdownButton<String>(
                                items: _rollenselect.map((String val) {
                                  return new DropdownMenuItem<String>(
                                    value: val,
                                    child: new Text(val),
                                  );
                                }).toList(),
                                hint: Text(selectedrolle),
                                onChanged: (newVal) {
                                  selectedrolle = newVal;
                                  this.setState(() {});
                                }),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Icon(Icons.home),
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
                  child: Column(
                    children: <Widget>[
                      new TextFormField(
                        initialValue: widget.profile['Adresse'],
                        decoration: new InputDecoration(
                            border: UnderlineInputBorder(),
                            filled: true,
                            labelText: 'Adresse'),
                        keyboardType: TextInputType.text,
                        onSaved: (value) => _adresse = value,
                      ),
                      new Row(
                        children: <Widget>[
                          Expanded(
                              child: new TextFormField(
                            initialValue: widget.profile['PLZ'],
                            decoration: new InputDecoration(
                                border: UnderlineInputBorder(),
                                filled: true,
                                labelText: 'PLZ'),
                            keyboardType: TextInputType.text,
                            onSaved: (value) => _plz = value,
                          )),
                          Expanded(
                            child: new TextFormField(
                              initialValue: widget.profile['Ort'],
                              decoration: new InputDecoration(
                                  border: UnderlineInputBorder(),
                                  filled: true,
                                  labelText: 'Ort'),
                              keyboardType: TextInputType.text,
                              onSaved: (value) => _ort = value,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Icon(Icons.phone),
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
                child: new TextFormField(
                  initialValue: widget.profile['Handynummer'],
                  decoration: new InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      labelText: 'Handy nummer'),
                  validator: (value) =>
                      value.isEmpty ? 'Handynummer darf nicht leer sein' : null,
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => _handynummer = value,
                ),
              ),
            )
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Icon(Icons.email),
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
                child: new TextFormField(
                  initialValue: widget.profile['Email'],
                  decoration:
                      new InputDecoration(filled: true, labelText: 'Email'),
                  validator: (value) =>
                      value.isEmpty ? 'Email darf nicht leer sein' : null,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _email = value,
                ),
              ),
            )
          ],
        ),
      ),
      SizedBox(
        height: 24,
      )
    ];
  }

  List<Widget> buildSubmitButtons() {
    return [
      new RaisedButton(
        child: new Text('Ändern', style: new TextStyle(fontSize: 20)),
        onPressed: validateAndSubmit,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        color: Color(0xff7a62ff),
        textColor: Colors.white,
      ),
      new FlatButton(
        child: new Text('Person aus Datenbank löschen',
            style: new TextStyle(fontSize: 20, color: Colors.redAccent)),
        onPressed: () => {deleteuseraccount()},
      ),
      SizedBox(
        height: 15,
      )
    ];
  }
}
