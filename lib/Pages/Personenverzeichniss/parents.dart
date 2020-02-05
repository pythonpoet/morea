import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:morea/services/utilities/child_parent_pend.dart';
import 'package:morea/services/utilities/qr_code.dart';

abstract class BaseMergeChildParent {
  Widget childShowQrCode(Map userMap, BuildContext context,
      Function childaktuallisieren, Function(String) deleteRequest);

  void parentReadsQrCode(Map<String, dynamic> userMap,
      Function parentaktuallisieren, BuildContext context, Function signOut);
}

class MergeChildParent extends BaseMergeChildParent {
  QrCode qrCode = new QrCode();
  MoreaFirebase moreafire;
  CrudMedthods crud0;
  ChildParendPend childParendPend;
  bool parentReaderror = false, allowScanner = true;
  final formKey = new GlobalKey<FormState>();

  String _selectedstufe = 'Stufe wählen';
  String userId, error, _alter = "[Datum auswählen]";
  String _vorname, _nachname, _pfadiname;
  String _geschlecht = 'Bitte wählen';
  List<String> _stufenselect = [
    'Biber',
    'Wombat (Wölfe)',
    'Nahani (Meitli)',
    'Drason (Buebe)',
    'Pios'
  ];

  BuildContext showDialogcontext;

  MergeChildParent(CrudMedthods crudMedthods, MoreaFirebase moreaFirebase) {
    this.moreafire = moreaFirebase;

    this.crud0 = crudMedthods;
    this.childParendPend =
        new ChildParendPend(crud0: crud0, moreaFirebase: moreafire);
  }

