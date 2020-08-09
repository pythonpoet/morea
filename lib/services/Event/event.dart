
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


abstract class BaseEvent{
  Stream<Map<String, dynamic>> streamEventMap(Stream<String> eventID);
  Stream<Event> readEventMap(Stream<Map<String,dynamic>> sEvent);
  Future<String> createEvent(Event event);
  Future<void> editEvent(Event event);
  Future<void> joinEvent(String eventID, String value);
  
  
}

class Event extends BaseEvent{
  Participates participates;
  CrudMedthods crud0;
  Stream<String> eventID;
  
  Event({this.eventID,  @required this.crud0}){
    participates = new Participates(crud0: this.crud0, eventID: this.eventID);
  }

  Stream<Map<String, dynamic>> streamEventMap(Stream<String> sEventID)async*{
    await for(String eventID in sEventID){
      await for(DocumentSnapshot dSEvent in crud0.streamDocument(pathEvents, eventID)){
        yield dSEvent.data;
      }
  }

  Stream<Event> readEventMap(Stream<Map<String,dynamic>> sEvent)async{
    await for (Map<String,dynamic> event in sEvent){
      
    }
  }


  //TODO do!
}