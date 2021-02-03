import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/Event/event_data.dart';
import 'dart:convert';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';
import 'package:intl/intl.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'change_teleblitz_abtreten.dart';
import 'change_teleblitz_antreten.dart';
import 'change_teleblitz_bemerkung.dart';
import 'change_teleblitz_grund.dart';
import 'change_teleblitz_mitnehmen.dart';
import 'change_teleblitz_sender.dart';

class ChangeTeleblitz extends StatefulWidget {
  final String stufe;
  final String formType;
  final MoreaFirebase moreaFire;

  ChangeTeleblitz(this.stufe, this.formType, this.moreaFire);

  @override
  State<StatefulWidget> createState() => _ChangeTeleblitzState();
}

enum FormType { keineAktivitaet, ferien, normal }

class _ChangeTeleblitzState extends State<ChangeTeleblitz>
    with TickerProviderStateMixin {
  String stufe;
  FormType formType;
  MoreaFirebase moreaFire;

  //Variabeln vom Teleblitz
  String name,
      startTime,
      endTime,
      datum,
      antreten,
      mapAntreten,
      abtreten,
      mapAbtreten,
      bemerkung,
      sender,
      grund,
      endeFerien,
      id,
      slug,
      rawDate;
  List<String> mitnehmen;
  bool keineAktivitaet, ferien;
  bool archived = false;
  bool draft = false;
  var oldTeleblitz;
  MoreaLoading moreaLoading;

  TeleblitzManager teleblitzManager;

  @override
  void initState() {
    super.initState();
    this.stufe = widget.stufe;
    this.moreaFire = widget.moreaFire;
    this.moreaLoading = MoreaLoading(this);
    this.teleblitzManager = TeleblitzManager(this.moreaFire);
    this.oldTeleblitz = downloadTeleblitz();
    if (widget.formType == "keineAktivitaet") {
      this.formType = FormType.keineAktivitaet;
    } else if (widget.formType == "ferien") {
      this.formType = FormType.ferien;
    } else if (widget.formType == "normal") {
      this.formType = FormType.normal;
    } else {
      print('Error: Nicht der richtige FormType. Gewählter FormType: ' +
          widget.formType);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    moreaLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.oldTeleblitz,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Loading...'),
              ),
              body: MoreaBackgroundContainer(child: moreaLoading.loading()));
        } else if (snapshot.connectionState == ConnectionState.done) {
          switch (formType) {
            case FormType.keineAktivitaet:
              return Scaffold(
                appBar: AppBar(
                  title: Text('Ausfall Aktivität'),
                ),
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.file_upload),
                  backgroundColor: MoreaColors.violett,
                  onPressed: () => uploadTeleblitz(),
                ),
                body: LayoutBuilder(
                  builder: (context, viewportConstraints) {
                    return MoreaBackgroundContainer(
                      child: SingleChildScrollView(
                        child: MoreaShadowContainer(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(this.name,
                                    style: MoreaTextStyle.title),
                              ),
                              ListTile(
                                title:
                                    Text('Datum', style: MoreaTextStyle.lable),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    datum,
                                    style: MoreaTextStyle.subtitle,
                                  ),
                                ),
                                onTap: () => _selectDatum(context),
                                trailing: Icon(Icons.arrow_forward_ios),
                                contentPadding: EdgeInsets.only(
                                    right: 15, left: 15, bottom: 5),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.black26,
                                  )),
                              ListTile(
                                title: Text('Grund des Ausfalls',
                                    style: MoreaTextStyle.lable),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    this.grund,
                                    style: MoreaTextStyle.subtitle,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChangeGrund(
                                              this.grund, this.setGrund)));
                                },
                                trailing: Icon(Icons.arrow_forward_ios),
                                contentPadding: EdgeInsets.only(
                                    right: 15, left: 15, bottom: 15, top: 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
              break;
            case FormType.ferien:
              return Scaffold(
                appBar: AppBar(
                  title: Text('Ferien'),
                ),
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.file_upload),
                  backgroundColor: MoreaColors.violett,
                  onPressed: () => uploadTeleblitz(),
                ),
                body: LayoutBuilder(
                  builder: (context, viewportConstraints) {
                    return MoreaBackgroundContainer(
                      child: SingleChildScrollView(
                        child: MoreaShadowContainer(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(this.name,
                                    style: MoreaTextStyle.title),
                              ),
                              ListTile(
                                title: Text('Ende Ferien',
                                    style: MoreaTextStyle.lable),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    endeFerien,
                                    style: MoreaTextStyle.subtitle,
                                  ),
                                ),
                                onTap: () => _selectDatumEndeFerien(context),
                                trailing: Icon(Icons.arrow_forward_ios),
                                contentPadding: EdgeInsets.only(
                                    right: 15, left: 15, bottom: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
              break;
            case FormType.normal:
              return Scaffold(
                appBar: AppBar(
                  title: Text('Aktivität'),
                ),
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.file_upload),
                  backgroundColor: MoreaColors.violett,
                  onPressed: () => uploadTeleblitz(),
                ),
                body: LayoutBuilder(
                  builder: (context, viewportConstraints) {
                    return MoreaBackgroundContainer(
                      child: SingleChildScrollView(
                        child: MoreaShadowContainer(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(this.name,
                                    style: MoreaTextStyle.title),
                              ),
                              ListTile(
                                title:
                                    Text('Datum', style: MoreaTextStyle.lable),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    datum,
                                    style: MoreaTextStyle.subtitle,
                                  ),
                                ),
                                onTap: () => _selectDatum(context),
                                trailing: Icon(Icons.arrow_forward_ios),
                                contentPadding: EdgeInsets.only(
                                    left: 15, right: 15, top: 0, bottom: 5),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.black26,
                                  )),
                              ListTile(
                                title:
                                    Text('Beginn', style: MoreaTextStyle.lable),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    antreten,
                                    style: MoreaTextStyle.subtitle,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChangeAntreten(
                                              this.antreten,
                                              this.mapAntreten,
                                              this.setBeginn)));
                                },
                                trailing: Icon(Icons.arrow_forward_ios),
                                contentPadding: EdgeInsets.only(
                                    right: 15, left: 15, top: 5, bottom: 5),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.black26,
                                  )),
                              ListTile(
                                title: Text('Schluss',
                                    style: MoreaTextStyle.lable),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    abtreten,
                                    style: MoreaTextStyle.subtitle,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChangeAbtreten(this.abtreten,
                                              this.mapAbtreten, this.setEnde)));
                                },
                                trailing: Icon(Icons.arrow_forward_ios),
                                contentPadding: EdgeInsets.only(
                                    right: 15, left: 15, top: 5, bottom: 5),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.black26,
                                  )),
                              ListTile(
                                title: Text('Mitnehmen',
                                    style: MoreaTextStyle.lable),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: mitnehmen.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Text(
                                        '- ' + mitnehmen[index],
                                        style: MoreaTextStyle.subtitle,
                                      );
                                    },
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChangeMitnehmen(this.mitnehmen,
                                              this.setMitnehmen)));
                                },
                                trailing: Icon(Icons.arrow_forward_ios),
                                contentPadding: EdgeInsets.only(
                                    right: 15, left: 15, top: 10, bottom: 10),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.black26,
                                  )),
                              ListTile(
                                title: Text('Bemerkung',
                                    style: MoreaTextStyle.lable),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    bemerkung,
                                    style: MoreaTextStyle.subtitle,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChangeBemerkung(this.bemerkung,
                                              this.setBemerkung)));
                                },
                                trailing: Icon(Icons.arrow_forward_ios),
                                contentPadding: EdgeInsets.only(
                                    right: 15, left: 15, top: 5, bottom: 5),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.black26,
                                  )),
                              ListTile(
                                title:
                                    Text('Sender', style: MoreaTextStyle.lable),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    sender,
                                    style: MoreaTextStyle.subtitle,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ChangeSender(
                                              this.sender, this.setSender)));
                                },
                                trailing: Icon(Icons.arrow_forward_ios),
                                contentPadding: EdgeInsets.only(
                                    right: 15, left: 15, bottom: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
              break;
          }
        }
        return null;
      },
    );
  }

  Future<Map> downloadTeleblitz() async {
    var infos = await teleblitzManager.downloadTeleblitz(this.stufe);
    this.name = infos['name'];
    this.datum = infos['datum'];
    print(this.datum);
    antreten = infos['antreten'];
    mapAntreten = infos['google-map'];
    abtreten = infos['abtreten'];
    mapAbtreten = infos['map-abtreten'];
    mitnehmen = infos['mitnehmen-test'];
    bemerkung = infos['bemerkung'];
    sender = infos['name-des-senders'];
    grund = infos['grund'];
    endeFerien = infos['ende-ferien'];
    id = infos['_id'];
    slug = infos['slug'];
    switch (widget.formType) {
      case 'keineAktivitaet':
        keineAktivitaet = true;
        ferien = false;
        break;
      case 'ferien':
        keineAktivitaet = false;
        ferien = true;
        break;
      case 'normal':
        keineAktivitaet = false;
        ferien = false;
        break;
    }
    return infos;
  }

  void uploadTeleblitz() async {
    Map<String, dynamic> newTeleblitz = {
      'name': this.name,
      'datum': this.datum,
      'antreten': this.antreten,
      'google-map': this.mapAntreten,
      'abtreten': this.abtreten,
      'map-abtreten': this.mapAbtreten,
      'mitnehmen-test': this.mitnehmen,
      'bemerkung': this.bemerkung,
      'name-des-senders': this.sender,
      'grund': this.grund,
      'ende-ferien': this.endeFerien,
      'slug': this.slug,
      'ferien': this.ferien,
      'keine-aktivitat': this.keineAktivitaet,
      '_draft': false,
      '_archived': false,
      'groupIDs': [convWebflowtoMiData(stufe)],
      'EventType': 'Teleblitz',
      mapTimestamp: DateTime.now().toIso8601String()
    };
    EventData event = EventData(newTeleblitz);
    int hours = int.parse(this.antreten.substring(0, 2));
    int minutes = int.parse(this.antreten.substring(3, 5));
    teleblitzManager.uploadTeleblitz(newTeleblitz, this.id);
    DateTime start = (DateFormat("dd.MM.yyyy").parse(this.datum.split(', ')[1]))
        .add(Duration(hours: hours, minutes: minutes));
    hours = int.parse(this.abtreten.substring(0, 2));
    minutes = int.parse(this.abtreten.substring(3, 5));
    DateTime end = (DateFormat("dd.MM.yyyy").parse(this.datum.split(', ')[1]))
        .add(Duration(hours: hours, minutes: minutes));
    await widget.moreaFire.createEvent([convWebflowtoMiData(stufe)],
        start.toIso8601String(), end.toIso8601String(), newTeleblitz);

    Navigator.of(context).popUntil(ModalRoute.withName('/'));
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
        this.rawDate = picked.toIso8601String();
        this.datum = DateFormat('EEEE, dd.MM.yyy', 'de').format(picked);
      });
    }
  }

  Future<Null> _selectDatumEndeFerien(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(Duration(days: 9999)));
    if (picked != null) {
      setState(() {
        this.endeFerien = DateFormat('dd.MM.yyy', 'de').format(picked);
      });
    }
  }

  void setBeginn(String ort, String zeit, String map, String zeitRaw) {
    this.antreten = zeit + ' Uhr, ' + ort;
    this.mapAntreten = map;
    this.startTime = zeit;
  }

  void setEnde(String ort, String zeit, String map) {
    this.abtreten = zeit + ' Uhr, ' + ort;
    this.mapAbtreten = map;
    this.endTime = zeit;
  }

  void setMitnehmen(List<String> mitnehmen) {
    this.mitnehmen = mitnehmen;
  }

  void setBemerkung(String bemerkung) {
    this.bemerkung = bemerkung;
  }

  void setSender(String sender) {
    this.sender = sender;
  }

  void setGrund(String grund) {
    this.grund = grund;
  }

  void setEndeFerien(String endeFerien) {
    this.endeFerien = endeFerien;
  }
}

