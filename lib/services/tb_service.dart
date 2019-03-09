import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class GetTB {

  GetTB(this.filter);

  final String filter;

  Future<Info> getInfos() async{
    var data = await http.get("https://api.webflow.com/collections/5be4a9a6dbcc0a24d7cb0ee9/items?api_version=1.0.0&access_token=d9097840d357b02bd934ba7d9c52c595e6940273e940816a35062fe99e69a2de");
    var jsonData = json.decode(data.body);
    String stufe = filter;
    Info info;

    for(var u in jsonData["items"]){
      if(u["name"]==stufe){
        info = new Info(u["name"], u["antreten"], u["abtreten"], u["datum"], u["bemerkung"], u["name-des-senders"]);
      }
    }
    return info;
  }

}

class SendTB {

}

class Info {
  Info(this.titel, this.antreten, this.abtreten, this.datum, this.bemerkung, this.sender);
  String titel;
  String antreten;
  String abtreten;
  String datum;
  String bemerkung;
  String sender;
  double _sizeleft = 120;

  void setTitel(String titel){
    this.titel = titel;
  }

  void setAntreten(String antreten){
    this.antreten = antreten;
  }

  void setAbtreten(String abtreten){
    this.abtreten = abtreten;
  }

  void setDatum(String datum){
    this.datum = datum;
  }

  void setBemerkung(String bemerkung){
    this.bemerkung = bemerkung;
  }

  void setSender(String sender){
    this.sender = sender;
  }



  Container getTitel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      alignment: Alignment.topLeft,
      child: Text(this.titel, style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xff7a62ff),
          shadows: <Shadow>[
            Shadow(color: Color.fromRGBO(0, 0, 0, 0.25), offset: Offset(0, 6), blurRadius: 12),
          ]
      )),
    );
  }

  Container getAntreten(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        children: <Widget>[
          SizedBox(width: this._sizeleft,child: Text("Antreten", style: this._getStyleLeft())),
          Expanded(child: Text(this.antreten, style: this._getStyleRight(),))
        ],
      ),
      /*child: Center(
        child: Text(this.antreten, style: TextStyle(fontSize: 18)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),*/
    );
  }

  Container getAbtreten(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        children: <Widget>[
          SizedBox(width: this._sizeleft,child: Text("Abtreten", style: this._getStyleLeft())),
          Expanded(child: Text(this.abtreten, style: this._getStyleRight(),))
        ],
      ),
    );
  }

  Container getDatum(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        children: <Widget>[
          SizedBox(width: this._sizeleft,child: Text("Datum", style: this._getStyleLeft())),
          Expanded(child: Text(this.datum, style: this._getStyleRight(),))
        ],
      ),
    );
  }

  Container getBemerkung(){
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Row(
          children: <Widget>[
            SizedBox(width: this._sizeleft,child: Text("Bemerkung", style: this._getStyleLeft())),
            Expanded(child: Text(this.bemerkung, style: this._getStyleRight(),))
          ],
        )
    );
  }

  Container getSender(){
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Row(
          children: <Widget>[
            SizedBox(width: this._sizeleft,child: Text("", style: this._getStyleLeft())),
            Expanded(child: Text(this.sender, style: this._getStyleRight(),))
          ],
        )
    );
  }

  TextStyle _getStyleLeft(){
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle _getStyleRight(){
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );
  }
}