import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';
import 'package:intl/intl.dart';

class ChangeTeleblitz extends StatefulWidget {
  ChangeTeleblitz({this.auth, this.crud, this.onSignedOut, this.stufe, this.firestore});

  final String stufe;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final BaseCrudMethods crud;
  final Firestore firestore;

  
  @override
  State<StatefulWidget> createState() => _ChangeTeleblitzState();
}

class _ChangeTeleblitzState extends State<ChangeTeleblitz> {
  
  MoreaFirebase moreafire;
  String _stufe;
  final _formKey = GlobalKey<FormState>();
  final datumController = TextEditingController();
  final antretenController = TextEditingController();
  final abtretenController = TextEditingController();
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
  final formKey = new GlobalKey<FormState>();
  bool _noActivity = false;
  bool _ferien = false;
  var aktteleblitz;
  UniqueKey endeFerienKey = UniqueKey();

 

  void initState() {
    super.initState();
    moreafire = new MoreaFirebase(widget.firestore);
    _stufe = widget.stufe;
    this.aktteleblitz = downloadInfo(_stufe);
  }

  @override
  void dispose() {
    datumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: this.aktteleblitz,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_ferien) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text('Teleblitz ändern'),
                    backgroundColor: MoreaColors.violett,
                  ),
                  body: ListView(children: [
                    Column(children: <Widget>[
                      Container(
                          child: Form(
                              key: _formKey,
                              child: Column(children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 30, left: 40, right: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.not_interested),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: SwitchListTile(
                                          title: Text('Keine Aktivität'),
                                          value: _noActivity,
                                          activeColor: MoreaColors.violett,
                                          onChanged: (bool val) {
                                            setState(() {
                                              if (val == true) {
                                                _noActivity = val;
                                                _ferien = !val;
                                              } else {
                                                _noActivity = val;
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 0, left: 40, right: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.not_interested),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: SwitchListTile(
                                          title: Text('Ende Ferien'),
                                          value: _ferien,
                                          activeColor: MoreaColors.violett,
                                          onChanged: (bool val) {
                                            setState(() {
                                              if (val == true) {
                                                _noActivity = !val;
                                                _ferien = val;
                                              } else {
                                                _ferien = val;
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.date_range),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                            alignment: Alignment.center, //
                                            decoration: new BoxDecoration(
                                              border: new Border.all(
                                                  color: Colors.black,
                                                  width: 2),
                                              borderRadius:
                                                  new BorderRadius.all(
                                                Radius.circular(4.0),
                                              ),
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.symmetric(vertical: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Text('Datum Ende Ferien:'),
                                                  RaisedButton(
                                                    onPressed: () {
                                                      _selectDatumvon(context);
                                                    },
                                                    child: Text(
                                                      datumEndeFerien,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    color: MoreaColors.violett,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5))),
                                                  ),
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                              ),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 30),
                                  child: RaisedButton.icon(
                                    onPressed: () {
                                      this.uploadTeleblitz(
                                          _stufe,
                                          snapshot.data.getID(),
                                          snapshot.data.getSlug());
                                    },
                                    icon: Icon(
                                      Icons.update,
                                      color: Colors.white,
                                    ),
                                    label: Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        "Teleblitz ändern",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                    color: MoreaColors.violett,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                )
                              ])))
                    ])
                  ]));
            } else if (!(_noActivity) && !(_ferien)) {
              return new Scaffold(
                appBar: AppBar(
                  title: Text("Teleblitz ändern"),
                  backgroundColor: MoreaColors.violett,
                ),
                body: ListView(
                  children: [
                    Column(
                      children: <Widget>[
                        Container(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 30, left: 40, right: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.not_interested),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: SwitchListTile(
                                          title: Text('Keine Aktivität'),
                                          value: _noActivity,
                                          activeColor: MoreaColors.violett,
                                          onChanged: (bool val) {
                                            setState(() {
                                              if (val == true) {
                                                _noActivity = val;
                                                _ferien = !val;
                                              } else {
                                                _noActivity = val;
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 0, left: 40, right: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.not_interested),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: SwitchListTile(
                                          title: Text('Ende Ferien'),
                                          value: _ferien,
                                          activeColor: MoreaColors.violett,
                                          onChanged: (bool val) {
                                            setState(() {
                                              if (val == true) {
                                                _noActivity = !val;
                                                _ferien = val;
                                              } else {
                                                _ferien = val;
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.date_range),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          alignment: Alignment.center, //
                                          decoration: new BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(4.0),
                                            ),
                                          ),
                                          child: TextFormField(
                                            initialValue: datumController.text,
                                            decoration: InputDecoration(
                                              filled: true,
                                              labelText: 'Datum',
                                            ),
                                            onSaved: (value) =>
                                                datumController.text = value,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.map),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          alignment: Alignment.center, //
                                          decoration: new BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(4.0),
                                            ),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              TextFormField(
                                                initialValue:
                                                    antretenController.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Antreten',
                                                  filled: true,
                                                ),
                                                onSaved: (value) =>
                                                    antretenController.text =
                                                        value,
                                              ),
                                              TextFormField(
                                                initialValue:
                                                    mapAntretenController.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Antreten Map',
                                                  filled: true,
                                                ),
                                                onSaved: (value) =>
                                                    mapAntretenController.text =
                                                        value,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.map),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          alignment: Alignment.center, //
                                          decoration: new BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(4.0),
                                            ),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              TextFormField(
                                                initialValue:
                                                    abtretenController.text,
                                                decoration: InputDecoration(
                                                  labelText: 'Antreten',
                                                  filled: true,
                                                ),
                                                onSaved: (value) =>
                                                    abtretenController.text =
                                                        value,
                                              ),
                                              TextFormField(
                                                initialValue:
                                                    mapAbtretenController.text,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  labelText: 'Antreten Map',
                                                ),
                                                onSaved: (value) =>
                                                    mapAbtretenController.text =
                                                        value,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.assignment),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          alignment: Alignment.center, //
                                          decoration: new BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(4.0),
                                            ),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: this
                                                    .mitnehmenControllerList
                                                    .length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return TextFormField(
                                                    initialValue:
                                                        mitnehmenControllerList[
                                                                index]
                                                            .text,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        labelText: 'Mitnehmen'),
                                                    onSaved: (value) =>
                                                        mitnehmenControllerList[
                                                                index]
                                                            .text = value,
                                                  );
                                                },
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 10, bottom: 10),
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
                                                        child:
                                                            RaisedButton.icon(
                                                          onPressed: () {
                                                            this.setState(() {
                                                              mitnehmenControllerList
                                                                  .add(
                                                                      TextEditingController());
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          ),
                                                          label: Text(
                                                            "Element",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          color: MoreaColors
                                                              .violett,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          5))),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(),
                                                      ),
                                                      Expanded(
                                                        flex: 7,
                                                        child:
                                                            RaisedButton.icon(
                                                                onPressed: () {
                                                                  this.setState(
                                                                      () {
                                                                    mitnehmenControllerList
                                                                        .removeLast();
                                                                  });
                                                                },
                                                                icon: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                label: Text(
                                                                  "Element",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                color:
                                                                    MoreaColors
                                                                        .violett,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(5)))),
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
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.chat_bubble),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          alignment: Alignment.center, //
                                          decoration: new BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(4.0),
                                            ),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              TextFormField(
                                                initialValue:
                                                    bemerkungController.text,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  labelText: 'Bemerkung',
                                                ),
                                                onSaved: (value) =>
                                                    bemerkungController.text =
                                                        value,
                                              ),
                                              TextFormField(
                                                initialValue:
                                                    senderController.text,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  labelText: 'Sender',
                                                ),
                                                onSaved: (value) =>
                                                    senderController.text =
                                                        value,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 30),
                                  child: RaisedButton.icon(
                                    onPressed: () {
                                      this.uploadTeleblitz(
                                          _stufe,
                                          snapshot.data.getID(),
                                          snapshot.data.getSlug());
                                    },
                                    icon: Icon(
                                      Icons.update,
                                      color: Colors.white,
                                    ),
                                    label: Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        "Teleblitz ändern",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                    color: MoreaColors.violett,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(),
                  ],
                ),
              );
            } else {
              return Scaffold(
                  appBar: AppBar(
                    title: Text('Teleblitz ändern'),
                    backgroundColor: MoreaColors.violett,
                  ),
                  body: ListView(children: [
                    Column(children: <Widget>[
                      Container(
                          child: Form(
                              key: _formKey,
                              child: Column(children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 30, left: 40, right: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.not_interested),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: SwitchListTile(
                                          title: Text('Keine Aktivität'),
                                          value: _noActivity,
                                          activeColor: MoreaColors.violett,
                                          onChanged: (bool val) {
                                            setState(() {
                                              if (val == true) {
                                                _noActivity = val;
                                                _ferien = !val;
                                              } else {
                                                _noActivity = val;
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 0, left: 40, right: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.not_interested),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: SwitchListTile(
                                          title: Text('Ende Ferien'),
                                          value: _ferien,
                                          activeColor: MoreaColors.violett,
                                          onChanged: (bool val) {
                                            setState(() {
                                              if (val == true) {
                                                _noActivity = !val;
                                                _ferien = val;
                                              } else {
                                                _ferien = val;
                                              }
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.date_range),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          alignment: Alignment.center, //
                                          decoration: new BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(4.0),
                                            ),
                                          ),
                                          child: TextFormField(
                                            initialValue: datumController.text,
                                            decoration: InputDecoration(
                                              filled: true,
                                              labelText: 'Datum',
                                            ),
                                            onSaved: (value) =>
                                                datumController.text = value,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Icon(Icons.date_range),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          alignment: Alignment.center, //
                                          decoration: new BoxDecoration(
                                            border: new Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(4.0),
                                            ),
                                          ),
                                          child: TextFormField(
                                            initialValue: grundController.text,
                                            decoration: InputDecoration(
                                              filled: true,
                                              labelText: 'Grund für Ausfall',
                                            ),
                                            onSaved: (value) =>
                                                grundController.text = value,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 30),
                                  child: RaisedButton.icon(
                                    onPressed: () {
                                      this.uploadTeleblitz(
                                          _stufe,
                                          snapshot.data.getID(),
                                          snapshot.data.getSlug());
                                    },
                                    icon: Icon(
                                      Icons.update,
                                      color: Colors.white,
                                    ),
                                    label: Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        "Teleblitz ändern",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                    color: MoreaColors.violett,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                )
                              ])))
                    ])
                  ]));
            }
          } else {
            return Scaffold(
              appBar: AppBar(
                  title: Text("Loading"), backgroundColor: MoreaColors.violett),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
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
    antretenController.text = teleblitz.getAntreten();
    abtretenController.text = teleblitz.getAbtreten();
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
    validateAndSave();

    for (var u in mitnehmenControllerList) {
      _mitnehmen.add(u.text);
    }

    TeleblitzInfo newteleblitz = TeleblitzInfo.fromString(
        _stufe,
        datumController.text,
        antretenController.text,
        abtretenController.text,
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
      "abtreten": abtretenController.text,
      "antreten": antretenController.text,
      "bemerkung": bemerkungController.text,
      "datum": datumController.text,
      "keine-aktivitat": _noActivity.toString(),
      "mitnehmen-test": _jsonMitnehmen,
      "name-des-senders": senderController.text,
      "google-map": mapAntretenController.text,
      "map-abtreten": mapAbtretenController.text,
      'ferien': _ferien.toString(),
      'ende-ferien': datumEndeFerien,
      'grund': grundController.text,
    };
    moreafire.uploadteleblitz(_stufe, data);
    Navigator.pop(context);
  }

  Future<Null> _selectDatumvon(BuildContext context) async {
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
