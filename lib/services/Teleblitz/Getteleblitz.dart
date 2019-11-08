import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/morea_strings.dart';
import 'dart:async';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:morea/services/utilities/url_launcher.dart';

abstract class BaseTeleblitz {
  Widget anzeigen(String _stufe);
  Future<Info> getInfos(String filter);
  String _formatDate(String date); 
}

class Teleblitz implements BaseTeleblitz {
  MoreaFirebase moreafire;
  bool block = false;
  Map groupData;
  String eventID,groupID;


  Teleblitz(Firestore firestore, Map<String,dynamic> groupData){
    moreafire = new MoreaFirebase(firestore);
    this.groupData = groupData;
    groupID = groupData["groupID"];
    if(groupData.containsKey("AktuellerTeleblitz")){
      eventID = groupData["AktuellerTeleblitz"];
    }
  }
  String getEventID(){
    return this.eventID;
  }

    
  

  String _formatDate(String date) {
    if (date != '' && date!=null) {
      String rawDate = date.split('T')[0];
      List<String> dates = rawDate.split('-');
      String formatedDate = dates[2] + '.' + dates[1] + '.' + dates[0];
      return formatedDate;
    } else {
      return '';
    }
  }

  Future<Info> getInfos(String filter) async {
    var jsonData;
    var data;
    var info = new Info();
    String groupID = filter;

    if (groupID != '@') {
        await moreafire.getteleblitz(eventID).then((result) {
          info.setTitel(convMiDatatoWebflow(groupID));
          info.setDatum(result["datum"]);
          info.setAntreten(result["antreten"]);
          info.setAntretenMaps(result["google-map"]);
          info.setAbtreten(result["abtreten"]);
          info.setAbtretenMaps(result["map-abtreten"]);
          info.setBemerkung(result["bemerkung"]);
          info.setSender(result["name-des-senders"]);
          info.setMitnehmen(result['mitnehmen-test']);
          info.setkeineAktivitat(result['keine-aktivitat']);
          info.setGrund(result['grund']);
          info.setFerien(result['ferien']);
          info.setEndeFerien(result['ende-ferien']);
        });
      }
      return info;
    }
        

  Widget anzeigen(String _stufe) {
    try {
      return new StreamBuilder(
          stream: Firestore.instance.collection(pathEvents).document(_stufe).snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                    child: Container(
                  padding: EdgeInsets.all(120),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: new Text('Loading...'),
                      ),
                      Expanded(child: new CircularProgressIndicator())
                    ],
                  ),
                )),
              );
            } else {
              if (snapshot.data.keineaktivitat == 'true') {
                return Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      snapshot.data.getTitel(),
                      snapshot.data.getKeineAktivitat(),
                      snapshot.data.getDatum(),
                      snapshot.data.getGrund()
                    ],
                  ),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                        offset: Offset(3, 3),
                        blurRadius: 40)
                  ]),
                );
              } else if (snapshot.data.ferien == 'true') {
                return Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      snapshot.data.getTitel(),
                      snapshot.data.getKeineAktivitat(),
                      snapshot.data.getFerien(),
                      snapshot.data.getEndeFerien(),
                    ],
                  ),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                        offset: Offset(3, 3),
                        blurRadius: 40)
                  ]),
                );
              }
              return Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      snapshot.data.getTitel(),
                      snapshot.data.getDatum(),
                      snapshot.data.getAntreten(),
                      snapshot.data.getAbtreten(),
                      snapshot.data.getMitnehmen(),
                      snapshot.data.getBemerkung(),
                      snapshot.data.getSender(),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.16),
                          offset: Offset(3, 3),
                          blurRadius: 40)
                    ],
                  ));
            }
          });
    } catch (e) {
      print(e);
      return Center(
        child: Text(
          'Internet?',
          style: TextStyle(fontSize: 20),
        ),
      );
    }
  }
}

class Info {
//  static Info _instance;
//
//  factory Info() => _instance ??= new Info._();
//
//  Info._();

  Urllauncher urllauncher = new Urllauncher();

  String titel;
  String antreten;
  String antretenMap;
  String abtreten;
  String abtretenMap;
  String datum;
  String bemerkung;
  String sender;
  String mitnehmen;
  String keineaktivitat;
  String grund;
  String ferien;
  String endeferien;
  double _sizeleft = 110;

  void setTitel(String titel) {
    this.titel = titel;
  }

  void setAntreten(String antreten) {
    this.antreten = antreten;
  }

  void setAntretenMaps(String antretenMaps) {
    this.antretenMap = antretenMaps;
  }

  void setAbtreten(String abtreten) {
    this.abtreten = abtreten;
  }

  void setAbtretenMaps(String abtretenMaps) {
    this.abtretenMap = abtretenMaps;
  }

  void setDatum(String datum) {
    this.datum = datum;
  }

  void setBemerkung(String bemerkung) {
    this.bemerkung = bemerkung;
  }

  void setSender(String sender) {
    this.sender = sender;
  }

