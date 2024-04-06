import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:morea/services/morea_firestore.dart';

class TeleblitzManager {
  String? slug;
  String? name;
  String? id;
  bool archived = false;
  bool draft = false;

  late MoreaFirebase moreafire;

  TeleblitzManager(FirebaseFirestore firestore) {
    moreafire = MoreaFirebase(firestore);
  }

  Future<bool> uploadTeleblitz(
      String datum,
      String antreten,
      String mapAntreten,
      String abtreten,
      String mapAbtreten,
      List<String> mitnehmen,
      String bemerkung,
      String sender,
      bool keineAktivitat,
      String grund,
      bool ferien,
      String endeFerien) async {
    Teleblitz upload = Teleblitz.fromString(
        this.name!,
        datum,
        antreten,
        mapAntreten,
        abtreten,
        mapAbtreten,
        mitnehmen,
        bemerkung,
        sender,
        keineAktivitat,
        grund,
        ferien,
        endeFerien,
        this.id!,
        this.slug!);
    var jsonMap = {"fields": upload.toJson()};
    String jsonStr = jsonEncode(jsonMap);
    Map<String, String> header = Map();
    header["Authorization"] =
        "Bearer d9097840d357b02bd934ba7d9c52c595e6940273e940816a35062fe99e69a2de";
    header["accept-version"] = "1.0.0";
    header["Content-Type"] = "application/json";
    await http
        .put(
      Uri.https(
          "api.webflow.com",
          "/collections/5be4a9a6dbcc0a24d7cb0ee9/items/" + this.id!,
          {'live': 'true'}),
      headers: header,
      body: jsonStr,
    )
        .then((result) {
      print(result.statusCode);
      print(result.body);
    });

    Map<String, dynamic> data;
    data = {
      "datum": datum,
      "antreten": antreten,
      "google-map": mapAntreten,
      "abtreten": antreten,
      "map-abtreten": mapAbtreten,
      "mitnehmen-test": upload.getJsonMitnehmen(),
      "bemerkung": bemerkung,
      "name-des-senders": sender,
      "keine-aktivitat": keineAktivitat,
      'grund': grund,
      'ferien': ferien,
      'ende-ferien': endeFerien,
    };
    await moreafire.uploadteleblitz(name!, data);
    return true;
  }
}

class Teleblitz {
  late String _name,
      _datum,
      _antreten,
      _abtreten,
      _bemerkung,
      _sender,
      _id,
      _slug,
      _jsonMitnehmen,
      _mapAntreten,
      _mapAbtreten,
      _grund,
      _endeFerien;

  late List<String> _mitnehmen;
  late bool _keineaktivitaet, _ferien;

  Teleblitz();

  Teleblitz.fromString(
    String name,
    String datum,
    String antreten,
    String mapAntreten,
    String abtreten,
    String mapAbtreten,
    List<String> mitnehmen,
    String bemerkung,
    String sender,
    bool noActivity,
    String grund,
    bool ferien,
    String endeFerien,
    String id,
    String slug,
  ) {
    _name = name;
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

  Teleblitz.fromJson(Map<String, dynamic> json) {
    for (String u in json.keys) {
      var value = json[u];
      if (u == 'mitnehmen-test') {
        if (value == null || value == '') {
          json[u] = '<ul><li>platzhalter</li></ul>';
        }
      } else {
        if (value == null || value == '') {
          json[u] = 'platzhalter';
        }
      }
    }
    this._name = json['name'];
    _datum = json['datum'];
    _antreten = json['antreten'];
    _abtreten = json['abtreten'];
    _bemerkung = json['bemerkung'];
    _sender = json['name-des-senders'];
    _id = json['_id'];
    _keineaktivitaet = json['keine-aktivitat'];
    _ferien = json['ferien'];
    _slug = json['slug'];
    _mapAntreten = json['google-map'];
    _mapAbtreten = json['map-abtreten'];
    _grund = json['grund'];
    this._mitnehmen = json["mitnehmen-test"]
        .replaceFirst("<ul>", "")
        .replaceFirst('<' + '/' + 'ul>', "")
        .replaceAll("</li><li>", ";")
        .replaceFirst("<li>", "")
        .replaceFirst("</li>", "")
        .split(";");
    this._endeFerien = _formatDate(json['ende-ferien']);
    print(json);
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
        'name': _name,
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

  String getName() {
    return this._name;
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

  String getJsonMitnehmen() {
    return this._jsonMitnehmen;
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
}
