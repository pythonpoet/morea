import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/dwi_format.dart';
import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class BaseAgenda {
  Stream<List<dynamic>> getAgendaOverview(String groupID);

  Future<DocumentSnapshot> getAgendaTitle(String eventID);

  Future<void> deleteAgendaEvent(Map<String, dynamic> event);

  Future<void> deleteAgendaOverviewTitle(String groupID, String eventID);

  Future<void> uploadtoAgenda(
      Map<String, dynamic> dataold, Map<String, dynamic> data);

  Future<void> updateAgendaTitles(
      String groupID, Map<String, dynamic> agendaTitle);

  Future<String> createEventID();

  List<String> check4EventgroupIDsChanged(
      Map<String, dynamic> eventOld, Map<String, dynamic> eventNew);
}

class Agenda extends BaseAgenda {
  CrudMedthods crud0;
  DWIFormat dwiFormat = new DWIFormat();
  Firestore db;
  MoreaFirebase moreaFire;
  List<Map> events = new List();
  StreamController<List<Map>> eventStream = new BehaviorSubject();

  Stream<List<Map<dynamic, dynamic>>> get eventstream => eventStream.stream;

  Agenda(Firestore firestore, MoreaFirebase moreaFire) {
    this.crud0 = new CrudMedthods(firestore);
    this.db = firestore;
    this.moreaFire = moreaFire;
  }

  DateTime getDateTime(Map event) {
    return DateTime.parse(event['DeleteDate']);
  }

  Stream<List<Map<dynamic, dynamic>>> getAgendaOverview(String groupID) async* {
    await for (DocumentSnapshot groupMap
        in crud0.streamDocument(pathGroups, groupID)) {
      if (groupMap.data.containsKey('AgendaTitles')) {
        if (groupMap.data['AgendaTitles'].isNotEmpty) {
          yield List<Map>.from(groupMap.data["AgendaTitles"]);
        } else {
          yield [];
        }
      } else {
        yield [];
      }
    }
  }

  Stream<bool> addToList(String groupID) async* {
    await for (List<Map<dynamic, dynamic>> groupEvents
        in this.getAgendaOverview(groupID)) {
      if (groupEvents != null) if (events.length >= 0)
        for (Map groupEvent in groupEvents) {
          groupEvent['groupID'] = groupID;
          int i = 0;
          events.forEach((event) {
            if (event["eventID"] == groupEvent["eventID"]) i++;
          });
          if (i == 0) events.add(groupEvent);
        }
      else {
        events.addAll(groupEvents);
      }
      /*
      for(Map event in events){
        List someList = new List();
        groupEvents.contains((groupEvent) =>{
          event["eventID"]!=groupEvent["eventID"],
          events.add(groupEvent)
          }
        );
          
      }*/
      events.sort((a, b) => getDateTime(a).compareTo(getDateTime(b)));
      eventStream.add(events);
      yield true;
    }
  }

  void getTotalAgendaOverview(List<String> groupIDs) {
    //eliminates duplicates of groupIDs
    groupIDs.toSet().toList();
    for (String groupID in groupIDs) {
      addToList(groupID).firstWhere((bool test) => test == true);
    }
  }

  Future<DocumentSnapshot> getAgendaTitle(String eventID) async {
    return await crud0.getDocument(pathEvents, eventID);
  }

  Future<void> deleteAgendaEvent(Map<String, dynamic> event) async {
    List<String> groupIDs = new List<String>.from(event["groupIDs"]);
    String eventID = event["eventID"];
    if (groupIDs.isNotEmpty)
      for (String groupID in groupIDs) {
        this.deleteAgendaOverviewTitle(groupID, eventID);
      }

    return await crud0.deletedocument(pathEvents, eventID);
  }