class TeleblitzManager {
  MoreaFirebase moreaFirebase;

  TeleblitzManager(MoreaFirebase moreaFirebase) {
    this.moreaFirebase = moreaFirebase;
  }

  Future<Map> downloadTeleblitz(String stufe) async {
    String apiKey = await moreaFirebase.getWebflowApiKey();
    var jsonDecode;
    var jsonString;
    jsonString = await http.get(
        "https://api.webflow.com/collections/5be4a9a6dbcc0a24d7cb0ee9/items?api_version=1.0.0&access_token=$apiKey");
    jsonDecode = json.decode(jsonString.body);
    Map infos;
    for (var u in jsonDecode['items']) {
      if (u["name"] == stufe) {
        infos = u;
      }
    }
    String newDate = _formatDate(infos['ende-ferien']);
    infos['ende-ferien'] = newDate;
    infos['mitnehmen-test'] = _formatMitnehmen(infos['mitnehmen-test']);
    return infos;
  }

  String _formatDate(String date) {
    if (date != '') {
      String rawDate = date.split('T')[0];
      List<String> dates = rawDate.split('-');
      String formatedDate = dates[2] + '.' + dates[1] + '.' + dates[0];
      return formatedDate;
    } else {
      return '29.10.2019';
    }
  }

  List _formatMitnehmen(String mitnehmen) {
    List newMitnehmen = mitnehmen
        .replaceFirst("<ul>", "")
        .replaceFirst('<' + '/' + 'ul>', "")
        .replaceAll("</li><li>", ";")
        .replaceFirst("<li>", "")
        .replaceFirst("</li>", "")
        .split(';');
    return newMitnehmen;
  }