  void setMitnehmen(mitnehmen) {
    this.mitnehmen = mitnehmen;
  }

  void setkeineAktivitat(String aktv) {
    this.keineaktivitat = aktv;
  }

  void setGrund(String grund) {
    this.grund = grund;
  }

  void setFerien(String ferien) {
    this.ferien = ferien;
  }

  void setEndeFerien(String endeferien) {
    this.endeferien = endeferien;
  }

  Container getTitel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      alignment: Alignment.topLeft,
      child: Text(this.titel,
          style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xff7a62ff),
              shadows: <Shadow>[
                Shadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    offset: Offset(0, 6),
                    blurRadius: 12),
              ])),
    );
  }

  Container getKeineAktivitat() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Row(
          children: <Widget>[
            SizedBox(
              child: Text(
                'Keine Aktivität',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Expanded(
              child: SizedBox(),
            )
          ],
        ));
  }

  Container getAntreten() {
    if ((keineaktivitat == 'false') || (this?.antreten?.isNotEmpty ?? false)) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: this._sizeleft,
                child: Text("Antreten", style: this._getStyleLeft())),
            Expanded(
              child: InkWell(
                child: Text(
                  this.antreten,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 0, 0, 255),
                      decoration: TextDecoration.underline),
                ),
                onTap: () {
                  urllauncher.openlinkMaps(this.antretenMap);
                },
              ),
            )
          ],
        ),
        /*child: Center(
        child: Text(this.antreten, style: TextStyle(fontSize: 18)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),*/
      );
    }
  }

  Container getAbtreten() {
    if ((keineaktivitat == false) || (this?.abtreten?.isNotEmpty ?? false)) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: this._sizeleft,
                child: Text("Abtreten", style: this._getStyleLeft())),
            Expanded(
                child: InkWell(
              child: Text(
                this.abtreten,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 0, 0, 255),
                    decoration: TextDecoration.underline),
              ),
              onTap: () {
                urllauncher.openlinkMaps(this.abtretenMap);
              },
            ))
          ],
        ),
      );
    } else {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Row(
            children: <Widget>[
              SizedBox(),
              Expanded(
                child: SizedBox(),
              )
            ],
          ));
    }
  }

  Container getDatum() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
              width: this._sizeleft,
              child: Text("Datum", style: this._getStyleLeft())),
          Expanded(
              child: Text(
            this.datum,
            style: this._getStyleRight(),
          ))
        ],
      ),
    );
  }

  Container getBemerkung() {
    if ((keineaktivitat == false) || (this?.bemerkung?.isNotEmpty ?? false)) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        width: this._sizeleft,
                        child: Text("Bemerkung:", style: this._getStyleLeft())),
                    /*Expanded(
                  child: Text(
                this.bemerkung,
                style: this._getStyleRight(),
              ))*/
                  ],
                ),
              ),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      this.bemerkung,
                      style: this._getStyleRight(),
                    ))
                  ],
                ),
              ),
            ],
          ));
    } else {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Row(
            children: <Widget>[
              SizedBox(),
              Expanded(
                child: SizedBox(),
              )
            ],
          ));
    }
  }

  Container getSender() {
    if ((keineaktivitat == false) || (this?.sender?.isNotEmpty ?? false)) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                  width: this._sizeleft,
                  child: Text("", style: this._getStyleLeft())),
              Expanded(
                  child: Text(
                this.sender,
                style: this._getStyleRight(),
              ))
            ],
          ));
    } else {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Row(
            children: <Widget>[
              SizedBox(),
              Expanded(
                child: SizedBox(),
              )
            ],
          ));
    }
  }

  Container getMitnehmen() {
    if ((keineaktivitat == false) || (this?.antreten?.isNotEmpty ?? false)) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        width: this._sizeleft,
                        child: Text("Mitnehmen:", style: this._getStyleLeft())),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: Html(
                    data: this.mitnehmen,
                    defaultTextStyle: _getStyleRight(),
                  ))
                ],
              ),
            ],
          ));
    } else {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: Row(
            children: <Widget>[
              SizedBox(),
              Expanded(
                child: SizedBox(),
              )
            ],
          ));
    }
  }

  Container getGrund() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      width: this._sizeleft,
                      child: Text("Grund:", style: this._getStyleLeft())),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Html(
                  data: this.grund,
                  defaultTextStyle: _getStyleRight(),
                ))
              ],
            ),
          ],
        ));
  }

  Container getFerien() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      width: this._sizeleft,
                      child: Text("Grund:", style: this._getStyleLeft())),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Text(
                  "Die Aktivität fällt leider wegen der Schulferien aus.",
                  style: this._getStyleRight(),
                ))
              ],
            ),
          ],
        ));
  }

  Container getEndeFerien() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      width: this._sizeleft,
                      child: Text("Ende Ferien:", style: this._getStyleLeft())),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Html(
                  data: this.endeferien,
                  defaultTextStyle: _getStyleRight(),
                ))
              ],
            ),
          ],
        ));
  }

  TextStyle _getStyleLeft() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle _getStyleRight() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
  }
}