  Future<void> deleteAgendaOverviewTitle(String groupID, String eventID) async {
    DocumentReference docRef = db.collection(pathGroups).document(groupID);
    List<dynamic> agendaOverview;

    try {
      TransactionHandler transactionHandler = (Transaction tran) async {
        await tran.get(docRef).then((DocumentSnapshot snap) async {
          if (snap.exists) {
            Map<dynamic, dynamic> test = Map<dynamic, dynamic>.from(snap.data);
            if (test.containsKey("AgendaTitles")) {
              agendaOverview = new List<dynamic>.from(test["AgendaTitles"]);
              agendaOverview.removeWhere(
                  (element) => element[groupMapEventID] == eventID);
            }
          }
          await tran.update(docRef,
              Map<String, dynamic>.from({"AgendaTitles": agendaOverview}));
        }).catchError((err) => {print(err)});
      };
      return await db.runTransaction(transactionHandler);
    } catch (e) {
      print('Error in deleteAgendaOverview');
      print(e);
    }
  }

  Map<String, dynamic> createEventTitle(Map<String, dynamic> event) {
    return Map<String, dynamic>.from({
      "Datum": event["Datum"],
      "eventID": event["eventID"],
      "Lager": event["Lager"],
      "Event": event["Event"],
      "Eventname": event["Eventname"],
      "DeleteDate": event["DeleteDate"]
    });
  }

  Future<void> uploadtoAgenda(
      Map<String, dynamic> eventOld, Map<String, dynamic> data) async {
    String eventID;
    if (!eventOld.containsKey("eventID"))
      eventID = await createEventID();
    else {
      eventID = eventOld["eventID"];
      for (String groupID in eventOld['groupIDs']) {
        await this.deleteAgendaOverviewTitle(groupID, eventID);
      }
    }

    print(eventID);

    data["eventID"] = eventID;

    List<String> groupIDs = data["groupIDs"];

    for (String groupID in groupIDs) {
      this.updateAgendaTitles(groupID, this.createEventTitle(data));
    }
    return await crud0.runTransaction(pathEvents, eventID, data);
  }

  Future<String> createEventID() async {
    return await moreaFire.createEventID();
  }

  Future<void> updateAgendaTitles(
      String groupID, Map<String, dynamic> agendaTitle) async {
    DocumentReference docRef = db.collection(pathGroups).document(groupID);
    List<dynamic> agendaOverview = new List();

    //DateTime newDate = DateTime.parse(agendaTitle["Datum"]);

    try {
      TransactionHandler transactionHandler = (Transaction tran) async {
        await tran.get(docRef).then((DocumentSnapshot snap) async {
          if (snap.exists) {
            Map<dynamic, dynamic> test = Map<dynamic, dynamic>.from(snap.data);
            if (test.containsKey("AgendaTitles")) {
              agendaOverview = new List<dynamic>.from(test["AgendaTitles"]);
              if (agendaOverview.length >= 1) {
                agendaOverview.add(agendaTitle);
                agendaOverview
                    .sort((a, b) => getDateTime(a).compareTo(getDateTime(b)));
              } else {
                agendaOverview.add(agendaTitle);
              }
            } else {
              agendaOverview.add(agendaTitle);
            }
            await tran.update(docRef,
                Map<String, dynamic>.from({"AgendaTitles": agendaOverview}));
          }
        }).catchError((err) => {print(err)});
      };
      return await db.runTransaction(transactionHandler);
    } catch (e) {
      print('Error in updateAgendaTitles');
      print(e);
    }
  }

  List<String> check4EventgroupIDsChanged(
      Map<String, dynamic> eventOld, Map<String, dynamic> eventNew) {
    List<String> oldGroupIDs = new List<String>();
    List<String> newGroupIDs = new List<String>();
    if (eventOld.containsKey("groupIDs"))
      oldGroupIDs.addAll(List<String>.from(eventOld['groupIDs']));
    if (eventNew.containsKey('groupIDs'))
      newGroupIDs.addAll(List<String>.from(eventNew['groupIDs']));
    if (oldGroupIDs.length > 0)
      oldGroupIDs.removeWhere((element) => newGroupIDs.contains(element));

    return oldGroupIDs;
  }
}
