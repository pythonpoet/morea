import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Teleblitz/werchunt.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:morea/services/utilities/url_launcher.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';

enum ElementType{ferien, keineAktivitaet, teleblitz, notImplemented}
enum HomeScreenType{loading, noElement, info}
class Teleblitz {
  MoreaFirebase moreaFire;
  Info info = new Info();
  GlobalKey<FlipCardState> teleblitzCardKey = GlobalKey<FlipCardState>();
  String eventID;
  CrudMedthods crud0;
  Map<String, dynamic> anmeldeDaten, groupInfo;
  bool chunnt = false;
  final ScrollController _clickController = new ScrollController();
  Map<String,Stream<String>> anmeldeStream = new Map();
  Map<String, StreamController<String>> anmeldeStreamController = new Map();

  Teleblitz(MoreaFirebase moreaFire, CrudMedthods crud0) {
    this.moreaFire = moreaFire;
    this.crud0 = crud0;
  }
  
  void submit(String anabmelden, String groupnr, String eventID, String uid, {String name}) {
     _clickController.animateTo(0.0, curve: Curves.easeOut, duration: const Duration(milliseconds: 400));
    String anmeldung;

    if (anabmelden == 'Chunt') {
      anmeldung = 'Du hast dich Angemolden';
      chunnt = true;
    } else {
      anmeldung = 'Du hast dich Abgemolden';
      chunnt = false;
    }
    if(name == null){
      name = moreaFire.getDisplayName;
    }
    if (moreaFire.getGroupPrivilege[groupnr]< 2) {
      moreaFire.childAnmelden(eventID, moreaFire.getUserMap[userMapUID],
           moreaFire.getUserMap[userMapUID], anabmelden, name);
    } else {
      moreaFire.parentAnmeldet(eventID,uid, moreaFire.getUserMap[userMapUID],
      anabmelden, name);
    }
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
  Widget parentAnmeldeButton(String groupID, String eventID) {
    List<Widget> anmeldebuttons = new List();
    moreaFire.getChildMap[groupID].forEach((String vorname, uid) {
      anmeldebuttons.add(anmeldebutton(
          groupID, eventID, uid, "$vorname anmelden", "$vorname abmelden",
          name: vorname));
    });
    return Column(children: anmeldebuttons);
  }

  Widget childAnmeldeButton(String groupID, String eventID) {
    return anmeldebutton(moreaFire.getGroupID, eventID, moreaFire.getUserMap[userMapUID],
        'Chume', 'Chume nöd');
  }

  Widget anmeldebutton(
      String groupID, String eventID, String uid, String anmelden, abmelden,
      {String name}) {
    return StreamBuilder(
      stream: anmeldeStreamController[uid].stream,
      builder: (BuildContext context, snap){
          switch (snap.data) {
          case "un-initialized":
              return Container(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: new RaisedButton(
                          child: new Text(abmelden, style: new TextStyle(fontSize: 20)),
                          onPressed: () {
                            if (name == null) {
                              submit(eventMapAnmeldeStatusNegativ, groupID, eventID, uid);
                            } else {
                              submit(eventMapAnmeldeStatusNegativ, groupID, eventID, uid,
                                  name: name);
                            }
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                        ),
                      )),
                      Expanded(
                        child: Container(
                          child: new RaisedButton(
                            child: new Text(anmelden, style: new TextStyle(fontSize: 20)),
                            onPressed: () {
                              if (name == null) {
                                submit(eventMapAnmeldeStatusPositiv,groupID, eventID, uid);
                              } else {
                                submit(eventMapAnmeldeStatusPositiv, groupID, eventID, uid,
                                    name: name);
                              }
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            color: Color(0xff7a62ff),
                            textColor: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ));
            break;
          case "ChuntNoed":
                return Container(
                          child: new RaisedButton(
                            child: Container(child: Center(child: new Text(anmelden, style: new TextStyle(fontSize: 20))), width: 120,),
                            onPressed: () {
                              if (name == null) {
                                submit(eventMapAnmeldeStatusPositiv,groupID, eventID, uid);
                              } else {
                                submit(eventMapAnmeldeStatusPositiv, groupID, eventID, uid,
                                    name: name);
                              }
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            color: Color(0xff7a62ff),
                            textColor: Colors.white,
                          ),
                        );
          case "Chunt":
              return Container(
                        child: new RaisedButton(
                          child: new Text(abmelden, style: new TextStyle(fontSize: 20)),
                          onPressed: () {
                            if (name == null) {
                              submit(eventMapAnmeldeStatusNegativ, groupID, eventID, uid);
                            } else {
                              submit(eventMapAnmeldeStatusNegativ, groupID, eventID, uid,
                                  name: name);
                            }
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                        ),
                      );
          default:
            return Text(snap.data);
        }
      },
    );
  }
  Widget parentAnmeldeIndicator(String groupID, String eventID,  Stream<String> Function(String userID, String eventID) function) {
    List<Widget> anmeldebuttons = new List();
    moreaFire.getChildMap[groupID].forEach((String vorname, uid) {
            anmeldeStreamController[uid] = new BehaviorSubject();
            anmeldeStreamController[uid].addStream(function(uid, eventID));
      anmeldebuttons.add(anmeldeIndicator(
           uid, eventID, function, "$vorname ist angemolden", "$vorname ist abgemolden",
         ));
    });
    return Column(children: anmeldebuttons);
  }
  Widget childAnmeldeIndicator(String userID, String eventID, Stream<String> Function(String userID, String eventID) function){
    anmeldeStreamController[userID] = new BehaviorSubject();
    anmeldeStreamController[userID].addStream(function(userID, eventID));
    return anmeldeIndicator(userID, eventID, function, "Du hast dich angemolden", "Du hast dich abgemolden");
  }
  Widget anmeldeIndicator(String userID, String eventID, Stream<String> Function(String userID, String eventID) function, String angemolden, String abgemolden){
    return StreamBuilder(
      stream: anmeldeStreamController[userID].stream,
      builder: (BuildContext context, AsyncSnapshot<String> snap){
        if(!snap.hasData)
          return simpleMoreaLoadingIndicator();
        switch (snap.data) {
          case "un-initialized":
              return Container();
            break;
          case "ChuntNoed":
                return Container(height: 40, 
               child: Center(child:Text(abgemolden, style: TextStyle(fontSize: 20),),),
               width: double.infinity,
               decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4),),
                                        color: Colors.grey[300]),);
          case "Chunt":
              return Container(height: 40, 
               child: Center(child:Text(angemolden, style: TextStyle(fontSize: 20),),),
               width: double.infinity,
               decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4),),
                                        color: MoreaColors.violett),);
          default:
            return Text(snap.data);
        }
      },
    );
  }

  Widget parentShare(String groupID){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Teile diese Akivität", style: TextStyle(color: Colors.grey[600]),),
          IconButton(
            icon: Icon(Icons.share, color: Colors.grey[600]),
            onPressed: () =>{
                  Share.share("Lust auf Pfadi? Komm mal bei den ${convMiDatatoWebflow(groupID)} vorbei: https://www.morea.ch/teleblitz")
                },
          )
        ],
      )
    );
  }

  Widget teleblitz(String groupID, String eventID,Stream<String> Function(String userID, String eventID) function) {
    switch (moreaFire.getGroupPrivilege[groupID]) {
      case 0:
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
                  parentShare(groupID)
                ],
              ),
            ),
          );
      case 1:
         return MoreaShadowContainer(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              childAnmeldeIndicator(moreaFire.getUserMap[userMapUID], eventID, function),
              info.getTitel(),
              info.getDatum(),
              info.getAntreten(),
              info.getAbtreten(),
              info.getMitnehmen(),
              info.getBemerkung(),
              info.getSender(),
              childAnmeldeButton(groupID, eventID),
              parentShare(groupID),
            ],
          ),
        ),
      );
      case 2:
        return MoreaShadowContainer(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              parentAnmeldeIndicator(groupID,eventID, function),
              info.getTitel(),
              info.getDatum(),
              info.getAntreten(),
              info.getAbtreten(),
              info.getMitnehmen(),
              info.getBemerkung(),
              info.getSender(),
              parentAnmeldeButton(groupID, eventID),
              parentShare(groupID)
            ],
          ),
        ),
      );
      case 3:
     WerChunnt werChunnt = new WerChunnt(moreaFire, eventID);
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
                parentShare(groupID)
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
                        builder: (context,
                            AsyncSnapshot<List<List<String>>> snapshot) {
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
                        stream:
                            moreaFire.streamCollectionWerChunnt(eventID),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading...');
                          } else if (snapshot.hasError) {
                            return Text('Error');
                          } else {
                            List<DocumentSnapshot> documents =
                                snapshot.data.documents;
                            List<String> chunntNoed = [];
                            for (DocumentSnapshot document in documents) {
                              if (document.data['AnmeldeStatus'] ==
                                  eventMapAnmeldeStatusNegativ) {
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
      default:
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
      child: Icon(
        Icons.autorenew,
        size: 20,
        color: MoreaColors.violett,
      ),
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: 40,
      height: 20,
      elevation: 0,
    );
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
  Widget notImplemented() {
    return Container(
        height: 200,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(20),
        child: Center(
          child: new Text(
            "Dieses Element wird nicht unterstützt, update die App um dieses Element anzeigen zu können",
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
  ElementType getElementType(Map<String,dynamic> tlbz){
    if(tlbz.containsKey("TeleblitzType"))
      if(tlbz["TeleblitzType"]!="Teleblitz")
        return ElementType.notImplemented;
    var keineAkt = tlbz["keine-aktivitat"];
    var keineFerien =tlbz["ferien"];
    if(keineAkt.runtimeType == String){
      keineAkt = keineAkt.toLowerCase() == 'true';
    }
    if(keineFerien.runtimeType == String){
      keineFerien = keineFerien.toLowerCase() == 'true';
    }

    if (keineAkt) {
      return ElementType.keineAktivitaet;
    } else if (keineFerien) {
      return ElementType.ferien;
    } else {
      return ElementType.teleblitz;
    }
    
  }
  HomeScreenType getHomeScreenType( AsyncSnapshot snapshot){
    try{
    if(snapshot.connectionState == ConnectionState.waiting)
      return HomeScreenType.loading;
    if(snapshot.data == null)
      return HomeScreenType.noElement;
    return HomeScreenType.info;
    }catch(e){
      print(e);
      return HomeScreenType.loading;
    }
  }

  Map<String, Widget> anzeigen(
      String groupID, AsyncSnapshot snapshot,  moreaLoading, Stream<String> Function(String userID, String eventID) function) {
    Map<String, Widget> returnTelebliz = new Map();
    switch (getHomeScreenType(snapshot)) {
      case HomeScreenType.loading:
        returnTelebliz[tlbzMapLoading] = moreaLoading();
        return returnTelebliz;
      case HomeScreenType.noElement:
        returnTelebliz[tlbzMapNoElement] = noElement();
        return returnTelebliz;
      case HomeScreenType.info:
      snapshot.data[groupID].forEach((String eventID, Map<String, dynamic> tlbz){
        switch (getElementType(tlbz)) {
          case ElementType.notImplemented:
            returnTelebliz[eventID] = notImplemented();
            break;
          case ElementType.ferien:
            returnTelebliz[eventID] = ferien();
            break;
          case ElementType.keineAktivitaet:
            returnTelebliz[eventID] = keineAktivitat();
            break;
          case ElementType.teleblitz:
            defineInfo(tlbz, groupID);
            returnTelebliz[eventID] = teleblitz(groupID, eventID ,function);
        }
        
      });
        
    }
    return returnTelebliz; 
  }
  Widget displayContent( loading, groupID){
    return StreamBuilder(
      stream: moreaFire.tbz.getMapofEvents,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        List<Widget> anzeige = new List();
        this.anzeigen(groupID, snapshot,  loading, moreaFire.tbz.anmeldeStatus)
            .forEach((String eventID, tlbz) {

            anzeige.add(
            tlbz
            );
        });
        return MoreaBackgroundContainer(
          child: SingleChildScrollView(
            controller: _clickController,
            child: Column(children: anzeige),
          ),
        );
      },
    );
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
  double _sizeleft = 120;

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
    }else{
      return Container();
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
