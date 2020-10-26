import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/Pages/Teleblitz/werchunt.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/Event/data_types/Teleblitz_data.dart';
import 'package:morea/services/Event/event_data.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:morea/services/utilities/url_launcher.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';

enum ElementType { ferien, keineAktivitaet, teleblitz, notImplemented }
enum HomeScreenType { loading, noElement, info }

class Teleblitz {
  MoreaFirebase moreaFire;
  Info info = new Info();
  GlobalKey<FlipCardState> teleblitzCardKey = GlobalKey<FlipCardState>();
  String eventID;
  CrudMedthods crud0;
  Map<String, dynamic> anmeldeDaten, groupInfo;
  bool chunnt = false;
  Map<String, Stream<String>> anmeldeStream = new Map();
  Map<String, StreamController<String>> anmeldeStreamController = new Map();

  Teleblitz(MoreaFirebase moreaFire, CrudMedthods crud0) {
    this.moreaFire = moreaFire;
    this.crud0 = crud0;
  }
  int getHighestEventPriviledge(List<String> groupIDs) {
    if (groupIDs == null) return 0;
    int returnValue = 0;
    for (int i = 0; i < groupIDs.length; i++) {
      if (moreaFire.getGroupIDs.contains(groupIDs[i])) {
        if (moreaFire.getMapGroupData[groupIDs[i]].priviledge.role
                .teleblitzPriviledge ==
            null)
          throw 'Teleblitz Priviledge cant be null';
        else if (moreaFire.getMapGroupData[groupIDs[i]].priviledge.role
                .teleblitzPriviledge >
            returnValue)
          returnValue = moreaFire
              .getMapGroupData[groupIDs[i]].priviledge.role.teleblitzPriviledge;
      }
    }
    return returnValue;
  }

  void submit(
      String anabmelden, List<String> groupIDs, String eventID, String uid,
      {String name}) {
    HomePageState.homeScreenScrollController.animateTo(0.0,
        curve: Curves.easeOut, duration: const Duration(milliseconds: 400));

    if (anabmelden == 'Chunt') {
      chunnt = true;
    } else {
      chunnt = false;
    }
    if (name == null) {
      name = moreaFire.getDisplayName;
    }
    if (this.getHighestEventPriviledge(groupIDs) < 2) {
      moreaFire.childAnmelden(eventID, moreaFire.getUserMap[userMapUID],
          moreaFire.getUserMap[userMapUID], anabmelden, name);
    } else {
      moreaFire.parentAnmeldet(
          eventID, uid, moreaFire.getUserMap[userMapUID], anabmelden, name);
    }
  }

