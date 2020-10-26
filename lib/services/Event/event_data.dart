import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/Event/data_types/Teleblitz_data.dart';
import 'package:morea/services/crud.dart';

Stream<Map<String, dynamic>> getEventStreamMap(
    CrudMedthods crudMedthods, String eventID) async* {
  await for (DocumentSnapshot dsEventData
      in crudMedthods.streamDocument(pathEvents, eventID)) {
    yield dsEventData.data();
  }
}

enum EventType { teleblitz, notImplemented }

class EventData {
  String eventID, timestamp;
  List<String> groupIDs, changelog;
  Map<String, dynamic> eventData;
  EventType eventType;

  EventData.init(this.eventData) {
    validate(this.eventData);
  }
  factory EventData(Map<String, dynamic> eventData) {
    if (!eventData.containsKey(eventMapType))
      throw "$eventMapType has to be non-null";
    else
      switch (eventData[eventMapType]) {
        case "Teleblitz":
          return TeleblitzData(eventData);
          break;
        default:
          throw "${eventData[eventMapType]} is not implemented";
      }
  }

  void setEventID(String setEventID) => this.eventID = setEventID;

  void getEventType(String eventType) {
    switch (eventType) {
      case "Teleblitz":
        this.eventType = EventType.teleblitz;

        break;
      default:
        this.eventType = EventType.notImplemented;
    }
  }

  void validate(Map<String, dynamic> eventData) {
    this.eventData = eventData;

    if (eventData.containsKey('groupIDs'))
      this.groupIDs = new List.from(eventData['groupIDs']);
    else
      throw 'groupIDs has to be non-null';

    if (eventData.containsKey(mapTimestamp))
      this.timestamp = eventData[mapTimestamp];
    else
      throw "$mapTimestamp has to be non-null";

    if (!eventData.containsKey(eventMapType))
      throw "$eventMapType has to be non-null";
    else
      getEventType(eventData[eventMapType]);
  }

  Map<String, dynamic> pack() {
    return eventData;
  }

  Future<void> deleteEvent(CrudMedthods crudMedthods) {
    return crudMedthods.deletedocument(pathEvents, eventID);
  }

  Future<void> createEvent(CrudMedthods crudMedthods) {
    return crudMedthods.setData(pathEvents, this.eventID, this.pack());
  }

  Future<void> updateEvent(CrudMedthods crudMedthods) {
    return crudMedthods.runTransaction(pathEvents, this.eventID, this.pack());
  }
}
