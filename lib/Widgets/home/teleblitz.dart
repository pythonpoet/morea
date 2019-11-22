import 'package:flutter/material.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:morea/services/utilities/url_launcher.dart';


class Teleblitz{
  MoreaFirebase moreaFire;
  Info info = new Info();
  Teleblitz(MoreaFirebase moreaFire){
    this.moreaFire = moreaFire;
  }
  
  void defineInfo(Map<String, dynamic> tlbz, groupID){
    info.setTitel(convMiDatatoWebflow(groupID));
    info.setDatum(tlbz["datum"]);
    info.setAntreten(tlbz["antreten"]);
    info.setAntretenMaps(tlbz["google-map"]);
    info.setAbtreten(tlbz["abtreten"]);
    info.setAbtretenMaps(tlbz["map-abtreten"]);
    info.setBemerkung(tlbz["bemerkung"]);
    info.setSender(tlbz["name-des-senders"]);
    info.setMitnehmen(tlbz['mitnehmen-test']);
    info.setkeineAktivitat(tlbz['keine-aktivitat']);
    info.setGrund(tlbz['grund']);
    info.setFerien(tlbz['ferien']);
    info.setEndeFerien(tlbz['ende-ferien']);
  }


  Widget loadingScreen(Function navigation, Widget moreaLoading){
    return Scaffold(
          appBar: AppBar(
            title: Text('Teleblitz'),
          ),
          drawer: new Drawer(
            child: new ListView(children: navigation()),
          ),
          body: moreaLoading
        );
  }
  Widget keineAktivitat(){
    return Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      info.getTitel(),
                      info.getKeineAktivitat(),
                      info.getDatum(),
                      info.getGrund()
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
  Widget ferien(){
    return Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      info.getTitel(),
                      info.getKeineAktivitat(),
                      info.getFerien(),
                      info.getEndeFerien(),
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
  Widget teleblitz (){
    return Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      info.getTitel(),
                      info.getDatum(),
                      info.getAntreten(),
                      info.getAbtreten(),
                      info.getMitnehmen(),
                      info.getBemerkung(),
                      info.getSender(),
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
                  ));}
  
  Widget element(Map<String, dynamic> tlbz){
    if (tlbz["keineaktivitat"] == 'true') {
                return keineAktivitat();
              } else if (tlbz["ferien"] == 'true') {
                 return ferien();
              }
    return teleblitz();
  }
  Widget noElement(){
    return Container(
      height: 400,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(20),
      child: Center(
        child: new Text("Es sind noch keine Aktivitäten eingetragen. Bitte kontaktiere deine Leiter", style: new TextStyle(fontSize: 25),),
    ),
     decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.16),
                          offset: Offset(3, 3),
                          blurRadius: 40)
                    ],
                  )
    );
  }

  List<Widget> anzeigen(String groupID, AsyncSnapshot snapshot, Widget moreaLoading){
    
    List<Widget> returnTelebliz = new List<Widget>();
    if(snapshot.data == null){
       returnTelebliz.add(moreaLoading);
       return returnTelebliz;
    }
    
    
    
    Map<String, Map<String, dynamic>> mapTeleblitz = snapshot.data[groupID];
    if(mapTeleblitz!= null)
    mapTeleblitz.forEach((eventID,tlbz){
      defineInfo(tlbz, groupID);
      returnTelebliz.add(element(tlbz));
    });
    else
      returnTelebliz.add(noElement());
    return returnTelebliz;
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
    if (this?.antreten?.isNotEmpty ?? false) {
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
    if (this?.abtreten?.isNotEmpty ?? false) {
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
    if (this?.bemerkung?.isNotEmpty ?? false) {
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
    if (this?.sender?.isNotEmpty ?? false) {
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
    if (this?.antreten?.isNotEmpty ?? false){
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