import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:morea/services/utilities/user.dart';
abstract class BaseRegister {}

class Register implements BaseRegister {
  String get getPassword => _password;
  String _email,
      _pfadinamen = ' ',
      _vorname,
      _nachname,
      _alter = "[Datum auswählen]",
      _selectedstufe = 'Stufe wählen',
      _selectedverwandtschaft = 'Verwandtschaftsgrad wählen',
      _password,
      _adresse,
      _ort,
      _plz,
      _handynummer,
      _passwordneu,
      userId,
      error,
      _geschlecht = 'Bitte wählen';
  List<Map> _stufenselect = new List();
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
    try{
    if (_password.length < 6)
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Passwort muss aus mindistens 6 Zeichen bestehen"),
          ));
    else if(_password != _passwordneu)
      return  await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Passwörter sind nicht identisch"),
          ));
    else if(_geschlecht == 'Bitte wählen')
      return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Bitte Geschlecht wählen'),
            );
          });
    else if(_selectedstufe == "Stufe wählen")
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Bitte eine Stufe wählen!"),
          ));
    else return moreaUser;
    }catch(e){
      throw(e);
    }
  }
  dynamic validateParent(BuildContext context) async {
    if (_password.length < 6)
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Passwort muss aus mindistens 6 Zeichen bestehen"),
          ));
    else if(_password != _passwordneu)
      return  await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Passwörter sind nicht identisch"),
          ));
    else if(_geschlecht == 'Bitte wählen')
      return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Bitte Geschlecht wählen'),
            );
          });
    else if(_selectedverwandtschaft == "Verwandtschaftsgrad wählen")
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Bitte eine Stufe wählen!"),
          ));
    else return moreaUser;
  }
  dynamic validateParentRegistersChild(BuildContext context)async{
     if(_geschlecht == 'Bitte wählen')
      return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Bitte Geschlecht wählen'),
            );
          });
    else if(_selectedstufe == "Stufe wählen")
      return await showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text("Bitte eine Stufe wählen!"),
          ));
    else return moreaUser;
  }
  Widget registerParentWidget(BuildContext context, Function setState){
        return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          registerSection(icon: Icon(Icons.person), widgets: [
            registerVorName(),
            registerNachName(),
            registerGeschlecht(setState),
            //TODO Braucht es wirklich Geburtstag der Eltern?
            registerGeburtsTag(context, setState),
            registerVerwandtschaft(setState)
          ]),
          registerSection(icon: Icon(Icons.home), widgets: [
            registerAdresse(),
            registerPLZandOrt()
          ]),
          registerSection(icon: Icon(Icons.phone), widgets: [registerHandyNummer()]),
          registerSection(icon: Icon(Icons.email), widgets: [registerEmail()]),
          registerSection(icon: Icon(Icons.vpn_key), widgets: [registerPassword(),registerPasswordNew()]),
          
          SizedBox(
            height: 24,
          )
        ],
      ),
    );
  }
  Widget registerTeilnehmerWidget(BuildContext context, Function setState) {
    return FutureBuilder(
      future: docSnapAbteilung,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap){
        if(!snap.hasData)
          return simpleMoreaLoadingIndicator();
        this._stufenselect = new List<Map>.from(snap.data[groupMapSubgroup]);
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
            registerSection(icon: Icon(Icons.home), widgets: [
              registerAdresse(),
              registerPLZandOrt()
            ]),
            registerSection(icon: Icon(Icons.phone), widgets: [registerHandyNummer()]),
            registerSection(icon: Icon(Icons.email), widgets: [registerEmail()]),
            registerSection(icon: Icon(Icons.vpn_key), widgets: [registerPassword(), registerPasswordNew()]),
            
            SizedBox(
              height: 24,
            )
          ],
        ),
    );});
    }
    Widget parentRegisterNewChild(setState){
      return FutureBuilder(
        future: docSnapAbteilung,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap){
          if(!snap.hasData)
          return simpleMoreaLoadingIndicator();
        this._stufenselect = new List<Map>.from(snap.data[groupMapSubgroup]);
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
    Widget registerSection({
      @required Icon icon,
      @required List<Widget> widgets
    }){
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
                      child: Column(
                        children: widgets
                      )
                    ),
                  )
                ],
              ),
            );
    }
    Widget registerPfadiName(){
      return new TextFormField(
        decoration: new InputDecoration(
          border: UnderlineInputBorder(),
          filled: true,
          labelText: 'Pfadinamen',
        ),
        onSaved: (value) => moreaUser.pfadiName = value,
      );
    }
    Widget registerVorName(){
      return new TextFormField(
        decoration: new InputDecoration(
            border: UnderlineInputBorder(),
            filled: true,
            labelText: 'Vorname'),
        validator: (value) => value.isEmpty
            ? 'Vornamen darf nicht leer sein'
            : null,
        keyboardType: TextInputType.text,
        onSaved: (value) => moreaUser.vorName = value,
      );
    }
    Widget registerNachName(){
      return new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              labelText: 'Nachname'),
          validator: (value) => value.isEmpty
              ? 'Nachname darf nicht leer sein'
              : null,
          keyboardType: TextInputType.text,
          onSaved: (value) => moreaUser.nachName = value,
                        );
    }
    Widget registerGeschlecht(setState){
      return Column(
        children: <Widget>[
          divider(),
          new Container(
            padding: EdgeInsets.only(left: 12),
            width: 1000,
            color: Colors.grey[200],
            child: new DropdownButton<String>(
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
                  _geschlecht = newVal;
                  setState();
                }),
          ),
        ],
      );
    }
    Widget registerGeburtsTag(BuildContext context, Function setState){
      return Column(
        children:
        [
          divider(),
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
                              .add(new Duration(days: -365 * 100)),
                          maxTime: DateTime.now()
                              .add(new Duration(days: -365 * 3)),
                          onConfirm: (date) {
                            moreaUser.geburtstag =
                                DateFormat('dd.MM.yyy', 'de')
                                    .format(date)
                                    .toString();
                            _alter = DateFormat('dd.MM.yyy', 'de')
                                .format(date)
                                .toString();
                          },
                          currentTime: DateTime.now(),
                          locale: LocaleType.de);

                      setState();
                    },
                  )
                ],
              ),
            ),]
      );
    }
    Widget registerStufe(Function setState){
      return Column(
        children: [
          divider(),
          Container(
            padding: EdgeInsets.only(left: 12),
            width: 1000,
            color: Colors.grey[200],
            child: new DropdownButton<String>(
              underline: SizedBox(),
                items: _stufenselect.map((Map group) {
                  return new DropdownMenuItem<String>(
                    value: group[userMapgroupID],
                    child: new Text(group[groupMapgroupNickName]),
                  );
                }).toList(),
                hint: Text(_selectedstufe),
                onChanged: (newVal) {
                  _selectedstufe = convMiDatatoWebflow(newVal);
                  moreaUser.groupID = newVal;
                  setState();
                }),
          )
        ]
      );
    }
    Widget registerVerwandtschaft(Function setState){
      return Column(
        children: <Widget>[
          divider(),
          Container(
                  padding: EdgeInsets.only(left: 12),
                  width: 1000,
                  color: Colors.grey[200],
                  child: new DropdownButton<String>(
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
                ),
        ],
      );
    }
  Widget registerAdresse(){
    return new TextFormField(
      decoration: new InputDecoration(
          border: UnderlineInputBorder(),
          filled: true,
          labelText: 'Adresse'),
      keyboardType: TextInputType.text,
      onSaved: (value) => moreaUser.adresse = value,
    );
  }
  Widget registerPLZandOrt(){
    return new Row(
      children: <Widget>[
        Expanded(
            child: new TextFormField(
          decoration: new InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              labelText: 'PLZ'),
          keyboardType: TextInputType.number,
          onSaved: (value) => moreaUser.plz = value,
        )),
        Expanded(
          child: new TextFormField(
            decoration: new InputDecoration(
                border: UnderlineInputBorder(),
                filled: true,
                labelText: 'Ort'),
            keyboardType: TextInputType.text,
            onSaved: (value) => moreaUser.ort = value,
          ),
        ),
      ],
    );
  }
