import 'package:intl/intl.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/dwi_format.dart';
import 'dart:async';

abstract class BaseAgenda{
  Stream<List<dynamic>> getAgendaOverview(String groupID);
  Future<DocumentSnapshot> getAgendaTitle(String eventID);
  Future<void> deleteAgendaEvent(String groupID, eventID);
  Future<void> deleteAgendaOverviewTitle(String groupID, String eventID);
  Future<void> uploadtoAgenda(Map<String, dynamic> dataold, Map<String, dynamic> data);
  Future<void> updateAgendaTitles(String groupID, Map<String, dynamic> agendaTitle);
  Future<String> createEventID();
  List<String> check4EventgroupIDsChanged(Map<String, dynamic> eventOld, Map<String, dynamic> eventNew);
}
class Agenda extends BaseAgenda{
  CrudMedthods crud0;
  DWIFormat dwiFormat = new DWIFormat();
  Firestore db;
  MoreaFirebase moreaFire;

  Agenda(Firestore firestore){
   this.crud0 = new CrudMedthods(firestore);
   this.db = firestore;
   this.moreaFire = new MoreaFirebase(firestore);
  }

  Stream<List<dynamic>> getAgendaOverview(String groupID)async* {
    Stream<DocumentSnapshot> groupData = crud0.streamDocument(pathGroups, groupID);
    yield* groupData.map((data){
      return List.from(data.data["AgendaTitles"]);
    });  
    
  }
 Future<DocumentSnapshot> getAgendaTitle(String eventID)async{
   return await crud0.getDocument(pathEvents, eventID);
   
  }
  Future<void> deleteAgendaEvent(String groupID, eventID)async{
    this.deleteAgendaOverviewTitle(groupID, eventID);
    return await crud0.deletedocument(pathEvents, eventID);
  }
  Future<void> deleteAgendaOverviewTitle(String groupID, String eventID)async{
    DocumentReference docRef = db.collection(pathGroups).document(groupID);
    List<dynamic> agendaOverview;
     
    try{
          TransactionHandler transactionHandler =  (Transaction tran)async {
          await tran.get(docRef).then((DocumentSnapshot snap)async {
              if (snap.exists) {
                Map<dynamic, dynamic> test = Map<dynamic, dynamic>.from(snap.data);
                  if(test.containsKey("AgendaTitles")){
                    agendaOverview = new List<dynamic>.from(test["AgendaTitles"]);
                    agendaOverview.removeWhere((element) => element[groupMapEventID] == eventID);                      
                    }
                  }
                 await tran.update(docRef, Map<String, dynamic>.from({"AgendaTitles": agendaOverview}));
      
            }).catchError((err)=>{
              print(err)
            });
        };
      return await db.runTransaction(transactionHandler);
      }catch(e){
        print(e);
      }
  }
  Map<String, dynamic> createEventTitle(Map<String, dynamic> event){
    return Map<String, dynamic>.from({
      "Datum" : event["Datum"],
      "eventID": event,
      "Lager" : event["Lager"],
      "Event" : event["Event"],
      "Eventname": event["Eventname"]
    });
  }

  Future<void> uploadtoAgenda(Map<String, dynamic> eventOld, Map<String, dynamic> data) async {
    String eventID = await createEventID();
    data["eventID"] = eventID;
    List<String> groupIDs = data["groupIDs"];
    List<String> deletedGroupIDs = this.check4EventgroupIDsChanged(eventOld, data);

    for(String groupID in deletedGroupIDs){
      this.deleteAgendaOverviewTitle(groupID, eventID);
    }
    for(String groupID in groupIDs){
      this.updateAgendaTitles(groupID, this.createEventTitle(data));
    }    return await crud0.runTransaction(pathEvents, eventID , data);
  }
  Future<String> createEventID()async{
    return await moreaFire.createEventID();
  }
  Future<void> updateAgendaTitles(String groupID, Map<String, dynamic> agendaTitle)async{
    DocumentReference docRef = db.collection(pathGroups).document(groupID);
    List<dynamic> agendaOverview;
   
    DateTime newDate = DateTime.parse(agendaTitle["Datum"]);
    
    try{
          TransactionHandler transactionHandler =  (Transaction tran)async {
          await tran.get(docRef).then((DocumentSnapshot snap)async {
              if (snap.exists) {
                Map<dynamic, dynamic> test = Map<dynamic, dynamic>.from(snap.data);
                  if(test.containsKey("AgendaTitles")){
                    agendaOverview = new List<dynamic>.from(test["AgendaTitles"]);
                    if(agendaOverview.length>=0){
                      bool block = false;
                      for (int i=0; i<agendaOverview.length;i++){
                        DateTime checkdate = DateTime.parse(agendaOverview[i]["Datum"]);
                        if(newDate.difference(checkdate).inDays < 0){
                          agendaOverview.insert(i, agendaTitle);
                          block = true;
                          break;
                      }
                      }
                      if(!block)
                        agendaOverview.add(agendaTitle);
                    }else{
                       agendaOverview[0] = agendaTitle;
                    }
                  }else{
                    agendaOverview[0] = agendaTitle;
                  }
                 await tran.update(docRef, Map<String, dynamic>.from({"AgendaTitles": agendaOverview}));
              }
            }).catchError((err)=>{
              print(err)
            });
        };
      return await db.runTransaction(transactionHandler);
      }catch(e){
        print(e);
      }
  }
  List<String> check4EventgroupIDsChanged(Map<String, dynamic> eventOld, Map<String, dynamic> eventNew){
    List<String> oldGroupIDs = eventOld["groupIDs"];
    List<String> newGroupIDs = eventNew["groupIDs"];
    
    oldGroupIDs.removeWhere((element) => newGroupIDs.contains(element));
    
    return oldGroupIDs;
  }
}