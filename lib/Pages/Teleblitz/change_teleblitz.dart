import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class ChangeTeleblitz extends StatefulWidget {
  ChangeTeleblitz({this.auth, this.crud, this.onSignedOut, this.stufe, this.firestore, @required this.formType, this.moreaFire});

  final Firestore firestore;
  final String stufe;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final BaseCrudMethods crud;
  final String formType;
  final MoreaFirebase moreaFire;

 

  @override
  State<StatefulWidget> createState() => _ChangeTeleblitzState();
}

enum FormType { keineAktivitaet, ferien, normal }

class _ChangeTeleblitzState extends State<ChangeTeleblitz>
    with SingleTickerProviderStateMixin {
  Auth auth0 = Auth();
  
  String _stufe;
  final _formKey = GlobalKey<FormState>();
  final datumController = TextEditingController();
  final ortAntretenController = TextEditingController();
  final zeitAntretenController = MaskedTextController(mask: '00:00');
  final ortAbtretenController = TextEditingController();
  final zeitAbtretenController = MaskedTextController(mask: '00:00');
  Map<String, TextEditingController> mitnehmenControllerMap =
      Map<String, TextEditingController>();
  List<TextEditingController> mitnehmenControllerList =
      List<TextEditingController>();
  final bemerkungController = TextEditingController();
  final senderController = TextEditingController();
  final mapAntretenController = TextEditingController();
  final mapAbtretenController = TextEditingController();
  final grundController = TextEditingController();
  final endeFerienController = TextEditingController();
  String datumEndeFerien = 'Datum wählen';
  String datumAnzeige = 'Datum wählen';
  String antreten;
  String abtreten;
  bool _noActivity = false;
  bool _ferien = false;
  var aktteleblitz;
  UniqueKey endeFerienKey = UniqueKey();
  AnimationController _controller;
  Animation curve;
  Animation<double> animation;
  FormType formType;
  int _index = 0;
  int _maxIndex;

 

  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    animation = Tween<double>(begin: -0.5, end: 18 * math.pi).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    _controller.forward();
    _stufe = widget.stufe;
    this.aktteleblitz = downloadInfo(_stufe);
    if (widget.formType == 'keineAktivitaet') {
      this.formType = FormType.keineAktivitaet;
      this._maxIndex = 2;
    } else if (widget.formType == 'ferien') {
      this.formType = FormType.ferien;
      this._maxIndex = 1;
    } else {
      this.formType = FormType.normal;
      this._maxIndex = 5;
    }
    initializeDateFormatting("de_DE", null);
  }

  @override
  void dispose() {
    datumController.dispose();
    ortAntretenController.dispose();
    zeitAntretenController.dispose();
    ortAbtretenController.dispose();
    zeitAbtretenController.dispose();
    for (TextEditingController u in mitnehmenControllerList) {
      u.dispose();
    }
    bemerkungController.dispose();
    senderController.dispose();
    grundController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.aktteleblitz,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Loading...',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: MoreaColors.orange,
            ),
            body: Container(
              decoration: BoxDecoration(color: Colors.white),
              child:
                  Center(child: moreaLoadingIndicator(_controller, animation)),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Error',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: MoreaColors.orange,
            ),
            body: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Center(
                child: Text('Keine gültige Verbindung. Internet überprüfen.'),
              ),
            ),
          );
        } else {
          return LayoutBuilder(
              builder: (context, BoxConstraints viewportConstraints) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Teleblitz ändern',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: MoreaColors.orange,
              ),
              body: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        alignment: Alignment.bottomCenter),
                    color: MoreaColors.orange),
                constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Stepper(
                    steps: buildSteps(snapshot),
                    type: StepperType.vertical,
                    currentStep: _index,
                    onStepContinue: () {
                      setState(() {
                        if(_index == _maxIndex){
                          switch (formType) {
                            case FormType.ferien:
                              this._ferien = true;
                              this._noActivity = false;
                              if (this.validateAndSave()) {
                                this.uploadTeleblitz(_stufe, snapshot.data.getID(),
                                    snapshot.data.getSlug());
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Ein Fehler ist aufgetreten!'),
                                      content:
                                      Text('Bitte überprüfe deine Eingaben.'),
                                    );
                                  },
                                );
                              }
                              break;
                            case FormType.keineAktivitaet:
                              this._ferien = false;
                              this._noActivity = true;
                              if (this.validateAndSave()) {
                                this.uploadTeleblitz(_stufe, snapshot.data.getID(),
                                    snapshot.data.getSlug());
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Ein Fehler ist aufgetreten!'),
                                      content:
                                      Text('Bitte überprüfe deine Eingaben.'),
                                    );
                                  },
                                );
                              }
                              break;
                            case FormType.normal:
                              this._ferien = false;
                              this._noActivity = false;
                              if (this.validateAndSave()) {
                                this.uploadTeleblitz(_stufe, snapshot.data.getID(),
                                    snapshot.data.getSlug());
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Ein Fehler ist aufgetreten!'),
                                      content:
                                      Text('Bitte überprüfe deine Eingaben.'),
                                    );
                                  },
                                );
                              }
                          }
                        } else {
                          _index += 1;
                        }
                      });
                    },
                    onStepCancel: () {
                      setState(() {
                        if (_index == 0) {
                          Navigator.of(context).pop();
                        } else {
                          _index -= 1;
                        }
                      });
                    },
                    onStepTapped: (index) {
                      setState(() {
                        _index = index;
                      });
                    },
                    controlsBuilder: (BuildContext context,
                        {VoidCallback onStepContinue,
                        VoidCallback onStepCancel}) {
                      return Container(
                        margin: EdgeInsets.all(20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                child: FlatButton(
                                  child: Text(
                                    'Zurück',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  onPressed: () {
                                    onStepCancel();
                                  },
                                )),
                            Container(
                                decoration: BoxDecoration(
                                    color: MoreaColors.violett,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                child: FlatButton(
                                  child: Text(
                                    'Weiter',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                  onPressed: () {
                                    onStepContinue();
                                  },
                                ))
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          });
        }
      },
    );
  }

  List<Step> buildSteps(AsyncSnapshot snapshot) {
    switch (formType) {
      case FormType.ferien:
        return [
          Step(
              title: Text('Ende Ferien', style: TextStyle(color: Colors.white),),
              content: MoreaShadowContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Datum Ende Ferien",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      decoration: BoxDecoration(
                          color: MoreaColors.violett,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: FlatButton(
                        child: Text(
                          datumEndeFerien,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () {
                          _selectDatumVon(context);
                        },
                      ),
                    ),
                  ],
                ),
              )),
          Step(
              title: Text('Abschliessen', style: TextStyle(color: Colors.white)),
              content: MoreaShadowContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Abschliessen",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      decoration: BoxDecoration(
                          color: MoreaColors.violett,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: FlatButton(
                        child: Text(
                          'Teleblitz ändern',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () {
                          this._ferien = true;
                          this._noActivity = false;
                          if (this.validateAndSave()) {
                            this.uploadTeleblitz(_stufe, snapshot.data.getID(),
                                snapshot.data.getSlug());
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Ein Fehler ist aufgetreten!'),
                                  content:
                                      Text('Bitte überprüfe deine Eingaben.'),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )),
        ];
        break;
      case FormType.keineAktivitaet:
        return [
          Step(
              title: Text('Datum', style: TextStyle(color: Colors.white)),
              content: MoreaShadowContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Datum auswählen",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      decoration: BoxDecoration(
                          color: MoreaColors.violett,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: FlatButton(
                        child: Text(
                          datumAnzeige,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () {
                          _selectDatum(context);
                        },
                      ),
                    ),
                  ],
                ),
              )),
          Step(
              title: Text('Grund', style: TextStyle(color: Colors.white)),
              content: MoreaShadowContainer(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Grund",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    TextFormField(
                      controller: grundController,
                      maxLines: 10,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 18),
                      cursorColor: MoreaColors.violett,
                      decoration: InputDecoration(
                        labelText: 'Grund des Ausfalls',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Bitte nicht leer lassen';
                        } else {
                          return null;
                        }
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                    )
                  ],
                ),
              )),
          Step(
              title: Text('Abschliessen', style: TextStyle(color: Colors.white)),
              content: MoreaShadowContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Abschliessen",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      decoration: BoxDecoration(
                          color: MoreaColors.violett,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: FlatButton(
                        child: Text(
                          'Teleblitz ändern',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () {
                          this._noActivity = true;
                          this._ferien = false;
                          if (this.validateAndSave()) {
                            this.uploadTeleblitz(_stufe, snapshot.data.getID(),
                                snapshot.data.getSlug());
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Ein Fehler ist aufgetreten!'),
                                  content:
                                      Text('Bitte überprüfe deine Eingaben.'),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )),
        ];
        break;
      case FormType.normal:
        return [
          Step(
              title: Text('Datum', style: TextStyle(color: Colors.white)),
              content: MoreaShadowContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Datum auswählen",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      decoration: BoxDecoration(
                          color: MoreaColors.violett,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: FlatButton(
                        child: Text(
                          datumAnzeige,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () {
                          _selectDatum(context);
                        },
                      ),
                    ),
                  ],
                ),
              )),
          Step(
            title: Text('Antreten', style: TextStyle(color: Colors.white)),
            content: MoreaShadowContainer(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Antreten",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  TextFormField(
                    controller: ortAntretenController,
                    maxLines: 2,
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    cursorColor: MoreaColors.violett,
                    decoration: InputDecoration(
                      labelText: 'Ort des Antretens',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Bitte nicht leer lassen';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                  TextFormField(
                    controller: zeitAntretenController,
                    maxLines: 2,
                    minLines: 1,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 18),
                    cursorColor: MoreaColors.violett,
                    decoration: InputDecoration(
                      labelText: 'Zeit des Antretens',
                      alignLabelWithHint: true,
                      suffixText: 'Uhr',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Bitte nicht leer lassen';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                  TextFormField(
                    controller: mapAntretenController,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    cursorColor: MoreaColors.violett,
                    decoration: InputDecoration(
                      labelText: 'Google Maps Link',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Bitte nicht leer lassen';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  )
                ],
              ),
            ),
          ),
          Step(
            title: Text('Abtreten', style: TextStyle(color: Colors.white)),
            content: MoreaShadowContainer(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Abtreten",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  TextFormField(
                    controller: ortAbtretenController,
                    maxLines: 2,
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    cursorColor: MoreaColors.violett,
                    decoration: InputDecoration(
                      labelText: 'Ort des Abtretens',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Bitte nicht leer lassen';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                  TextFormField(
                    controller: zeitAbtretenController,
                    maxLines: 2,
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    cursorColor: MoreaColors.violett,
                    decoration: InputDecoration(
                      labelText: 'Zeit des Abtretens',
                      alignLabelWithHint: true,
                      suffixText: 'Uhr',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Bitte nicht leer lassen';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                  TextFormField(
                    controller: mapAbtretenController,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    cursorColor: MoreaColors.violett,
                    decoration: InputDecoration(
                      labelText: 'Google Maps Link',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Bitte nicht leer lassen';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  )
                ],
              ),
            ),
          ),
          Step(
            title: Text('Mitnehmen', style: TextStyle(color: Colors.white)),
            content: MoreaShadowContainer(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Mitnehmen",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: this.mitnehmenControllerList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return TextFormField(
                        controller: mitnehmenControllerList[index],
                        minLines: 1,
                        maxLines: 2,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 18),
                        cursorColor: MoreaColors.violett,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Bitte nicht leer lassen';
                          } else {
                            return null;
                          }
                        },
                      );
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 7,
                            child: RaisedButton.icon(
                              onPressed: () {
                                this.setState(() {
                                  mitnehmenControllerList
                                      .add(TextEditingController());
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 10,
                              ),
                              label: Text(
                                "Element",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              color: MoreaColors.violett,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 7,
                            child: RaisedButton.icon(
                                onPressed: () {
                                  this.setState(() {
                                    mitnehmenControllerList.removeLast();
                                  });
                                },
                                icon: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                label: Text(
                                  "Element",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                color: MoreaColors.violett,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)))),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: Text('Fussnote', style: TextStyle(color: Colors.white)),
            content: MoreaShadowContainer(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Fussnote",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  TextFormField(
                    controller: bemerkungController,
                    maxLines: 2,
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    cursorColor: MoreaColors.violett,
                    decoration: InputDecoration(
                      labelText: 'Bemerkung',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Bitte nicht leer lassen';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                  TextFormField(
                    controller: senderController,
                    minLines: 1,
                    maxLines: 10,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 18),
                    cursorColor: MoreaColors.violett,
                    decoration: InputDecoration(
                      labelText: 'Sender',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Bitte nicht leer lassen';
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                  )
                ],
              ),
            ),
          ),
          Step(
              title: Text('Abschliessen', style: TextStyle(color: Colors.white)),
              content: MoreaShadowContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Abschliessen",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      decoration: BoxDecoration(
                          color: MoreaColors.violett,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: FlatButton(
                        child: Text(
                          'Teleblitz ändern',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () {
                          this._noActivity = false;
                          this._ferien = false;
                          if (this.validateAndSave()) {
                            this.uploadTeleblitz(_stufe, snapshot.data.getID(),
                                snapshot.data.getSlug());
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Ein Fehler ist aufgetreten!'),
                                  content:
                                      Text('Bitte überprüfe deine Eingaben.'),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )),
        ];
        break;
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<TeleblitzInfo> downloadInfo(String filter) async {
    var jsonDecode;
    var jsonString;
    String _stufe = filter;
    jsonString = await http.get(
        "https://api.webflow.com/collections/5be4a9a6dbcc0a24d7cb0ee9/items?api_version=1.0.0&access_token=d9097840d357b02bd934ba7d9c52c595e6940273e940816a35062fe99e69a2de");
    jsonDecode = json.decode(jsonString.body);
    Map infos;
    for (var u in jsonDecode['items']) {
      if (u['name'] == _stufe) {
        infos = u;
      }
    }
    var teleblitz = TeleblitzInfo.fromJson(infos);
    datumController.text = teleblitz.getDatum();
    this.antreten = teleblitz.getAntreten();
    List splittedAntreten = antreten.split(',');
    ortAntretenController.text = splittedAntreten[0];
    zeitAntretenController.text = splittedAntreten[1].replaceAll(' ', '').replaceAll('Uhr', '');
    this.abtreten = teleblitz.getAbtreten();
    List splittedAbtreten = this.abtreten.split(',');
    ortAbtretenController.text = splittedAbtreten[0];
    zeitAbtretenController.text = splittedAbtreten[1].replaceAll(' ', '').replaceAll('Uhr', '');

    for (var u in teleblitz.getMitnehmen()) {
      print(u);
      if (!(this.mitnehmenControllerMap.containsKey(u))) {
        TextEditingController controller = TextEditingController(text: u);
        this.mitnehmenControllerMap[u] = controller;
      }
    }

    for (var u in mitnehmenControllerMap.values) {
      if (!mitnehmenControllerList.contains(u)) {
        mitnehmenControllerList.add(u);
      }
    }
    bemerkungController.text = teleblitz.getBemerkung();
    senderController.text = teleblitz.getSender();
    mapAntretenController.text = teleblitz.getMapAntreten();
    mapAbtretenController.text = teleblitz.getMapAbtreten();
    grundController.text = teleblitz.getGrund();

    return teleblitz;
  }

  void uploadTeleblitz(String filter, String id, String slug) {
    String _stufe = filter;
    String _id = id;
    String _slug = slug;
    String _jsonMitnehmen;

    List<String> _mitnehmen = List<String>();

    for (var u in mitnehmenControllerList) {
      _mitnehmen.add(u.text);
    }

    this.antreten = ortAntretenController.text + ', ' + zeitAntretenController.text + ' Uhr';
    this.abtreten = ortAbtretenController.text + ', ' + zeitAbtretenController.text + ' Uhr';

    TeleblitzInfo newteleblitz = TeleblitzInfo.fromString(
        _stufe,
        datumController.text,
        this.antreten,
        this.abtreten,
        bemerkungController.text,
        senderController.text,
        _id,
        _mitnehmen,
        _slug,
        mapAntretenController.text,
        mapAbtretenController.text,
        _noActivity,
        _ferien,
        datumEndeFerien,
        grundController.text);
    var jsonMap = {"fields": newteleblitz.toJson()};
    String jsonStr = jsonEncode(jsonMap);
    Map<String, String> header = Map();
    header["Authorization"] =
        "Bearer d9097840d357b02bd934ba7d9c52c595e6940273e940816a35062fe99e69a2de";
    header["accept-version"] = "1.0.0";
    header["Content-Type"] = "application/json";
    http
        .put(
      "https://api.webflow.com/collections/5be4a9a6dbcc0a24d7cb0ee9/items/" +
          _id +
          "?live=true",
      headers: header,
      body: jsonStr,
    )
        .then((result) {
      print(result.statusCode);
      print(result.body);
    });
    _jsonMitnehmen = "<ul>";
    for (var u in _mitnehmen) {
      _jsonMitnehmen = _jsonMitnehmen + "<li>" + u + "</li>";
    }
    _jsonMitnehmen = _jsonMitnehmen + '</ul>';

    //Damit ende-ferien nie leer ist. Sonst enstehen bugs.
    if (datumEndeFerien == 'Datum wählen') {
      datumEndeFerien = '12-06-2018';
    }
    Map<String, dynamic> data;
    data = {
      "abtreten": this.abtreten,
      "antreten": this.antreten,
      "bemerkung": bemerkungController.text,
      "datum": datumController.text,
      "keine-aktivitat": _noActivity,
      "mitnehmen-test": _jsonMitnehmen,
      "name-des-senders": senderController.text,
      "google-map": mapAntretenController.text,
      "map-abtreten": mapAbtretenController.text,
      'ferien': _ferien,
      'ende-ferien': datumEndeFerien,
      'grund': grundController.text,
    };
    widget.moreaFire.uploadteleblitz(_stufe, data);
    Navigator.pop(context);
  }

  Future<Null> _selectDatum(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(Duration(days: 9999)));
    if (picked != null) {
      setState(() {
        datumController.text =
            DateFormat('EEEE, dd.MM.yyy', 'de_DE').format(picked);
        datumAnzeige = DateFormat('dd.MM.yyy').format(picked);
      });
    }
  }

  Future<Null> _selectDatumVon(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(new Duration(days: 9999)),
    );
    if (picked != null)
      setState(() {
        datumEndeFerien = DateFormat('dd-MM-yyyy').format(picked);
      });
  }
}

