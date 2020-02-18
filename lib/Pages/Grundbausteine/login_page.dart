import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/Widgets/Login/register.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/mailchimp_api_manager.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/bubble_indication_painter.dart';
import 'package:morea/services/utilities/dwi_format.dart';
import 'package:morea/services/utilities/notification.dart';
import 'package:morea/services/utilities/user.dart';
import 'datenschutz.dart';

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
  Register register;
  CrudMedthods crud0;

  final formKey = new GlobalKey<FormState>();
  final resetkey = new GlobalKey<FormState>();

  String _password;
  String error;
  FormType _formType = FormType.login;
  List<Map> _stufenselect = new List();
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
            var regDat = await register.validateTeilnehmer(context);
            if(!(regDat is User))
              return
              moreaUser = regDat;
              setState(() {
                _load = true;
              });
              CrudMedthods crud = new CrudMedthods(widget.firestore);
              await datenschutz.moreaDatenschutzerklaerung(
                  context,
                  (await crud.getDocument(pathConfig, "init"))
                      .data["Datenschutz"]);
                if (datenschutz.akzeptiert) {
                  moreaUser.pos = "Teilnehmer";
                  await moreaUser.createMoreaUser(
                      widget.auth, register.getPassword, moreafire, widget.onSignedIn);
                  await mailChimpAPIManager.updateUserInfo(
                      moreaUser.email,
                      moreaUser.vorName,
                      moreaUser.nachName,
                      moreaUser.geschlecht,
                      moreaUser.groupID,
                      moreafire);
                } else {
                  setState(() {
                    _load = false;
                  });
                  return null;
                }
                 
            break;
          case FormType.registereltern:
            var regDat = await register.validateParent(context);
            if(!(regDat is User))
              return
              moreaUser = regDat;
              setState(() {
                _load = true;
              });
                    CrudMedthods crud = new CrudMedthods(widget.firestore);
                    await datenschutz.moreaDatenschutzerklaerung(
                        context,
                        (await crud.getDocument(pathConfig, "init"))
                            .data["Datenschutz"]);
                    if (datenschutz.akzeptiert) {
                      await moreaUser.createMoreaUser(
                          widget.auth, register.getPassword, moreafire, widget.onSignedIn);
                      await mailChimpAPIManager.updateUserInfo(
                          moreaUser.email,
                          moreaUser.vorName,
                          moreaUser.nachName,
                          moreaUser.geschlecht,
                          moreaUser.groupID,
                          moreafire);
                    }
                  
            break;
        }
      } catch (e) {
        setState(() {
                _load = false;
              });
        widget.auth.displayAuthError(
            widget.auth.checkForAuthErrors(context, e), context);
        print(e);
      }
    }
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
    crud0 = new CrudMedthods(widget.firestore);
    moreaUser = new User(crud0);
    register = new Register(moreaUser: moreaUser, docSnapAbteilung: crud0.getDocument(pathGroups, "1165"));
    Map<String, dynamic> data =
        (await crud0.getDocument(pathGroups, "1165")).data;
    this._stufenselect = new List<Map>.from(data[groupMapSubgroup]);
  }
  letsSetState(){
    setState(() {
      
    });
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
                    register.registerTeilnehmerWidget(context, letsSetState),
                    Column(children: buildSubmitButtons())
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    register.registerParentWidget(context, letsSetState),
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
