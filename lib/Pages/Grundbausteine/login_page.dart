import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/mailchimp_api_manager.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:morea/services/utilities/bubble_indication_painter.dart';
import 'package:morea/services/utilities/dwi_format.dart';
import 'package:morea/services/utilities/user.dart';
import 'datenschutz.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn, this.firestore});

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register, registereltern }
enum authProblems { UserNotFound, PasswordNotValid, NetworkError }
enum Platform { isAndroid, isIOS }

class _LoginPageState extends State<LoginPage> {
  DWIFormat dwiFormat = new DWIFormat();
  MoreaFirebase moreafire;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  Datenschutz datenschutz = new Datenschutz();
  User moreaUser;

  final formKey = new GlobalKey<FormState>();
  final resetkey = new GlobalKey<FormState>();

  String _alter = "[Datum auswählen]",
      _selectedstufe = 'Stufe wählen',
      _selectedverwandtschaft = 'Verwandtschaftsgrad wählen',
      _password,
      _passwordneu;
  String error;
  String _geschlecht = 'Bitte wählen';
  FormType _formType = FormType.login;
  List<Map> _stufenselect = new List();
  List<String> _verwandtschaft = [
    'Mutter',
    'Vater',
    'Erziehungsberechtigter',
    'Erziehungsberechtigte'
  ];
  bool _load = false;

  PageController pageController;
  Color left = Colors.black;
  Color right = Colors.white;

