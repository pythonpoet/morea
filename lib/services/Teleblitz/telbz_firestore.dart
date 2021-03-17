import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async' show Stream;
import 'package:async/async.dart' show StreamGroup;

/*
Author David Wild aka. Rumpelstilzli,
Date 10.01.2020

This class contains all teleblitz function

If an instance of this class is initialized, getMapHomeFeed and getMapofEvents are
beeing initialized as well.
*/
abstract class BaseTeleblitzFirestore {
  Stream<Map<String, List<String>>> get getMapHomeFeed;

  //Returns a stream with a Map that contains the groupID as key and the "homeFeed" of the groupMap as value
  Stream<Map<String, Map<String, Map<String, dynamic>>>> get getMapofEvents;

  /*Returns a stream with a Map that contains the groupID as key and a further Map as value. 
  The Map contains the eventID as key and the teleblitz (event content) as value.*/

  Stream<String> anmeldeStatus(String eventID, userID);

  Future<bool> eventIDExists(String eventID);

  //Returns true if a given eventID exists in the FirebaseFirestore

  Future<void> uploadTelbzAkt(String groupID, Map<String, dynamic> data);

  /*Uploads the eventID to a specified group. The eventID is stored as a Map. 
  Key is homeFeed while the eventID is stored as a array as value*/
  Future<void> uploadTelbz(String eventID, Map<String, dynamic> data);
//Stores the teleblitz (event content) with the given eventID
}

class TeleblizFirestore implements BaseTeleblitzFirestore {
  CrudMedthods crud0;
  Map<String, dynamic> _teleblitze = new Map<String, dynamic>();
  Map<String, List<String>> mapHomeFeed = new Map<String, List<String>>();

  Map<String, Map<String, Map<String, dynamic>>> mapOfGroupEvent =
      new Map<String, Map<String, Map<String, dynamic>>>();
  StreamController<Map<String, List<String>>> _mapHomeFeedController =
      new BehaviorSubject();
  StreamController<Map<String, Map<String, Map<String, dynamic>>>>
      _mapofEventsController = new BehaviorSubject();

  Stream<Map<String, List<String>>> get getMapHomeFeed =>
      _mapHomeFeedController.stream;

  Stream<Map<String, Map<String, Map<String, dynamic>>>> get getMapofEvents =>
      _mapofEventsController.stream;

  TeleblizFirestore(FirebaseFirestore firestore, List<String> groupIDs) {
    crud0 = CrudMedthods(firestore);
    _mapHomeFeedController.addStream(this.streamMapHomeFeed(groupIDs));
    this.streamMapofGroupEvents(groupIDs);
  }

  Stream<Map<String, List<String>>> streamHomeFeed(String groupID) async* {
    Stream<DocumentSnapshot> sDhomeFeed =
        crud0.streamDocument(pathGroups, groupID);
    await for (List<String> homeFeed
        in sDhomeFeed.map((DocumentSnapshot dsHomeFeed) {
      return new List<String>.from(dsHomeFeed.data()[groupMapHomeFeed] ?? []);
    })) {
      mapHomeFeed[groupID] = homeFeed;
      yield mapHomeFeed;
    }
  }

  Stream<Map<String, List<String>>> streamMapHomeFeed(
      List<String> groupIDs) async* {
    yield* StreamGroup.merge(groupIDs.map((groupID) {
      return streamHomeFeed(groupID);
    }));
  }

  Stream<Map<String, dynamic>> steramTelebliz(eventID) async* {
    yield* crud0.streamDocument(pathEvents, eventID).map((dsEvent) {
      return dsEvent.data();
    });
  }

  Stream<Map<String, Map<String, dynamic>>> steamMapofEventshelper(
      String eventID, Map<String, Map<String, dynamic>> mapOfEvents) async* {
    await for (Map<String, dynamic> event in this.steramTelebliz(eventID)) {
      mapOfEvents[eventID] = event;
      yield mapOfEvents;
    }
  }

  Stream<Map<String, Map<String, dynamic>>> steamMapofEvents(
      List<String> eventIDs) {
    Map<String, Map<String, dynamic>> mapOfEvents = new Map();
    List<Stream<Map<String, Map<String, dynamic>>>> listStream = [];
    for (String eventID in eventIDs) {
      listStream.add(steamMapofEventshelper(eventID, mapOfEvents));
    }
    return StreamGroup.merge(listStream);
  }

  Stream<Map<String, Map<String, Map<String, dynamic>>>>
      streamMapofGroupEventsHelper(
          MapEntry<String, List<String>> homeFeed) async* {
    await for (Map<String, Map<String, dynamic>> mapofEvents
        in steamMapofEvents(homeFeed.value)) {
      mapOfGroupEvent[homeFeed.key] = mapofEvents;
      yield mapOfGroupEvent;
    }
  }

  void helper(Map<String, List<String>> listHomeFeed) async {
    List<Stream<Map<String, Map<String, Map<String, dynamic>>>>> list = [];
    for (MapEntry<String, List<String>> homeFeed in listHomeFeed.entries) {
      list.add(streamMapofGroupEventsHelper(homeFeed).asBroadcastStream());
    }
    helpertow(StreamGroup.merge(list).asBroadcastStream());
  }

  void helpertow(
      Stream<Map<String, Map<String, Map<String, dynamic>>>> stream) async {
    await for (Map<String, Map<String, Map<String, dynamic>>> event in stream) {
      _mapofEventsController.add(event);
    }
  }

  void streamMapofGroupEvents(groupIDs) async {
    await for (dynamic listHomeFeed in getMapHomeFeed) {
      helper(listHomeFeed);
    }
  }

  Future<Map> getTelbz(String eventID) async {
    if (this._teleblitze.isNotEmpty) if (this._teleblitze.containsKey(
        eventID)) if (DateTime(this._teleblitze[eventID]["Timestamp"])
            .difference(DateTime.now())
            .inMinutes <
        5) return this._teleblitze[eventID];

    return await refeshTelbz(eventID);
  }

  Future<Map> refeshTelbz(String eventID) async {
    try {
      Map<String, dynamic> tlbz = Map<String, dynamic>.from(
          (await crud0.getDocument(pathGroups, eventID)).data());
      tlbz["Timestamp"] = DateTime.now();
      this._teleblitze[eventID] = tlbz;
      return tlbz;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<String> anmeldeStatus(String userID, eventID) async* {
    Stream<DocumentSnapshot> sdSAnmeldung = crud0.streamDocument(
        pathEvents + "/" + eventID + "/" + "Anmeldungen", userID);
    await for (DocumentSnapshot dSAnmeldung in sdSAnmeldung) {
      if (!dSAnmeldung.exists)
        yield "un-initialized";
      else
        yield dSAnmeldung.data()["AnmeldeStatus"];
    }
  }

  Future<bool> eventIDExists(eventID) async {
    DocumentSnapshot doc = await crud0.getDocument(pathEvents, eventID);
    return doc.exists;
  }

  Future<void> uploadTelbzAkt(String groupID, Map<String, dynamic> data) async {
    return await crud0.runTransaction(pathGroups, groupID, data);
  }

  Future<void> uploadTelbz(String eventID, Map<String, dynamic> data) async {
    data['Timestamp'] = DateTime.now().toString();
    data['TeleblitzType'] = "Teleblitz";
    return await crud0.runTransaction(pathEvents, eventID, data);
  }
}
