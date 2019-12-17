import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Teleblitz/werchunt.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:morea/services/utilities/url_launcher.dart';

class Teleblitz {
  MoreaFirebase moreaFire;
  Info info = new Info();
  GlobalKey<FlipCardState> teleblitzCardKey = GlobalKey<FlipCardState>();
  String eventID;
  WerChunnt werChunnt;

  Teleblitz(MoreaFirebase moreaFire) {
    this.moreaFire = moreaFire;
    this.eventID = moreaFire.getHomeFeedMainEventID;
    this.werChunnt = WerChunnt(this.moreaFire, this.eventID);
  }

  void dispose(){
    werChunnt.dispose();
  }

  void defineInfo(Map<String, dynamic> tlbz, groupID) {
    info.setTitel(convMiDatatoWebflow(groupID));
    info.setDatum(tlbz["datum"]);
    info.setAntreten(tlbz["antreten"]);
    info.setAntretenMaps(tlbz["google-map"]);
    info.setAbtreten(tlbz["abtreten"]);
    info.setAbtretenMaps(tlbz["map-abtreten"]);
    info.setBemerkung(tlbz["bemerkung"]);
    info.setSender(tlbz["name-des-senders"]);
    info.setMitnehmen(tlbz['mitnehmen-test']);
    info.setkeineAktivitat(tlbz['keine-aktivitat'].toString());
    info.setGrund(tlbz['grund']);
    info.setFerien(tlbz['ferien'].toString());
    info.setEndeFerien(tlbz['ende-ferien']);
  }

  Widget loadingScreen(Function navigation, Widget moreaLoading) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Teleblitz'),
        ),
        drawer: new Drawer(
          child: new ListView(children: navigation()),
        ),
        body: moreaLoading);
  }

  Widget keineAktivitat() {
    return MoreaShadowContainer(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            info.getTitel(),
            info.getKeineAktivitat(),
            info.getDatum(),
            info.getGrund()
          ],
        ),
      ),
    );
  }

  Widget ferien() {
    return MoreaShadowContainer(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            info.getTitel(),
            info.getKeineAktivitat(),
            info.getFerien(),
            info.getEndeFerien(),
          ],
        ),
      ),
    );
  }

  Widget teleblitz() {
    if (moreaFire.getPos != "Leiter") {
      return MoreaShadowContainer(
        child: Padding(
          padding: const EdgeInsets.all(15),
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
        ),
      );
    } else {
      return FlipCard(
        direction: FlipDirection.HORIZONTAL,
        flipOnTouch: false,
        key: teleblitzCardKey,
        front: MoreaShadowContainer(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[info.getTitel(), getWerChunntButton()],
                ),
                info.getDatum(),
                info.getAntreten(),
                info.getAbtreten(),
                info.getMitnehmen(),
                info.getBemerkung(),
                info.getSender(),
              ],
            ),
          ),
        ),
        back: MoreaShadowContainer(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Chunnt:'),
                      StreamBuilder(
                        stream: werChunnt.stream,
                        builder:
                            (context, AsyncSnapshot<List<List<String>>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading...');
                          } else if (snapshot.hasError) {
                            return Text('Error');
                          } else {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data[0].length,
                                itemBuilder: (context, i) {
                                  return Text(snapshot.data[0][i]);
                                });
                          }
                        },
                      )
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Chunnt nöd:"),
                          getTeleblitzButton(),
                        ],
                      ),
                      StreamBuilder(
                        stream: moreaFire.streamCollectionWerChunnt(this.eventID),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading...');
                          } else if (snapshot.hasError) {
                            return Text('Error');
                          } else {
                            List<DocumentSnapshot> documents = snapshot.data.documents;
                            List<String> chunntNoed = [];
                            for(DocumentSnapshot document in documents){
                              if(document.data['AnmeldeStatus'] == eventMapAnmeldeStatusNegativ){
                                chunntNoed.add(document.data['Name']);
                              }
                            }
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: chunntNoed.length,
                                itemBuilder: (context, i) {
                                  return Text(chunntNoed[i]);
                                });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget getWerChunntButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: MoreaColors.violett,
      onPressed: () => teleblitzCardKey.currentState.toggleCard(),
      child: Text(
        "Wer chunnt?",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget getTeleblitzButton() {
    return MaterialButton(
      onPressed: () => teleblitzCardKey.currentState.toggleCard(),
      child: Icon(Icons.autorenew, size: 20, color: MoreaColors.violett,),
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: 40,
      height: 20,
      elevation: 0,
    );
  }

  Widget element(Map<String, dynamic> tlbz) {
    if (tlbz["keine-aktivitat"]) {
      return keineAktivitat();
    } else if (tlbz["ferien"]) {
      return ferien();
    } else {
      return teleblitz();
    }
  }

  Widget noElement() {
    return Container(
        height: 400,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(20),
        child: Center(
          child: new Text(
            "Es sind noch keine Aktivitäten eingetragen. Bitte kontaktiere deine Leiter",
            style: new TextStyle(fontSize: 25),
          ),
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

  Map<String, Widget> anzeigen(
      String groupID, AsyncSnapshot snapshot, Widget moreaLoading) {
    Map<String, Widget> returnTelebliz = new Map();
    if (snapshot.connectionState == ConnectionState.waiting) {
      returnTelebliz[tlbzMapLoading] = moreaLoading;
      print("Loading Teleblitz");
      return returnTelebliz;
    }

    Map<String, Map<String, dynamic>> mapTeleblitz = snapshot.data[groupID];
    if (mapTeleblitz != null)
      mapTeleblitz.forEach((eventID, tlbz) {
        defineInfo(tlbz, groupID);
        returnTelebliz[eventID] = element(tlbz);
      });
    else {
      returnTelebliz[tlbzMapNoElement] = noElement();
      print("No Teleblitz");
    }
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
      child: Text(this.titel, style: MoreaTextStyle.title),
    );
  }

  Container getKeineAktivitat() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Row(
          children: <Widget>[
            Text(
              'Keine Aktivität',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
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
                child: Text("Beginn", style: this._getStyleLeft())),
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
                child: Text("Schluss", style: this._getStyleLeft())),
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
    if (this?.antreten?.isNotEmpty ?? false) {
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
                    defaultTextStyle:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
                    child: Text(
                  this.grund,
                  style: _getStyleRight(),
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
    List<String> listEndeFerien = this.endeferien.split("T")[0].split("-");
    String formatedEndeFerien =
        listEndeFerien[2] + "." + listEndeFerien[1] + "." + listEndeFerien[0];
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
                  data: formatedEndeFerien,
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