  void uploadTeleblitz(Map newTeleblitz, String id) async {
    String apiKey = await moreaFirebase.getWebflowApiKey();
    String formatedMitnehmen = '<ul>';
    for (String u in newTeleblitz['mitnehmen-test']) {
      formatedMitnehmen = formatedMitnehmen + '<li>' + u + '</li>';
    }
    formatedMitnehmen = formatedMitnehmen + '</ul>';
    newTeleblitz['mitnehmen-test'] = formatedMitnehmen;
    var result = newTeleblitz['ende-ferien'].split('.');
    newTeleblitz['ende-ferien'] =
        result[2] + '-' + result[1] + '-' + result[0] + 'T00:00:00.000Z';
    newTeleblitz.remove('groupIDs');
    newTeleblitz.remove('EventType');
    newTeleblitz.remove('Timestamp');
    var jsonMap = {"fields": newTeleblitz};
    String jsonStr = jsonEncode(jsonMap);
    Map<String, String> header = Map();
    header["Authorization"] = "Bearer $apiKey";
    header["accept-version"] = "1.0.0";
    header["Content-Type"] = "application/json";
    http
        .put(
      "https://api.webflow.com/collections/5be4a9a6dbcc0a24d7cb0ee9/items/" +
          id +
          "?live=true",
      headers: header,
      body: jsonStr,
    )
        .then((result) {
      print(result.statusCode);
      print(result.body);
    });
  }
}
