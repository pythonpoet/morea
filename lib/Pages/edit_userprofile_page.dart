import 'view_userprofile_page.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';

class EditUserProfilePage extends StatefulWidget {
  EditUserProfilePage({this.profile,this.auth});

  final BaseAuth auth;
  var profile;

@override
  State<StatefulWidget> createState() => new EditUserPoriflePageState();
}

class EditUserPoriflePageState extends State<EditUserProfilePage> {
  Auth auth0 = new Auth();

  final formKey = new GlobalKey<FormState>();
  final resetkey = new GlobalKey<FormState>();

  String _email,
      _pfadinamen = ' ',
      _vorname,
      _nachname,
      _stufe,
      _selectedstufe,
      selectedrolle;
  String _password, _adresse, _ort, _plz, _handynummer, _passwordneu;
  List<String> _stufenselect = [
    'Biber',
    'Wombat (Wölfe)',
    'Nahani (Meitli)',
    'Drason (Buebe)',
    'Pios'
  ];
  List<String> _rollenselect = [
    'Teilnehmer',
    'Leiter'
  ];
  String error;

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
              var userdata=mapUserData();
              await auth0.updateUserInformation(userdata, userdata['UID']).then((onValue){
                
              });
              
            } else {
              showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: new Text("Bitte eine Stufe wählen!"),
                  ));
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
              child: Text('Es werden nur die Userdaten gelöscht,\num den Account komplett zu löschen,\nkontaktiere Jarvis '),
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Löschen',style: TextStyle(
                    color: Colors.redAccent
                  ),),
                  onPressed: () {
                    auth0.deletedocument('user', widget.profile['UID']);
                    Navigator.pop(context);
                  })
            ],
          ),
    );
  }


  Map mapUserData() {
    Map<String, dynamic> userInfo = {
      'Pfadinamen': this._pfadinamen,
      'Vorname': this._vorname,
      'Nachname': this._nachname,
      'Stufe': this._selectedstufe,
      'Adresse': this._adresse,
      'PLZ': this._plz,
      'Ort': this._ort,
      'Handynummer': this._handynummer,
      'Pos': selectedrolle,
      'UID':widget.profile['UID'],
      'Email':widget.profile['Email'],
      'devtoken':widget.profile['devtoken']
    };
    return userInfo;
  }
  @override
  void initState() {
    _selectedstufe = widget.profile['Stufe'];
    selectedrolle = widget.profile['Pos'];
    super.initState();
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
        )
        ));
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
            validator: (value) =>
                value.isEmpty ? 'Vornamen darf nicht leer sein' : null,
            keyboardType: TextInputType.text,
            onSaved: (value) => _vorname = value,
          ),
          new TextFormField(
            initialValue: widget.profile['Nachname'],
            decoration: new InputDecoration(
                border: UnderlineInputBorder(),
                filled: true,
                labelText: 'Nachname'),
            validator: (value) =>
                value.isEmpty ? 'Nachname darf nicht leer sein' : null,
            keyboardType: TextInputType.text,
            onSaved: (value) => _nachname = value,
          ),
          Container(
            padding: EdgeInsets.only(left: 12),
            width: 1000,
            color: Colors.grey[200],
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text('Stufe:',style: TextStyle(fontSize: 15),),
                ),
                Expanded(
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
                this.setState(() {});
              }),
                )
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
                  child: Text('Rolle:',style: TextStyle(fontSize: 15),),
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
                  )
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
            ),),
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
                      decoration: new InputDecoration(
                          filled: true,
                          labelText: 'Email'),
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

          
        SizedBox(height: 24,)
        
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
          child: new Text(
            'Person aus Datenbank löschen',
          style: new TextStyle(
            fontSize: 20,
            color: Colors.redAccent)),
            onPressed: () => {
              deleteuseraccount()
            },
         
        ),
        SizedBox(height: 15,)
      ];
    }
  
}