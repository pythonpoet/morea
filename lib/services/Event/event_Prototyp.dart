
/*
Use-Case:
  This Class is the backend to all event related actions.
  
Developed:
  David Wild - 9.08.20

Description:
  initialisation:
    stream eventID
    crud0
  
  Functions:
    streamEventMap
     - readEventMap
    createEvent
    editEvent
    joinEvent
    getParticipates
     
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/Event/participates.dart';
import 'package:morea/services/crud.dart';

enum EventType {teleblitz}

abstract class BaseEvent{
  Stream<Map<String, dynamic>> streamEventMap(Stream<String> eventID);
  void readEventMap(Stream<Map<String,dynamic>> sEvent);
  Future<void> createEvent({ @required EventType type, @required String userID, @required data});
  Future<void> editEvent(Event event);
  Future<void> joinEvent(String userUID, String eventID, String value);
  
  
}

class Event extends BaseEvent{
  Participates participates;
  CrudMedthods crud0;
  Stream<String> eventID;
  dynamic event;
  List<String> groupIDs;
  
  Event({this.eventID,  @required this.crud0}){
    participates = new Participates(crud0: this.crud0, eventID: this.eventID);
  }

  Stream<Map<String, dynamic>> streamEventMap(Stream<String> sEventID)async*{
    await for(String eventID in sEventID){
      await for(DocumentSnapshot dSEvent in crud0.streamDocument(pathEvents, eventID)){
        yield dSEvent.data;
      }
    }
  }

  void readEventMap(Stream<Map<String,dynamic>> sEventData)async{
    await for (Map<String,dynamic> eventData in sEventData){
      switch (eventData[eventMapType]) {
        case "Teleblitz":
          this.event = new Teleblitz(eventData);
          break;
        default:
      }  
    }
  }
  Future<void> createEvent({ @required EventType type, @required String userID, @required Event data}) async {
    
    groupIDs = data['groupIDs'];
    String eventID =
        groupID + data['datum'].toString().replaceAll('Samstag, ', '');
    Map<String, List> akteleblitz = {
      groupMapHomeFeed: [eventID]
    };
    await tbz.uploadTelbzAkt(groupID, akteleblitz);
    data['groupIDs'] = groupIDs;
    return await tbz.uploadTelbz(eventID, data);
  }


  //TODO do!
}