class TeleblitzInfo {
  Map<String, dynamic> _inhalt;

  String _titel,
      _datum,
      _antreten,
      _abtreten,
      _bemerkung,
      _sender,
      _stufe,
      _id,
      _slug,
      _jsonMitnehmen,
      _mapAntreten,
      _mapAbtreten,
      _grund,
      _endeFerien;

  List<String> _mitnehmen;
  bool _keineaktivitaet, _ferien;

  TeleblitzInfo();

  TeleblitzInfo.fromString(
      String titel,
      String datum,
      String antreten,
      String abtreten,
      String bemerkung,
      String sender,
      String id,
      List<String> mitnehmen,
      String slug,
      String mapAntreten,
      String mapAbtreten,
      bool noActivity,
      bool ferien,
      String endeFerien,
      String grund) {
    _titel = titel;
    _datum = datum;
    _antreten = antreten;
    _abtreten = abtreten;
    _bemerkung = bemerkung;
    _sender = sender;
    _id = id;
    _mitnehmen = mitnehmen;
    _keineaktivitaet = noActivity;
    _ferien = ferien;
    _slug = slug;
    _mapAntreten = mapAntreten;
    _mapAbtreten = mapAbtreten;
    _grund = grund;
    if (endeFerien == 'Datum wählen') {
      _endeFerien = '2019-06-12T00:00:00.000Z';
    } else {
      var dates = endeFerien.split('-');
      _endeFerien =
          dates[2] + '-' + dates[1] + '-' + dates[0] + 'T00:00:00.000Z';
    }
    this.createJsonMitnehmen();
  }