  void defineInfo(TeleblitzData eventData) {
    info.setTitel(eventData.name);
    info.setDatum(eventData.datum);
    info.setAntreten(eventData.antreten);
    info.setAntretenMaps(eventData.googleMap);
    info.setAbtreten(eventData.abtreten);
    info.setAbtretenMaps(eventData.mapAbtreten);
    info.setBemerkung(eventData.bemerkung);
    info.setSender(eventData.nameDesSenders);
    info.setMitnehmen(eventData.mitnehmenTest);
    info.setkeineAktivitat(eventData.keineAktivitaet);
    info.setGrund(eventData.grund);
    info.setFerien(eventData.ferien.toString());
    info.setEndeFerien(eventData.endeFerien);
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

  Widget parentAnmeldeButton(List<String> groupIDs, String eventID) {
    List<Widget> anmeldebuttons = new List();

    groupIDs.forEach((String groupID) {
      moreaFire.getChildMap[groupID].forEach((String uid, vorname) {
        anmeldebuttons.add(
            anmeldebutton(groupIDs, eventID, uid, "ja", "nein", name: vorname));
      });
    });

    return Column(children: anmeldebuttons);
  }

  Widget childAnmeldeButton(List<String> groupIDs, String eventID) {
    return anmeldebutton(
      groupIDs,
      eventID,
      moreaFire.getUserMap[userMapUID],
      'Chume',
      'Chume nöd',
    );
  }

  Widget parentListTitle() {
    return Container(
        padding: EdgeInsets.only(top: 30, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 120, child: Text("", style: MoreaTextStyle.lable)),
            Expanded(
                child: Text(
              'Bist du dabei?',
              style: MoreaTextStyle.lable,
            ))
          ],
        ));
  }

  Widget childListTitle(String displayname) {
    return Container(
        padding: EdgeInsets.only(top: 30, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 120, child: Text("", style: MoreaTextStyle.lable)),
            Expanded(
                child: Text(
              '$displayname, bist du dabei?',
              style: MoreaTextStyle.lable,
            ))
          ],
        ));
  }

  Widget anmeldebutton(List<String> groupIDs, String eventID, String uid,
      String anmelden, abmelden,
      {String name}) {
    return StreamBuilder(
      stream: anmeldeStreamController[uid].stream,
      builder: (BuildContext context, snap) {
        if (snap.connectionState == ConnectionState.active) {
          switch (snap.data) {
            case "un-initialized":
              return Container(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          name == null ? '' : name,
                          style: MoreaTextStyle.lable,
                        ),
                      ),
                      Flexible(
                        child: RaisedButton(
                          elevation: 0,
                          padding: EdgeInsets.all(0),
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 15),
                              constraints:
                                  BoxConstraints(minWidth: 170, maxWidth: 170),
                              child: Center(
                                  child: new Text(abmelden,
                                      style: MoreaTextStyle.flatButton))),
                          onPressed: () {
                            if (name == null) {
                              submit(eventMapAnmeldeStatusNegativ, groupIDs,
                                  eventID, uid);
                            } else {
                              submit(eventMapAnmeldeStatusNegativ, groupIDs,
                                  eventID, uid,
                                  name: name);
                            }
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 5),
                      ),
                      Flexible(
                        child: RaisedButton(
                          padding: EdgeInsets.all(0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 15),
                            constraints:
                                BoxConstraints(maxWidth: 170, minWidth: 170),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  MoreaColors.orange,
                                  MoreaColors.violett
                                ]),
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                                child: new Text(anmelden,
                                    style: MoreaTextStyle.raisedButton)),
                            width: 120,
                          ),
                          onPressed: () {
                            if (name == null) {
                              submit(eventMapAnmeldeStatusPositiv, groupIDs,
                                  eventID, uid);
                            } else {
                              submit(eventMapAnmeldeStatusPositiv, groupIDs,
                                  eventID, uid,
                                  name: name);
                            }
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: Colors.transparent,
                          textColor: Colors.white,
                        ),
                      )
                    ],
                  ));
              break;
            case "ChuntNoed":
              return Container(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        name == null ? '' : name,
                        style: MoreaTextStyle.lable,
                      ),
                    ),
                    Flexible(
                      child: Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                    ),
                    Flexible(
                      child: new RaisedButton(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                          constraints:
                              BoxConstraints(maxWidth: 170, minWidth: 170),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                MoreaColors.orange,
                                MoreaColors.violett
                              ]),
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                              child: new Text(anmelden,
                                  style: MoreaTextStyle.flatButton)),
                          width: 120,
                        ),
                        onPressed: () {
                          if (name == null) {
                            submit(eventMapAnmeldeStatusPositiv, groupIDs,
                                eventID, uid);
                          } else {
                            submit(eventMapAnmeldeStatusPositiv, groupIDs,
                                eventID, uid,
                                name: name);
                          }
                        },
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.transparent,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            case "Chunt":
              return Container(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        name == null ? '' : name,
                        style: MoreaTextStyle.lable,
                      ),
                    ),
                    Flexible(
                      child: new RaisedButton(
                        elevation: 0,
                        padding: EdgeInsets.all(0),
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 15),
                            constraints:
                                BoxConstraints(minWidth: 170, maxWidth: 170),
                            child: Center(
                                child: new Text(abmelden,
                                    style: MoreaTextStyle.flatButton))),
                        onPressed: () {
                          if (name == null) {
                            submit(eventMapAnmeldeStatusNegativ, groupIDs,
                                eventID, uid);
                          } else {
                            submit(eventMapAnmeldeStatusNegativ, groupIDs,
                                eventID, uid,
                                name: name);
                          }
                        },
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                    ),
                    Flexible(
                      child: Container(),
                    ),
                  ],
                ),
              );
            default:
              return Text(snap.data);
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget parentAnmeldeIndicator(List<String> groupIDs, String eventID,
      Stream<String> Function(String userID, String eventID) function) {
    List<Widget> anmeldebuttons = new List();
    groupIDs.forEach((String groupID) {
      moreaFire.getChildMap[groupID].forEach((String uid, vorname) {
        anmeldeStreamController[uid] = new BehaviorSubject();
        anmeldeStreamController[uid].addStream(function(uid, eventID));
        anmeldebuttons.add(anmeldeIndicator(
          uid,
          eventID,
          function,
          "$vorname ist angemolden",
          "$vorname ist abgemolden",
        ));
      });
    });
    return Column(children: anmeldebuttons);
  }

  Widget childAnmeldeIndicator(String userID, String eventID,
      Stream<String> Function(String userID, String eventID) function) {
    anmeldeStreamController[userID] = new BehaviorSubject();
    anmeldeStreamController[userID].addStream(function(userID, eventID));
    return anmeldeIndicator(userID, eventID, function,
        "Du hast dich angemolden", "Du hast dich abgemolden");
  }

  Widget anmeldeIndicator(
      String userID,
      String eventID,
      Stream<String> Function(String userID, String eventID) function,
      String angemolden,
      String abgemolden) {
    return StreamBuilder(
      stream: anmeldeStreamController[userID].stream,
      builder: (BuildContext context, AsyncSnapshot<String> snap) {
        if (!snap.hasData) return simpleMoreaLoadingIndicator();
        switch (snap.data) {
          case "un-initialized":
            return Container();
            break;
          case "ChuntNoed":
            return Container(
              height: 40,
              child: Center(
                child: Text(
                  abgemolden,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                  color: Colors.grey[300]),
            );
          case "Chunt":
            return Container(
              height: 40,
              child: Center(
                child: Text(
                  angemolden,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                  color: MoreaColors.violett),
            );
          default:
            return Text(snap.data);
        }
      },
    );
  }

  Widget parentShare(String name) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Teile diese Akivität",
          style: TextStyle(color: Colors.grey[600]),
        ),
        IconButton(
          icon: Icon(Icons.share, color: Colors.grey[600]),
          onPressed: () => {
            Share.share(
                "Lust auf Pfadi? Komm mal bei den $name vorbei: https://www.morea.ch/teleblitz")
          },
        )
      ],
    ));
  }

  Widget teleblitz(String name, List<String> groupIDs, String eventID,
      Stream<String> Function(String userID, String eventID) function) {
    switch (this.getHighestEventPriviledge(groupIDs)) {
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
                parentShare(name)
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
                childAnmeldeIndicator(
                    moreaFire.getUserMap[userMapUID], eventID, function),
                info.getTitel(),
                info.getDatum(),
                info.getAntreten(),
                info.getAbtreten(),
                info.getMitnehmen(),
                info.getBemerkung(),
                info.getSender(),
                childListTitle(moreaFire.getDisplayName),
                childAnmeldeButton(groupIDs, eventID),
                parentShare(name),
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
                parentAnmeldeIndicator(groupIDs, eventID, function),
                info.getTitel(),
                info.getDatum(),
                info.getAntreten(),
                info.getAbtreten(),
                info.getMitnehmen(),
                info.getBemerkung(),
                info.getSender(),
                parentListTitle(),
                parentAnmeldeButton(groupIDs, eventID),
                parentShare(name)
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
                    children: <Widget>[
                      info.getTitel(),
                      turnFlipCardTeleblitz()
                    ],
                  ),
                  info.getDatum(),
                  info.getAntreten(),
                  info.getAbtreten(),
                  info.getMitnehmen(),
                  info.getBemerkung(),
                  info.getSender(),
                  parentShare(name)
                ],
              ),
            ),
          ),
          back: MoreaShadowContainer(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Wer chunnt?',
                          style: MoreaTextStyle.title,
                        ),
                      ),
                      turnFlipCardTeleblitz(),
                    ],
                  ),
                  Row(
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
                            Text(
                              'Chunnt:',
                              style: MoreaTextStyle.lable,
                            ),
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
                                      itemCount: snapshot.data[0].length + 1,
                                      itemBuilder: (context, i) {
                                        if (i < snapshot.data[0].length) {
                                          return Text(
                                            snapshot.data[0][i],
                                            style: MoreaTextStyle.normal,
                                          );
                                        } else {
                                          return Text(
                                            'Total: ' +
                                                snapshot.data[0].length
                                                    .toString(),
                                            style: MoreaTextStyle.normal,
                                          );
                                        }
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
                            Text(
                              'Chunnt nöd:',
                              style: MoreaTextStyle.lable,
                            ),
                            StreamBuilder(
                              stream:
                                  moreaFire.streamCollectionWerChunnt(eventID),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                    if (document.data()['AnmeldeStatus'] ==
                                        eventMapAnmeldeStatusNegativ) {
                                      chunntNoed.add(document.data()['Name']);
                                    }
                                  }
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: chunntNoed.length + 1,
                                      itemBuilder: (context, i) {
                                        if (i < chunntNoed.length) {
                                          return Text(
                                            chunntNoed[i],
                                            style: MoreaTextStyle.normal,
                                          );
                                        } else {
                                          return Text(
                                            'Total: ' +
                                                chunntNoed.length.toString(),
                                            style: MoreaTextStyle.normal,
                                          );
                                        }
                                      });
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                  )
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

  Widget turnFlipCardTeleblitz() {
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

  ElementType getElementType(Map<String, dynamic> tlbz) {
    if (tlbz.containsKey("TeleblitzType")) if (tlbz["TeleblitzType"] !=
        "Teleblitz") return ElementType.notImplemented;
    var keineAkt = tlbz["keine-aktivitat"];
    var keineFerien = tlbz["ferien"];
    if (keineAkt.runtimeType == String) {
      keineAkt = keineAkt.toLowerCase() == 'true';
    }
    if (keineFerien.runtimeType == String) {
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

  HomeScreenType getHomeScreenType(AsyncSnapshot snapshot) {
    try {
      if (snapshot.connectionState == ConnectionState.waiting)
        return HomeScreenType.loading;
      if (snapshot.data == null) return HomeScreenType.noElement;
      return HomeScreenType.info;
    } catch (e) {
      print(e);
      return HomeScreenType.loading;
    }
  }

  Widget simpleTeleblitz(TeleblitzData eventData, String eventID,
      Stream<String> Function(String, String) function) {
    switch (eventData.teleblitzType) {
      case TeleblitzType.notImplemented:
        return notImplemented();
        break;
      case TeleblitzType.ferien:
        defineInfo(eventData);
        return ferien();
        break;
      case TeleblitzType.keineAktivitaet:
        defineInfo(eventData);
        return keineAktivitat();
        break;
      case TeleblitzType.teleblitz:
        defineInfo(eventData);
        return teleblitz(eventData.name, eventData.groupIDs, eventID, function);
      default:
        return notImplemented();
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
  List<String> mitnehmen;
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
                child: Text("Beginn:", style: MoreaTextStyle.lable)),
            Expanded(
              child: InkWell(
                child: Text(
                  this.antreten,
                  style: MoreaTextStyle.link,
                ),
                onTap: () {
                  urllauncher.openlinkMaps(this.antretenMap);
                },
              ),
            )
          ],
        ),
      );
    } else {
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
                child: Text("Schluss:", style: MoreaTextStyle.lable)),
            Expanded(
                child: InkWell(
              child: Text(
                this.abtreten,
                style: MoreaTextStyle.link,
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
              child: Text("Datum:", style: MoreaTextStyle.lable)),
          Expanded(
              child: Text(
            this.datum,
            style: MoreaTextStyle.normal,
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
                        child: Text("Bemerkung:", style: MoreaTextStyle.lable)),
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
                      style: MoreaTextStyle.normal,
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
                  child: Text("", style: MoreaTextStyle.lable)),
              Expanded(
                  child: Text(
                this.sender,
                style: MoreaTextStyle.normal,
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
                        child: Text("Mitnehmen:", style: MoreaTextStyle.lable)),
                  ],
                ),
              ),
              ListView.builder(
                padding: EdgeInsets.only(left: 15),
                shrinkWrap: true,
                itemCount: this.mitnehmen.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Text(
                    '- ' + this.mitnehmen[index],
                    style: MoreaTextStyle.normal,
                  );
                },
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
                      child: Text("Grund:", style: MoreaTextStyle.lable)),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Text(
                  this.grund,
                  style: MoreaTextStyle.normal,
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
                      child: Text("Grund:", style: MoreaTextStyle.lable)),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Text(
                  "Die Aktivität fällt leider wegen der Schulferien aus.",
                  style: MoreaTextStyle.normal,
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
                      child: Text("Ende Ferien:", style: MoreaTextStyle.lable)),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Html(
                  data: formatedEndeFerien,
                  defaultTextStyle: MoreaTextStyle.normal,
                ))
              ],
            ),
          ],
        ));
  }
}
