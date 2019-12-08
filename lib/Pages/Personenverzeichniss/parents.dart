import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:morea/services/utilities/child_parent_pend.dart';
import 'package:morea/services/utilities/qr_code.dart';

abstract class BaseMergeChildParent {

  
  Widget childShowQrCode(Map userMap, BuildContext context);

  void parentReadsQrCode(Map<String,dynamic> userMap);
}

class test {
  ProfilePageStatePage profilePageStatePage = new ProfilePageStatePage();
}

class MergeChildParent extends Object
    with test
    implements BaseMergeChildParent {

  QrCode qrCode = new QrCode();
  MoreaFirebase moreafire;
  CrudMedthods crud0;
  ChildParendPend childParendPend = new ChildParendPend();
  bool parentReaderror = false, allowScanner = true;
  final formKey = new GlobalKey<FormState>();

   String _email,
      _pfadinamen = ' ',
      _vorname,
      _nachname,
      _selectedstufe = 'Stufe wählen',
      _selectedverwandtschaft = 'Verwandtschaftsgrad wählen';
  String _password,
      _adresse,
      _ort,
      _plz,
      _handynummer,
      _passwordneu,
      userId,
      error;
  List<String> _stufenselect = [
    'Biber',
    'Wombat (Wölfe)',
    'Nahani (Meitli)',
    'Drason (Buebe)',
    'Pios'
  ];
  

  //ProfilePageStatePage profilePageStatePage = new ProfilePageStatePage();

  BuildContext showDialogcontext;

  MergeChildParent(Firestore firestore, ){
    this.moreafire = new MoreaFirebase(firestore);
    this.crud0 = new CrudMedthods(firestore);
  }
  Widget registernewChild(Map<String,dynamic> parentData, BuildContext context){
    return new Container(
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
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
                        child: buildRegisterTeilnehmer(context , parentData)
                      ),
                    );
                  },
                ),
              ),
              ),
              Flexible(
                flex: 1,
                child: new RaisedButton(
                child:
                    new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                onPressed: () async => {
                  profilePageStatePage.newKidakt(),
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
      )
    );
  }

  Widget childShowQrCode(Map userMap, BuildContext context) {
     Future<String> qrCodeString =childParendPend.childGenerateRequestString(Map<String,dynamic>.from(userMap));
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
                builder: (BuildContext context, snap){
                  if(snap.hasData)
                    return qrCode.generate(snap.data);
                  else
                    return Container(
                      child: moreaLoadingIndicator(),
                      height: 100,
                      width: 140,
                      
                    );
                },
              ),
              SizedBox(
                height: 40,
              ),
              new RaisedButton(
                child:
                    new Text('Abbrechen', style: new TextStyle(fontSize: 20)),
                onPressed: () async => {
                  profilePageStatePage.childaktuallisieren(),
                  profilePageStatePage.childParendPend.deleteRequest(await qrCodeString)
                  },

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

  void parentReadsQrCode(Map<String,dynamic> userMap) async {
    
    await qrCode.german_scanQR();
    if (qrCode.germanError ==
        'Um den Kopplungsvorgang mit deinem Kind abzuschliessen, scanne den Qr-Code, der im Profil deines Kindes ersichtlich ist.') {
       childParendPend.parentSendsRequestString(qrCode.qrResult, userMap);
      allowScanner = false;
      parentReaderror = false;
      profilePageStatePage.parentaktuallisieren();
    } else {
     
      parentReaderror = true;
      profilePageStatePage.parentaktuallisieren();
    }
  }

  Widget parentScannsQrCode(Map<String, dynamic> userMap) {
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
                onPressed: () => parentReadsQrCode(userMap),
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
                onPressed: () => {
                      parentReaderror = false,
                      profilePageStatePage.parentaktuallisieren()
                    },
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
   Widget buildRegisterTeilnehmer(BuildContext context, Map<String,dynamic> parentData) {
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
                              onSaved: (value) => _pfadinamen = value,
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
                                    profilePageStatePage.setProfileState();
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
                          onSaved: (value) => _email = value,
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
                child:
                    new Text('$_vorname Registrieren', style: new TextStyle(fontSize: 20)),
                onPressed: () => {
                      
                     registerChild(parentData, context)
                    },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xff7a62ff),
                textColor: Colors.white,
              ),
        ],
      ),
    );
  }
  Future<Map<String,dynamic>> mapUserData() async {
        Map<String, dynamic> userInfo = {
          userMapPfadiName: this._pfadinamen,
          userMapVorName: this._vorname,
          userMapNachName: this._nachname,
          userMapgroupID: convWebflowtoMiData(_selectedstufe),
          'Adresse': this._adresse,
          'PLZ': this._plz,
          'Ort': this._ort,
          'Pos': 'Teilnehmer',
          'UID': this.userId,
          'Email': this._email,

        };
        return userInfo;
    
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
  Future<void>registerChild(Map<String,dynamic> parentData, BuildContext context)async{
    if(validateAndSave()){
      _adresse = parentData[userMapAdresse];
      _plz = parentData[userMapPLZ];
      _ort = parentData[userMapOrt];
      Map<String,dynamic> childData = await this.mapUserData();
      await childParendPend.createChildAndPendIt(this._email, this._password, childData, parentData, context);
      return  profilePageStatePage.newKidakt();
    }
    return null;
  }
}