  TeleblitzInfo.fromJson(Map<String, dynamic> json)
      : _titel = json['name'],
        _datum = json['datum'],
        _antreten = json['antreten'],
        _abtreten = json['abtreten'],
        _bemerkung = json['bemerkung'],
        _sender = json['name-des-senders'],
        _stufe = json['name'],
        _id = json['_id'],
        _keineaktivitaet = json['keine-aktivitat'],
        _ferien = json['ferien'],
        _slug = json['slug'],
        _mapAntreten = json['google-map'],
        _mapAbtreten = json['map-abtreten'],
        _grund = json['grund'] {
    this._mitnehmen = json["mitnehmen-test"]
        .replaceFirst("<ul>", "")
        .replaceFirst('<' + '/' + 'ul>', "")
        .replaceAll("</li><li>", ";")
        .replaceFirst("<li>", "")
        .replaceFirst("</li>", "")
        .split(";");
    print(this._mitnehmen.toString());
    this._inhalt = Map.from(json);
    this._endeFerien = _formatDate(json['ende-ferien']);
    print(json);
    print('Ferien: $_endeFerien');
  }

  String _formatDate(String date) {
    if (date != '') {
      String rawDate = date.split('T')[0];
      List<String> dates = rawDate.split('-');
      String formatedDate = dates[2] + '.' + dates[1] + '.' + dates[0];
      return formatedDate;
    } else {
      return date;
    }
  }