  //Mailchimp
  MailChimpAPIManager mailChimpAPIManager = MailChimpAPIManager();

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  updatedevtoken() async {
    moreafire.uploadDevTocken(moreaUser.userID);
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        switch (_formType) {
          case FormType.login:
            setState(() {
              _load = true;
            });
            moreaUser.userID = await widget.auth
                .signInWithEmailAndPassword(moreaUser.email, _password);
            print('Sign in: ${moreaUser.userID}');
            if (moreaUser.userID != null) {
              moreafire.uploadDevTocken(moreaUser.userID);
              setState(() {
                _load = false;
              });
              widget.onSignedIn();
            } else {
              setState(() {
                _load = false;
              });
            }
            break;
          case FormType.register:
            if (_password.length >= 6) {
              if (_password == _passwordneu) {
                if (_selectedstufe != 'Stufe wählen') {
                  if (_geschlecht != 'Bitte wählen') {
                    setState(() {
                      _load = true;
                    });
                    await datenschutz.moreaDatenschutzerklaerung(context);
                    if (datenschutz.akzeptiert) {
                      moreaUser.geschlecht = _geschlecht;
                      moreaUser.pos = "Teilnehmer";
                      await moreaUser.createMoreaUser(
                          widget.auth, _password, moreafire, widget.onSignedIn);
                      await mailChimpAPIManager.updateUserInfo(
                          moreaUser.email,
                          moreaUser.vorName,
                          moreaUser.nachName,
                          _geschlecht,
                          moreaUser.groupID,
                          moreafire);
                    } else {
                      setState(() {
                        _load = false;
                      });
                      return null;
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Bitte Geschlecht wählen'),
                          );
                        });
                  }
                } else {
                  showDialog(
                      context: context,
                      child: new AlertDialog(
                        title: new Text("Bitte eine Stufe wählen!"),
                      ));
                }
              } else {
                showDialog(
                    context: context,
                    child: new AlertDialog(
                      title: new Text("Passwörter sind nicht identisch"),
                    ));
              }
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                          'Passwort muss aus mindestens 6 Zeichen bestehen'),
                    );
                  });
            }
            break;
          case FormType.registereltern:
            if (_password.length >= 6) {
              if (_password == _passwordneu) {
                if (_selectedverwandtschaft != "Verwandtschaftsgrad wählen") {
                  if (_geschlecht != 'Bitte wählen') {
                    setState(() {
                      _load = true;
                    });
                    await datenschutz.moreaDatenschutzerklaerung(context);
                    if (datenschutz.akzeptiert) {
                      moreaUser.geschlecht = _geschlecht;
                      moreaUser.pos = _selectedverwandtschaft;
                      await moreaUser.createMoreaUser(
                          widget.auth, _password, moreafire, widget.onSignedIn);
                      await mailChimpAPIManager.updateUserInfo(
                          moreaUser.email,
                          moreaUser.vorName,
                          moreaUser.nachName,
                          _geschlecht,
                          moreaUser.groupID,
                          moreafire);
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Bitte Geschlecht wählen'),
                          );
                        });
                  }
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Verwandtschaftsgrad wählen"),
                        );
                      });
                }
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Passwörter sind nicht identisch'),
                      );
                    });
              }
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                          'Passwort muss aus mindistens 6 Zeichen bestehen'),
                    );
                  });
            }
            break;
        }
      } catch (e) {
        widget.auth.displayAuthError(
            widget.auth.checkForAuthErrors(context, e), context);
      }
    }
    setState(() {
      _load = false;
    });
  }

  void moveToRegister() {
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    setState(() {
      _formType = FormType.login;
    });
  }

  void passwortreset() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: new InputDecoration(
                  labelText: 'Passwort zurücksetzen',
                  hintText: 'z.B. maxi@stinkt.undso',
                ),
                onChanged: (String value) {
                  this.moreaUser.email = value;
                },
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('Zurücksetzen'),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    child: new AlertDialog(
                      title: new Text(
                          'Sie haben ein Passwortzurücksetzungsemail auf die Emailadresse: $moreaUser.email erhalten'),
                    ));
                widget.auth.sendPasswordResetEmail(moreaUser.email);
              })
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    moreafire = new MoreaFirebase(widget.firestore);

    initSubgoup();
  }

  initSubgoup() async {
    CrudMedthods crud0 = new CrudMedthods(widget.firestore);
    moreaUser = new User(crud0);
    Map<String, dynamic> data =
        (await crud0.getDocument(pathGroups, "1165")).data;
    this._stufenselect = new List<Map>.from(data[groupMapSubgroup]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _load
        ? new Container(
            width: 70.0,
            height: 70.0,
            child: new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Center(child: new CircularProgressIndicator())),
          )
        : new Container();

    return new Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: <Widget>[
            Container(
                color: Colors.white70,
                child: new SingleChildScrollView(
                  child: new Form(
                      key: formKey,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height >= 1100.0
                            ? MediaQuery.of(context).size.height
                            : 1100.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: buildInputs(),
                        ),
                      )),
                )),
            new Align(
              child: loadingIndicator,
              alignment: FractionalOffset.center,
            ),
          ],
        ));
  }

  Widget buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
          color: Color(0xffff9262),
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: pageController),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _registerAsTeilnehmer,
                child: Text('Teilnehmer',
                    style: TextStyle(color: left, fontSize: 16.0)),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _registerAsElternteil,
                child: Text('Elternteil',
                    style: TextStyle(color: right, fontSize: 16.0)),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [
        Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                new Image(
                  height: 200,
                  image: new AssetImage('assets/images/Logo_gross_weiss.jpeg'),
                ),
                new SizedBox(
                  height: 34,
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                    labelText: 'Email',
                    border: UnderlineInputBorder(
                      borderSide: new BorderSide(width: 4, color: Colors.black),
                    ),
                  ),
                  validator: (value) =>
                      value.isEmpty ? 'Email darf nicht leer sein' : null,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => moreaUser.email = value,
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                    labelText: 'Passwort',
                    border: UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.black)),
                  ),
                  validator: (value) =>
                      value.isEmpty ? 'Passwort darf nicht leer sein' : null,
                  obscureText: true,
                  onSaved: (value) => _password = value,
                ),
                SizedBox(
                  height: 24,
                ),
                Column(
                  children: buildSubmitButtons(),
                )
              ],
            ))
      ];
    } else {
      return [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: buildMenuBar(context),
        ),
        Expanded(
          flex: 2,
          child: PageView(
            controller: pageController,
            onPageChanged: (i) {
              if (i == 0) {
                setState(() {
                  right = Colors.white;
                  left = Colors.black;
                });
              } else if (i == 1) {
                setState(() {
                  right = Colors.black;
                  left = Colors.white;
                });
              }
            },
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    buildRegisterTeilnehmer(context),
                    Column(children: buildSubmitButtons())
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    buildRegisterEltern(context),
                    Column(children: buildSubmitButtons())
                  ],
                ),
              ),
            ],
          ),
        )
      ];
    }
  }

  Widget buildRegisterEltern(BuildContext context) {
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
                              labelText: 'Vorname'),
                          validator: (value) => value.isEmpty
                              ? 'Vornamen darf nicht leer sein'
                              : null,
                          keyboardType: TextInputType.text,
                          onSaved: (value) => moreaUser.vorName = value,
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
                          onSaved: (value) => moreaUser.nachName = value,
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
                          padding: EdgeInsets.only(left: 12),
                          width: 1000,
                          color: Colors.grey[200],
                          child: new DropdownButton<String>(
                              items: _verwandtschaft.map((String val) {
                                return new DropdownMenuItem<String>(
                                  value: val,
                                  child: new Text(val),
                                );
                              }).toList(),
                              hint: Text(_selectedverwandtschaft),
                              onChanged: (newVal) {
                                _selectedverwandtschaft = newVal;
                                this.setState(() {});
                              }),
                        ),
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
                            decoration: new InputDecoration(
                                border: UnderlineInputBorder(),
                                filled: true,
                                labelText: 'Adresse'),
                            keyboardType: TextInputType.text,
                            onSaved: (value) => moreaUser.adresse = value,
                          ),
                          new Row(
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
                      decoration: new InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          labelText: 'Handy nummer'),
                      validator: (value) => value.isEmpty
                          ? 'Handynummer darf nicht leer sein'
                          : null,
                      keyboardType: TextInputType.phone,
                      onSaved: (value) => moreaUser.handynummer = value,
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
                      onSaved: (value) => moreaUser.email = value,
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
          )
        ],
      ),
    );
  }

  Widget buildRegisterTeilnehmer(BuildContext context) {
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
                          onSaved: (value) => moreaUser.pfadiName = value,
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
                          onSaved: (value) => moreaUser.vorName = value,
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
                          onSaved: (value) => moreaUser.nachName = value,
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
                                    theme: DatePickerTheme(doneStyle: TextStyle(color: MoreaColors.violett, fontSize: 16, fontWeight: FontWeight.bold) ),
                                    minTime: DateTime.now().add(new Duration(days: -365*25)),
                                    maxTime: DateTime.now().add(new Duration(days: -365*3)),
                                    onConfirm: (date) {
                                      moreaUser.geburtstag  = DateFormat('dd.MM.yyy', 'de').format(date).toString();
                                      _alter = DateFormat('dd.MM.yyy', 'de').format(date).toString();
                                    }, currentTime: DateTime.now(), locale: LocaleType.de);
          
                                  setState(() {
                                    
                                  });
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
                              items: _stufenselect.map((Map group) {
                                return new DropdownMenuItem<String>(
                                  value: group[userMapgroupID],
                                  child: new Text(group[groupMapgroupNickName]),
                                );
                              }).toList(),
                              hint: Text(_selectedstufe),
                              onChanged: (newVal) {
                                if(newVal == midatanamebiber){
                                  _selectedstufe = 'Biber';
                                } else if(newVal == midatanamewoelf){
                                  _selectedstufe = 'Wombat (Wölfe)';
                                } else if(newVal == midatanamemeitli){
                                  _selectedstufe = 'Nahani (Meitli)';
                                } else if(newVal == midatanamebuebe){
                                  _selectedstufe = 'Drason(Buebe)';
                                }
                                moreaUser.groupID = newVal;
                                this.setState(() {});
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
                            decoration: new InputDecoration(
                                border: UnderlineInputBorder(),
                                filled: true,
                                labelText: 'Adresse'),
                            keyboardType: TextInputType.text,
                            onSaved: (value) => moreaUser.adresse = value,
                          ),
                          new Row(
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
                      decoration: new InputDecoration(
                          border: UnderlineInputBorder(),
                          filled: true,
                          labelText: 'Handy nummer'),
                      validator: (value) => value.isEmpty
                          ? 'Handynummer darf nicht leer sein'
                          : null,
                      keyboardType: TextInputType.phone,
                      onSaved: (value) => moreaUser.handynummer = value,
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
                      onSaved: (value) => moreaUser.email = value,
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
          )
        ],
      ),
    );
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        new RaisedButton(
          child: new Text('Anmelden', style: new TextStyle(fontSize: 20)),
          onPressed: validateAndSubmit,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Color(0xff7a62ff),
          textColor: Colors.white,
        ),
        new FlatButton(
          child: new Text(
            'Noch kein Konto? Hier registrieren',
            style: new TextStyle(fontSize: 20),
          ),
          onPressed: moveToRegister,
        ),
        new FlatButton(
          child: new Text(
            'Passwort vergessen?',
            style: new TextStyle(fontSize: 15),
          ),
          onPressed: passwortreset,
        )
      ];
    } else {
      return [
        new RaisedButton(
          child: new Text('Registrieren', style: new TextStyle(fontSize: 20)),
          onPressed: validateAndSubmit,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Color(0xff7a62ff),
          textColor: Colors.white,
        ),
        new FlatButton(
          child: new Text(
            'Ich habe bereits ein Konto',
            style: new TextStyle(fontSize: 20),
          ),
          onPressed: moveToLogin,
        ),
      ];
    }
  }

  void _registerAsTeilnehmer() {
    pageController.animateToPage(0,
        duration: Duration(milliseconds: 700), curve: Curves.decelerate);
    _formType = FormType.register;
  }

  void _registerAsElternteil() {
    pageController?.animateToPage(1,
        duration: Duration(milliseconds: 700), curve: Curves.decelerate);
    _formType = FormType.registereltern;
  }
}
