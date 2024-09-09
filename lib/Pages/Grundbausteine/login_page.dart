import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morea/Widgets/Login/register.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/mailchimp_api_manager.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/user.dart';
import 'package:morea/services/utilities/bubble_indication_painter.dart';
import 'package:morea/services/utilities/dwi_format.dart';
import 'package:morea/services/utilities/moreaInputValidator.dart';
import 'datenschutz.dart';

class LoginPage extends StatefulWidget {
  LoginPage(
      {required this.auth, required this.onSignedIn, required this.firestore});

  final Auth auth;
  final Function onSignedIn;
  final FirebaseFirestore firestore;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register, registereltern }

enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  DWIFormat dwiFormat = new DWIFormat();
  late MoreaFirebase moreafire;
  Datenschutz datenschutz = new Datenschutz();
  late User moreaUser;
  late Register register;
  late CrudMedthods crud0;
  late MoreaLoading moreaLoading;
  final formKey = new GlobalKey<FormState>();
  final resetkey = new GlobalKey<FormState>();

  String? _password;
  FormType _formType = FormType.login;
  bool _load = false;
  bool _mailchimp = false;

  late PageController pageController;
  Color left = Colors.black;
  Color right = Colors.white;

  //Mailchimp
  MailChimpAPIManager mailChimpAPIManager = MailChimpAPIManager();

  bool validateAndSave() {
    final form = formKey.currentState!;
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
          //Login
          case FormType.login:
            //Sets Login indicator
            setState(() {
              _load = true;
            });
            //login firebase user
            moreaUser.userID = await widget.auth
                .signInWithEmailAndPassword(moreaUser.email, _password!);
            print('Sign in: ${moreaUser.userID}');
            if (moreaUser.userID != null) {
              //upload deviceToken
              moreafire.uploadDevTocken(moreaUser.userID);
              widget.onSignedIn(tutorialautostart: false);
            } else {
              setState(() {
                _load = false;
              });
            }
            break;
          case FormType.register:
            //Check if userMap is right
            var regDat = await register.validateTeilnehmer(context);
            if (!(regDat is User)) return moreaUser = regDat;
            setState(() {
              _load = true;
            });
            CrudMedthods crud = new CrudMedthods(widget.firestore);
            if (_mailchimp) {
              await datenschutz.moreaDatenschutzerklaerung(
                  context,
                  ((await crud.getDocument(pathConfig, "init")).data()!
                      as Map<String, dynamic>)["Datenschutz"]);
              if (datenschutz.akzeptiert) {
                moreaUser.pos = "Teilnehmer";
                await moreaUser.createMoreaUser(widget.auth,
                    register.getPassword, moreafire, widget.onSignedIn,
                    tutorial: true);
                await mailChimpAPIManager.updateUserInfo(
                    moreaUser.email,
                    moreaUser.vorName,
                    moreaUser.nachName,
                    moreaUser.geschlecht,
                    moreaUser.groupIDs,
                    moreafire);
              } else {
                setState(() {
                  _load = false;
                });
                return null;
              }
            } else {
              await _showMailchimpWarning(context);
              setState(() {
                _load = false;
              });
            }

            break;
          case FormType.registereltern:
            var regDat = await register.validateParent(context);
            if (!(regDat is User)) return moreaUser = regDat;
            setState(() {
              _load = true;
            });
            CrudMedthods crud = new CrudMedthods(widget.firestore);
            if (_mailchimp) {
              await datenschutz.moreaDatenschutzerklaerung(
                  context,
                  ((await crud.getDocument(pathConfig, "init")).data()!
                      as Map<String, dynamic>)["Datenschutz"]);
              if (datenschutz.akzeptiert) {
                await moreaUser.createMoreaUser(widget.auth,
                    register.getPassword, moreafire, widget.onSignedIn,
                    tutorial: true);
              } else {
                setState(() {
                  _load = false;
                });
              }
            } else {
              await _showMailchimpWarning(context);
              setState(() {
                _load = false;
              });
            }
            break;
        }
      } catch (e) {
        setState(() {
          _load = false;
        });
        widget.auth.displayAuthError(
            widget.auth.checkForAuthErrors(
                context, (e is PlatformException) ? e : null),
            context);
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
                  hintText: 'z.B. test@gmail.com',
                ),
                onChanged: (String value) {
                  this.moreaUser.email = value;
                },
              ),
            )
          ],
        ),
        actions: <Widget>[
          new TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new TextButton(
              child: const Text('Zurücksetzen'),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: new Text(
                              'Es wurde dir eine E-Mail an ${moreaUser.email} gesendet, die einen Link enthält, mit dem du dein Passwort zurücksetzen kannst.'),
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
    moreaLoading = MoreaLoading(this);
    pageController = PageController();
    moreafire = new MoreaFirebase(widget.firestore);
    initSubgoup();
  }

  initSubgoup() async {
    crud0 = new CrudMedthods(widget.firestore);
    moreaUser = new User(crud0);
    Map<String, dynamic> initDoc =
        (await crud0.getDocument(pathConfig, pathInit)).data()!
            as Map<String, dynamic>;
    register = new Register(
        moreaUser: moreaUser,
        docSnapAbteilung: crud0.getDocument(pathGroups, initDoc[mainGroupID]));
  }

  @override
  void dispose() {
    pageController.dispose();
    moreaLoading.dispose();
    super.dispose();
  }

  letsSetState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_load) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: moreaLoading.loading(),
        ),
      );
    } else {
      return new Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
          ),
          body: Container(
              color: Colors.white70,
              width: MediaQuery.of(context).size.width,
              height: (_formType == FormType.login)
                  ? MediaQuery.of(context).size.height - 117
                  : 1100,
              child: new SingleChildScrollView(
                child: new Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: buildInputs(),
                    )),
              )));
    }
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
              child: TextButton(
                style: ButtonStyle(overlayColor:
                    MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed))
                    return Colors.transparent;
                  return Colors.transparent;
                })),
                onPressed: _registerAsTeilnehmer,
                child:
                    Text(roleTN, style: TextStyle(color: left, fontSize: 14.0)),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: TextButton(
                style: ButtonStyle(overlayColor:
                    MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed))
                    return Colors.transparent;
                  return Colors.transparent;
                })),
                onPressed: _registerAsElternteil,
                child: Text(roleErziehungsperson,
                    style: TextStyle(color: right, fontSize: 14.0)),
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
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Bitte nicht leer lassen';
                    } else if (!MoreaInputValidator.email(value)) {
                      return 'Bitte gültige E-Mail verwenden';
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => moreaUser.email = value!,
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                    labelText: 'Passwort',
                    border: UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.black)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Passwort darf nicht leer sein' : null,
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
        SizedBox(
          height: 1100,
          child: Column(
            children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
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
                          register.registerTeilnehmerWidget(context,
                              letsSetState, _mailchimp, this.changeMailchimp),
                          Column(children: buildSubmitButtons())
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          register.registerParentWidget(context, letsSetState,
                              _mailchimp, this.changeMailchimp),
                          Column(children: buildSubmitButtons())
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        moreaRaisedButton('ANMELDEN', validateAndSubmit),
        moreaFlatIconButton(
            'NEU REGISTRIEREN',
            moveToRegister,
            Icon(
              Icons.create,
              color: MoreaColors.violett,
            )),
        TextButton(
          child: new Text(
            'PASSWORT VERGESSEN',
            style: MoreaTextStyle.flatButton,
          ),
          onPressed: passwortreset,
        )
      ];
    } else {
      return [
        moreaRaisedButton('REGISTRIEREN', validateAndSubmit),
        moreaFlatButton('ICH HABE BEREITS EIN KONTO', moveToLogin),
      ];
    }
  }

  void _registerAsTeilnehmer() {
    pageController.animateToPage(0,
        duration: Duration(milliseconds: 700), curve: Curves.decelerate);
    _formType = FormType.register;
  }

  void _registerAsElternteil() {
    pageController.animateToPage(1,
        duration: Duration(milliseconds: 700), curve: Curves.decelerate);
    _formType = FormType.registereltern;
  }

  Future<void> _showMailchimpWarning(context) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fehler', style: MoreaTextStyle.warningTitle),
        content: Text(
          'Damit du alle Informationen von uns bekommst, musst du dich in unseren E-Mail-Verteiler eintragen lassen.\nBitte setze in der Registrierung den ensprechende Haken',
          style: MoreaTextStyle.normal,
        ),
        actions: <Widget>[
          moreaFlatIconButton('SCHLIESSEN', () {
            Navigator.of(context).pop();
          },
              Icon(
                Icons.cancel,
                color: MoreaColors.violett,
              )),
        ],
      ),
    );
    return null;
  }

  void changeMailchimp(bool newVal) {
    setState(() {
      _mailchimp = newVal;
    });
    print(_mailchimp);
  }
}
