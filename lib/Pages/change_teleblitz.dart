import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth.dart';
import '../services/crud.dart';
import '../services/Getteleblitz.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangeTeleblitz extends StatefulWidget {
  String stufe;
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final BasecrudMethods crud;

  ChangeTeleblitz({this.auth, this.crud, this.onSignedOut,this.stufe});

  @override
  State<StatefulWidget> createState() => _ChangeTeleblitzState();
}

class _ChangeTeleblitzState extends State<ChangeTeleblitz> {
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
  var aktteleblitz;

  void initState() {
    super.initState();
    _stufe =widget.stufe;
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
                              ListTile(
                                title: Text("Datum"),
                                trailing: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Icon(Icons.date_range),
                                ),
                              ),
                              ListTile(
                                title: TextField(
                                  controller: datumController,
                                ),
                                trailing: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.cancel),
                                ),
                              ),
                              ListTile(
                                title: Text("Antreten"),
                                trailing: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.flag),
                                ),
                              ),
                              ListTile(
                                title: TextField(
                                  controller: antretenController,
                                ),
                                trailing: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.cancel),
                                ),
                              ),
                              ListTile(
                                title: Text("Abtreten"),
                                trailing: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.flag),
                                ),
                              ),
                              ListTile(
                                title: TextField(
                                  controller: abtretenController,
                                ),
                                trailing: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.cancel),
                                ),
                              ),
                              ListTile(
                                title: Text("Mitnehmen"),
                                trailing: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.assignment),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: this.mitnehmenControllerList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return new ListTile(
                                    title: TextField(
                                      controller:
                                      mitnehmenControllerList[index],
                                    ),
                                    trailing: IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: null),
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
                                    icon: Icon(Icons.add),
                                    label: Text("Element hinzufügen")),
                              ),
                              ListTile(
                                title: Text("Bemerkung"),
                                trailing: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.note),
                                ),
                              ),
                              ListTile(
                                title: TextField(
                                  controller: bemerkungController,
                                ),
                                trailing: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.cancel),
                                ),
                              ),
                              ListTile(
                                title: Text("Sender"),
                                trailing: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.perm_contact_calendar),
                                ),
                              ),
                              ListTile(
                                title: TextField(
                                  controller: senderController,
                                ),
                                trailing: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.cancel),
                                ),
                              ),
                              ListTile(
                                title: RaisedButton.icon(
                                  //TODO change to a variable stufe later
                                  onPressed: () {
                                    this.uploadTeleblitz(_stufe, snapshot.data.getID());
                                  },
                                  icon: Icon(Icons.update),
                                  label: Text("Teleblitz ändern"),
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
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
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

  void uploadTeleblitz(String filter, String id) {
    String _stufe = filter;
    String _id = id;

    List<String> _mitnehmen = List<String>();

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
        _mitnehmen);
    var jsonMap = {
      "fields": newteleblitz.toJson()
    };
    String jsonStr = jsonEncode(jsonMap);
    Map<String, String> header = Map();
    header["Authorization"] =
    "Bearer d9097840d357b02bd934ba7d9c52c595e6940273e940816a35062fe99e69a2de"
    ;
    header["accept-version"] = "1.0.0";
    header["Content-Type"] = "application/json";
    http.put(
      "https://api.webflow.com/collections/5be4a9a6dbcc0a24d7cb0ee9/items/" +
          _id+
          "?live=true",
      headers: header,
      body: jsonStr,
    ).then((result){
      print(result.statusCode);
      print(result.body);
    });
  }
}

class TeleblitzInfo {
  Map<String, dynamic> _inhalt;

  String _titel, _datum, _antreten, _abtreten, _bemerkung, _sender, _stufe, _id, _jsonMitnehmen;

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
      List<String> mitnehmen) {
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
        _ferien = json['ferien'] {
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
        'slug': _stufe,
        '_archived': false,
        '_draft': false,
      };

  void createJsonMitnehmen(){
    _jsonMitnehmen = "<ul>";
    for (var u in _mitnehmen){
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