  Widget registernewChild(Map<String, dynamic> parentData, BuildContext context,
      Function setProfileState, Function newKidakt, Function signOut) {
    return new Container(
        color: Colors.black.withOpacity(0.7),
        padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
        child: new Card(
          child: new Container(
            padding: EdgeInsets.all(20),
            child: new Column(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Text(
                    'Neues Kind registrieren',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: new Form(
                      key: formKey,
                      child: buildRegisterTeilnehmer(context, parentData,
                          setProfileState, newKidakt, signOut)),
                ),
              ],
            ),
          ),
        ));
  }

  Widget childShowQrCode(Map userMap, BuildContext context,
      Function childaktuallisieren, Function(String) deleteRequest) {
    Future<String> qrCodeString = childParendPend
        .childGenerateRequestString(Map<String, dynamic>.from(userMap));
    return new Container(
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(
                'Eltern/Erziehungsberechtigte koppeln',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                  'Um die Kopplung abzuschliessen, muss ein Elternteil/Erziehungsberechtigte disen Code Scannen'),
              SizedBox(
                height: 30,
              ),
              FutureBuilder(
                future: qrCodeString,
                builder: (BuildContext context, snap) {
                  if (snap.hasData)
                    return qrCode.generate(snap.data);
                  else
                    return Container(
                      child: Center(child: simpleMoreaLoadingIndicator()),
                      height: 100,
                      width: 140,
                    );
                },
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 80,
                ),
              ),
              Expanded(
                flex: 2,
                child: new RaisedButton(
                  child:
                      new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                  onPressed: () async => {
                    childaktuallisieren(),
                    deleteRequest(await qrCodeString)
                  },
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Color(0xff7a62ff),
                  textColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void parentReadsQrCode(
      Map<String, dynamic> userMap,
      Function parentaktuallisieren,
      BuildContext context,
      Function signOut) async {
    await qrCode.germanScanQR();
    if (qrCode.germanError ==
        'Um den Kopplungsvorgang mit deinem Kind abzuschliessen, scanne den Qr-Code, der im Profil deines Kindes ersichtlich ist.') {
      await childParendPend.parentSendsRequestString(qrCode.qrResult, userMap);
      allowScanner = false;
      parentReaderror = false;
      parentaktuallisieren();
    } else {
      parentReaderror = true;
      parentaktuallisieren();
    }
    showDialog(
            context: context,
            builder: (context) => AlertDialog(
                content: Text(
                    'Die App muss neu gestartet werden nachdem sie ein neues Kind verknüpft haben. Sie werden darum nun ausgeloggt.')))
        .then((onvalue) {
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
      signOut();
    });
  }

  Widget parentScannsQrCode(Map<String, dynamic> userMap,
      Function parentaktuallisieren, BuildContext context, Function signOut) {
    return new Container(
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text(
                'Eltern/Erziehungsberechtigte koppeln',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              Text(qrCode.germanError),
              SizedBox(
                height: 30,
              ),
              new RaisedButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.camera_alt),
                    SizedBox(
                      width: 5,
                    ),
                    new Text('Scannen', style: new TextStyle(fontSize: 20))
                  ],
                ),
                onPressed: () => parentReadsQrCode(
                    userMap, parentaktuallisieren, context, signOut),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xff7a62ff),
                textColor: Colors.white,
              ),
              SizedBox(
                height: 40,
              ),
              new RaisedButton(
                child:
                    new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                onPressed: () =>
                    {parentReaderror = false, parentaktuallisieren()},
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xff7a62ff),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRegisterTeilnehmer(
      BuildContext context,
      Map<String, dynamic> parentData,
      Function setProfileState,
      Function newKidakt,
      Function signOut) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
                            decoration: new InputDecoration(
                              border: UnderlineInputBorder(),
                              filled: true,
                              labelText: 'Pfadinamen',
                            ),
                            onSaved: (value) => _pfadiname = value,
                          ),
                          new TextFormField(
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
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(width: 1),
                                  top: BorderSide(width: 0.5)),
                              color: Colors.grey[200],
                            ),
                            child: new DropdownButton<String>(
                                items: [
                                  DropdownMenuItem(
                                      value: "Weiblich",
                                      child: Text('weiblich')),
                                  DropdownMenuItem(
                                      value: 'Männlich',
                                      child: Text('männlich'))
                                ],
                                hint: Text(_geschlecht),
                                onChanged: (newVal) {
                                  _geschlecht = newVal;
                                  moreafire.moreaUser.geschlecht = newVal;
                                  setProfileState();
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
                                          color: Colors.grey[500],
                                          fontSize: 16)),
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
                                      _alter = DateFormat('dd.MM.yyy', 'de')
                                          .format(date)
                                          .toString();
                                      moreafire.moreaUser.geburtstag = _alter;
                                    },
                                        currentTime: DateTime.now(),
                                        locale: LocaleType.de);
                                    setProfileState();
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
                            child: new DropdownButton<String>(
                                items: _stufenselect.map((String val) {
                                  return new DropdownMenuItem<String>(
                                    value: val,
                                    child: new Text(val),
                                  );
                                }).toList(),
                                hint: Text(_selectedstufe),
                                onChanged: (newVal) {
                                  _selectedstufe = newVal;
                                  setProfileState();
                                }),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
            new RaisedButton(
              child:
                  new Text('Registrieren', style: new TextStyle(fontSize: 20)),
              onPressed: () => {
                registerChild(parentData, context, newKidakt).then((res) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            content: Text(
                                'Die App muss neu gestartet werden nachdem sie ein neues Kind verknüpft haben. Sie werden darum nun ausgeloggt.'),
                          )).then((onval) {
                    Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    signOut();
                  });
                })
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Color(0xff7a62ff),
              textColor: Colors.white,
            ),
            RaisedButton(
              child: new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
              onPressed: () async => {
                newKidakt(),
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Color(0xff7a62ff),
              textColor: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  bool validateAndSave(context) {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      if (_geschlecht == 'Bitte wählen' ||
          _selectedstufe == 'Stufe wählen' ||
          _alter == "[Datum auswählen]") {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text('Bitte alle Felder ausfüllen/wählen'),
                ));
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  Future<void> registerChild(Map<String, dynamic> parentData,
      BuildContext context, Function newKidakt) async {
    if (validateAndSave(context)) {
      Map<String, dynamic> childUserMap = {
        userMapPfadiName: _pfadiname,
        userMapVorName: _vorname,
        userMapNachName: _nachname,
        userMapGeschlecht: _geschlecht,
        userMapGeburtstag: _alter,
        userMapgroupID: convWebflowtoMiData(_selectedstufe),
        userMapEmail: parentData[userMapEmail],
        userMapAdresse: parentData[userMapAdresse],
        userMapPLZ: parentData[userMapPLZ],
        userMapOrt: parentData[userMapOrt],
        userMapHandynummer: parentData[userMapHandynummer],
        userMapPos: 'Teilnehmer',
      };
      HttpsCallableResult results =
          await moreafire.uploadChildUserInformation(childUserMap);
      String childUID = results.data;
      Map<String, dynamic> userInfo = Map.of(moreafire.getUserMap);
      if (userInfo['Kinder'] == null) {
        userInfo['Kinder'] = {_vorname: childUID};
      } else {
        userInfo['Kinder'][_vorname] = childUID;
      }
      moreafire.updateUserInformation(
          moreafire.getUserMap[userMapUID], userInfo);
      moreafire.priviledgeEltern(convWebflowtoMiData(_selectedstufe));

//      moreafire.createUserInformation(childUserMap);
//      moreafire.moreaUser.adresse = parentData[userMapAdresse];
//      moreafire.moreaUser.plz = parentData[userMapPLZ];
//      moreafire.moreaUser.ort = parentData[userMapOrt];
//      Map<String, dynamic> childData =
//          moreafire.moreaUser.generateAndValitateUserMap();
//      await moreafire.createUserInformation(childData);
//      await childParendPend.createChildAndPendIt(moreafire.moreaUser.email,
//          this._password, childData, parentData, context);
//      return newKidakt();
    }
    return null;
  }
}
