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

  void parentReadsQrCode(
      Map<String, dynamic> userMap, Function parentaktuallisieren);
}

class MergeChildParent extends BaseMergeChildParent {
  QrCode qrCode = new QrCode();
  MoreaFirebase moreafire;
  CrudMedthods crud0;
  ChildParendPend childParendPend;
  bool parentReaderror = false, allowScanner = true;
  final formKey = new GlobalKey<FormState>();

  String _selectedstufe = 'Stufe wählen';
  String _password, _passwordneu, userId, error, _alter = "[Datum auswählen]";
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
      Function setProfileState, Function newKidakt) {
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
                    child: LayoutBuilder(
                      builder: (BuildContext context,
                          BoxConstraints viewportConstraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: viewportConstraints.maxHeight,
                              ),
                              child: buildRegisterTeilnehmer(context,
                                  parentData, setProfileState, newKidakt)),
                        );
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: new RaisedButton(
                    child: new Text('Abbrechen',
                        style: new TextStyle(fontSize: 20)),
                    onPressed: () async => {
                      newKidakt(),
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
              Column(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 80,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: new RaisedButton(
                      child: new Text('Abbrechen',
                          style: new TextStyle(fontSize: 20)),
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
              )
            ],
          ),
        ),
      ),
    );
  }

  void parentReadsQrCode(
      Map<String, dynamic> userMap, Function parentaktuallisieren) async {
    await qrCode.germanScanQR();
    if (qrCode.germanError ==
        'Um den Kopplungsvorgang mit deinem Kind abzuschliessen, scanne den Qr-Code, der im Profil deines Kindes ersichtlich ist.') {
      childParendPend.parentSendsRequestString(qrCode.qrResult, userMap);
      allowScanner = false;
      parentReaderror = false;
      parentaktuallisieren();
    } else {
      parentReaderror = true;
      parentaktuallisieren();
    }
  }

  Widget parentScannsQrCode(
      Map<String, dynamic> userMap, Function parentaktuallisieren) {
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
                onPressed: () =>
                    parentReadsQrCode(userMap, parentaktuallisieren),
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
      Function newKidakt) {
    return Container(
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
                          onSaved: (value) =>
                              moreafire.moreaUser.pfadiName = value,
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
                          onSaved: (value) =>
                              moreafire.moreaUser.vorName = value,
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
                          onSaved: (value) =>
                              moreafire.moreaUser.nachName = value,
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
                                    _alter = DateFormat.yMd()
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
                      decoration:
                          new InputDecoration(filled: true, labelText: 'Email'),
                      validator: (value) =>
                          value.isEmpty ? 'Email darf nicht leer sein' : null,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) => moreafire.moreaUser.email = value,
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
                  child: Icon(Icons.vpn_key),
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
                              labelText: 'Password'),
                          validator: (value) => value.isEmpty
                              ? 'Passwort darf nicht leer sein'
                              : null,
                          obscureText: true,
                          onSaved: (value) => _password = value,
                        ),
                        new TextFormField(
                          decoration: new InputDecoration(
                              border: UnderlineInputBorder(),
                              filled: true,
                              labelText: 'Password erneut eingeben'),
                          validator: (value) => value.isEmpty
                              ? 'Passwort darf nicht leer sein'
                              : null,
                          obscureText: true,
                          onSaved: (value) => _passwordneu = value,
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
            child: new Text('${moreafire.moreaUser.vorName} Registrieren',
                style: new TextStyle(fontSize: 20)),
            onPressed: () => {registerChild(parentData, context, newKidakt)},
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Color(0xff7a62ff),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<void> registerChild(Map<String, dynamic> parentData,
      BuildContext context, Function newKidakt) async {
    if (validateAndSave()) {
      moreafire.moreaUser.adresse = parentData[userMapAdresse];
      moreafire.moreaUser.plz = parentData[userMapPLZ];
      moreafire.moreaUser.ort = parentData[userMapOrt];
      Map<String, dynamic> childData =
          moreafire.moreaUser.generateAndValitateUserMap();
      await moreafire.createUserInformation(childData);
      await childParendPend.createChildAndPendIt(moreafire.moreaUser.email,
          this._password, childData, parentData, context);
      return newKidakt();
    }
    return null;
  }
}