  Map<String, dynamic> toJson() => {
        'name': _titel,
        'datum': _datum,
        'antreten': _antreten,
        'abtreten': _abtreten,
        'mitnehmen-test': _jsonMitnehmen,
        'bemerkung': _bemerkung,
        'name-des-senders': _sender,
        'keine-aktivitat': _keineaktivitaet,
        'ferien': _ferien,
        'ende-ferien': _endeFerien,
        '_archived': false,
        '_draft': false,
        'slug': _slug,
        'google-map': _mapAntreten,
        'map-abtreten': _mapAbtreten,
        'grund': _grund,
      };

  void createJsonMitnehmen() {
    _jsonMitnehmen = "<ul>";
    for (var u in _mitnehmen) {
      _jsonMitnehmen = _jsonMitnehmen + "<li>" + u + "</li>";
    }
    _jsonMitnehmen = _jsonMitnehmen + '</ul>';
    print(_jsonMitnehmen);
  }

  String getTitel() {
    return this._titel;
  }

  String getDatum() {
    return this._datum;
  }

  String getAntreten() {
    return this._antreten;
  }

  String getAbtreten() {
    return this._abtreten;
  }

  List<String> getMitnehmen() {
    return this._mitnehmen;
  }

  String getBemerkung() {
    return this._bemerkung;
  }