Widget registerHandyNummer(){
  return new TextFormField(
    decoration: new InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        labelText: 'Handynummer'),
    validator: (value) => value.isEmpty
        ? 'Handynummer darf nicht leer sein'
        : null,
    keyboardType: TextInputType.phone,
    onSaved: (value) => moreaUser.handynummer = value,
  );
}
Widget registerEmail(){
  return new TextFormField(
    decoration:
        new InputDecoration(filled: true, labelText: 'Email'),
    validator: (value) =>
        value.isEmpty ? 'Email darf nicht leer sein' : null,
    keyboardType: TextInputType.emailAddress,
    onSaved: (value) => moreaUser.email = value,
  );
}
Widget registerPassword(){
  return new TextFormField(
    decoration: new InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        labelText: 'Passwort'),
    validator: (value) => value.isEmpty
        ? 'Passwort darf nicht leer sein'
        : null,
    obscureText: true,
    onSaved: (value) => _password = value,
  );
}
Widget registerPasswordNew(){
  return new TextFormField(
    decoration: new InputDecoration(
        border: UnderlineInputBorder(),
        filled: true,
        labelText: 'Passwort erneut eingeben'),
    validator: (value) => value.isEmpty
        ? 'Passwort darf nicht leer sein'
        : null,
    obscureText: true,
    onSaved: (value) => _passwordneu = value,
  );
} 
Widget divider(){
  return Container(
            color: Colors.grey[700],
            height: 0.9,
            width: 1000,
          );
}                          
    
                        
                      
}
