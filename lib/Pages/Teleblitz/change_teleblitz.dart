import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangeTeleblitz extends StatefulWidget {
  final String stufe;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final BasecrudMethods crud;

  ChangeTeleblitz({this.auth, this.crud, this.onSignedOut, this.stufe});

  @override
  State<StatefulWidget> createState() => _ChangeTeleblitzState();
}

class _ChangeTeleblitzState extends State<ChangeTeleblitz> {
  Auth auth0 = Auth();
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
  final formKey = new GlobalKey<FormState>();
  var aktteleblitz;
  

  void initState() {
    super.initState();
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
            datumController.text = snapshot.data.getDatum();
            antretenController.text = snapshot.data.getAntreten();
            abtretenController.text = snapshot.data.getAbtreten();
            for (var u in snapshot.data.getMitnehmen()) {
              print(u);
              if (!(this.mitnehmenControllerMap.containsKey(u))) {
                TextEditingController controller =
                TextEditingController(text: u);
                this.mitnehmenControllerMap[u] = controller;
              }
            }

            for (var u in mitnehmenControllerMap.values) {
              if (!mitnehmenControllerList.contains(u)) {
                mitnehmenControllerList.add(u);
              }
            }
            bemerkungController.text = snapshot.data.getBemerkung();
            senderController.text = snapshot.data.getSender();

            return new Scaffold(
              appBar: AppBar(
                title: Text("Teleblitz Ändern"),
                backgroundColor: Color(0xff7a62ff),
              ),
              body: ListView(
                children: [
                  Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black26),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                        "Datum",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      trailing: Icon(Icons.date_range),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        initialValue: datumController.text,
                                        style: TextStyle(fontSize: 18),
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Color.fromRGBO(
                                                153, 255, 255, 0.3)),
                                                onSaved: (value)=> datumController.text = value,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black26),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                        "Antreten",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      trailing: Icon(Icons.flag),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        initialValue: antretenController.text,
                                        style: TextStyle(fontSize: 18),
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Color.fromRGBO(
                                                153, 255, 255, 0.3)),
                                                onSaved: (value)=> antretenController.text = value,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black26),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                        "Abtreten",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      trailing: Icon(Icons.flag),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        initialValue: abtretenController.text,
                                        style: TextStyle(fontSize: 18),
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Color.fromRGBO(
                                                153, 255, 255, 0.3)),
                                                onSaved: (value)=> abtretenController.text = value,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black26),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                        "Mitnehmen",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      trailing: Icon(Icons.assignment),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                      this.mitnehmenControllerList.length,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return new ListTile(
                                          title: TextFormField(
                                            initialValue: mitnehmenControllerList[index]
                                                .text,
                                            style: TextStyle(fontSize: 18),
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Color.fromRGBO(
                                                    153, 255, 255, 0.3)),
                                            onSaved: (value) =>
                                            mitnehmenControllerList[index]
                                                .text = value,
                                          ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      title: RaisedButton.icon(
                                        onPressed: () {
                                          this.setState(() {
                                            mitnehmenControllerList
                                                .add(TextEditingController());
                                          });
                                        },
                                        icon: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          "Element hinzufügen",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        color: Color(0xffff9262),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black26),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                        "Bemerkung",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      trailing: Icon(Icons.note),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        initialValue: bemerkungController.text,
                                        style: TextStyle(fontSize: 18),
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Color.fromRGBO(
                                                153, 255, 255, 0.3)),
                                                onSaved: (value)=> bemerkungController.text = value,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black26),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                        "Sender",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      trailing: Icon(Icons.contacts),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        initialValue: senderController.text,
                                        style: TextStyle(fontSize: 18),
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Color.fromRGBO(
                                                153, 255, 255, 0.3)),
                                                onSaved: (value)=> senderController.text = value,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListTile(
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 25),
                                title: RaisedButton.icon(
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
                                  label: Text(
                                    "Teleblitz ändern",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Color(0xffff9262),
                                ),
                              )
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
                title: Text("Loading"),
                backgroundColor: Color(0xff7a62ff)
              ),
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
    );
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

    Map<String, dynamic> data = {
      "abtreten": abtretenController.text,
      "antreten": antretenController.text,
      "bemerkung": bemerkungController.text,
      "datum": datumController.text,
      "keine-aktivität": false,
      "mitnehmen-test": _jsonMitnehmen,
      "name-des-senders": senderController.text,
    };
    auth0.uploadteleblitz(data, _stufe);
    Navigator.pop(context);
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
      _jsonMitnehmen;

  List<String> _mitnehmen;
  bool _keineaktivitaet, _ferien;

  TeleblitzInfo();

  TeleblitzInfo.fromString(String titel,
      String datum,
      String antreten,
      String abtreten,
      String bemerkung,
      String sender,
      String id,
      List<String> mitnehmen,
      String slug) {
    _titel = titel;
    _datum = datum;
    _antreten = antreten;
    _abtreten = abtreten;
    _bemerkung = bemerkung;
    _sender = sender;
    _id = id;
    _mitnehmen = mitnehmen;
    _keineaktivitaet = false;
    _ferien = false;
    _slug = slug;
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
        _slug = json['slug'] {
    this._mitnehmen = json["mitnehmen-test"]
        .replaceFirst("<ul>", "")
        .replaceFirst('<' + '/' + 'ul>', "")
        .replaceAll("</li><li>", ";")
        .replaceFirst("<li>", "")
        .replaceFirst("</li>", "")
        .split(";");
    print(this._mitnehmen.toString());
    this._inhalt = Map.from(json);
  }

  Map<String, dynamic> toJson() =>
      {
        'name': _titel,
        'datum': _datum,
        'antreten': _antreten,
        'abtreten': _abtreten,
        'mitnehmen-test': _jsonMitnehmen,
        'bemerkung': _bemerkung,
        'name-des-senders': _sender,
        'keine-aktivitat': _keineaktivitaet,
        'ferien': _ferien,
        '_archived': false,
        '_draft': false,
        'slug': _slug,
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

  String getFromMap(String key) {
    if (_inhalt[key] == null) {
      return "";
    } else {
      return _inhalt[key];
    }
  }
}