  String getSender() {
    return this._sender;
  }

  String getStufe() {
    return this._stufe;
  }

  String getID() {
    return this._id;
  }

  String getSlug() {
    return this._slug;
  }

  String getMapAntreten() {
    return this._mapAntreten;
  }

  String getMapAbtreten() {
    return this._mapAbtreten;
  }

  String getGrund() {
    return this._grund;
  }

  String getEndeFerien() {
    return this._endeFerien;
  }

  void setDatum(String datum) {
    this._datum = datum;
  }

  void setAntreten(String antreten) {
    this._antreten = antreten;
  }

  void setAbtreten(String abtreten) {
    this._abtreten = abtreten;
  }

  void setMitnehmen(List<String> mitnehmen) {
    this._mitnehmen = mitnehmen;
  }

  void setBemerkung(String bemerkung) {
    this._bemerkung = bemerkung;
  }

  void setSender(String sender) {
    this._sender = sender;
  }

  void setID(String id) {
    this._id = id;
  }

  void setMapAntreten(String mapAntreten) {
    this._mapAntreten = mapAntreten;
  }

  void setMapAbtreten(String mapAbtreten) {
    this._mapAbtreten = mapAbtreten;
  }

  String getFromMap(String key) {
    if (_inhalt[key] == null) {
      return "";
    } else {
      return _inhalt[key];
    }
  }
}
