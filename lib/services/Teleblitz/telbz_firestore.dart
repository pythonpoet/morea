import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async' show Stream;
import 'package:async/async.dart' show StreamGroup;

abstract class BaseTeleblitzFirestore {
  Stream<Map<String, List<String>>> get getMapHomeFeed;
  Stream<Map<String, Map<String, Map<String,dynamic>>>> get getMapofEvents;

  Future<String> getTelbzAkt(String groupnr);
  Future<Map> getTelbz(String eventID);
  Stream<List<String>> streamHomeFeed(String groupID);
  Stream<Map<String,dynamic>> steramTelebliz(eventID);

  Stream<Map<String, List<String>>> streamMapHomeFeed(List<String> groupIDs);
  Stream<Map<String, Map<String, Map<String,dynamic>>>>streamMapofGroupEvents(groupIDs);
  Stream<Map<String, Map<String,dynamic>>> steamMapofEvents(List<String> eventIDs);
  Future<bool> eventIDExists(String eventID);

  Future<void> uploadTelbzAkt(String groupnr, Map<String, dynamic> data);
  Future<void> uploadTelbz(String eventID, Map<String, dynamic> data);
}

class TeleblizFirestore implements BaseTeleblitzFirestore {
  CrudMedthods crud0;
  Map<String, dynamic> _teleblitze = new Map<String,dynamic>();
  Map<String,List<String>> mapHomeFeed = new Map<String,List<String>>();
  Map<String,Map<String, Map<String, dynamic>>> mapOfGroupEvent = new Map<String,Map<String, Map<String, dynamic>>>();
  StreamController<Map<String, List<String>>> _mapHomeFeedController = new BehaviorSubject();
  StreamController<Map<String, Map<String, Map<String,dynamic>>>> _mapofEventsController = new BehaviorSubject();
  
  Stream<Map<String, List<String>>> get getMapHomeFeed => _mapHomeFeedController.stream;
  Stream<Map<String, Map<String, Map<String,dynamic>>>> get getMapofEvents => _mapofEventsController.stream;

  TeleblizFirestore(Firestore firestore, List<String> groupIDs) {
    crud0 = CrudMedthods(firestore);
    _mapHomeFeedController.addStream(this.streamMapHomeFeed(groupIDs));
    _mapofEventsController.addStream(this.streamMapofGroupEvents(groupIDs));
  }


  Stream<List<String>> streamHomeFeed(String groupID)async*{
    Stream<DocumentSnapshot> sDhomeFeed = crud0.streamDocument(pathGroups, groupID); 
    yield* sDhomeFeed.map((DocumentSnapshot dsHomeFeed){
       return new List<String>.from(dsHomeFeed.data[groupMapHomeFeed]?? new List());
    }); 
  }
  Stream<Map<String,List<String>>> somestream(String groupID)async*{
    await for(List<String>homeFeed in this.streamHomeFeed(groupID)){
        mapHomeFeed[groupID]=homeFeed;
        yield mapHomeFeed;
      }
  }
  Stream<Map<String, List<String>>> streamMapHomeFeed(List<String> groupIDs)async*{
    List<Stream<Map<String, List<String>>>> streamList = new List();
    for(String groupID in groupIDs){   
      streamList.add(somestream(groupID));
    }
    yield* StreamGroup.merge(streamList).map((convert){
      print(convert);
      return convert;
    });
  }
  Stream<Map<String,dynamic>> steramTelebliz(eventID)async*{
    yield* crud0.streamDocument(pathEvents, eventID).map((dsEvent){
      return dsEvent.data;
    });
  }
  Stream<Map<String, Map<String,dynamic>>>steamMapofEventshelper(String eventID,Map<String, Map<String,dynamic>> mapOfEvents)async*{
    await for(Map<String, dynamic>event in this.steramTelebliz(eventID)){
       mapOfEvents[eventID] = event;
       yield mapOfEvents;
     }
  }
  Stream<Map<String, Map<String,dynamic>>> steamMapofEvents(List<String> eventIDs){
    Map<String, Map<String,dynamic>> mapOfEvents = new Map();
    List<Stream<Map<String, Map<String,dynamic>>>> listStream = new List();
    for (String eventID in eventIDs){
      listStream.add(steamMapofEventshelper(eventID, mapOfEvents));
    }
    print(listStream);
    return listStream[0];
  }
   Stream<Map<String, Map<String, Map<String,dynamic>>>>streamMapofGroupEventsHelper(MapEntry<String, List<String>> homeFeed)async*{

    await for(Map<String, Map<String, dynamic>>mapofEvents in steamMapofEvents(homeFeed.value)){
          print(mapofEvents);
          mapOfGroupEvent[homeFeed.key] = mapofEvents;
          yield mapOfGroupEvent;
        }
  }
  Stream<Map<String, Map<String, Map<String,dynamic>>>>streamMapofGroupEvents(groupIDs)async*{
    List<Stream<Map<String, Map<String, Map<String,dynamic>>>>> listStream = new List();
    Stream<Map<String, List<String>>> someStream = this.streamMapHomeFeed(groupIDs);
    await for(Map<String, List<String>>listHomeFeed in someStream){
      for(MapEntry<String, List<String>> homeFeed in listHomeFeed.entries){
        if(homeFeed.value.isNotEmpty)
        listStream.add(streamMapofGroupEventsHelper(homeFeed));
      }
      yield* StreamGroup.merge(listStream);
    }    
  }
 
  
  
  Future<String> getTelbzAkt(String groupID) async {
    try {
      DocumentSnapshot akteleblitz = await crud0.getDocument(pathGroups, groupID);
      _teleblitze[groupID] = Map<String,dynamic>.from(akteleblitz.data);
      return akteleblitz.data[groupMapAktuellerTeleblitz];
    } catch (e) {
      print(e.toString());
      return DateTime.parse('2019-03-07T13:30:16.388642').toString();
    }
  }
  

  Future<Map> getTelbz(String eventID) async {
    if(this._teleblitze.isNotEmpty)
      if(this._teleblitze.containsKey(eventID))
        if(DateTime(this._teleblitze[eventID]["Timestamp"]).difference(DateTime.now()).inMinutes < 5)
          return this._teleblitze[eventID];
      
    return await refeshTelbz(eventID);
  }
  Future<Map> refeshTelbz(String eventID) async{
    try {
      Map<String, dynamic> tlbz = Map<String, dynamic>.from((await crud0.getDocument(pathGroups, eventID)).data);
      tlbz["Timestamp"] = DateTime.now();
      this._teleblitze[eventID]= tlbz;
      return  tlbz;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> eventIDExists(eventID) async {
    DocumentSnapshot doc = await crud0.getDocument(pathEvents, eventID);
    return doc.exists;
  }
  //TODO Auf Teleblitz Home ändern
  Future<void> uploadTelbzAkt(String groupnr, Map<String, dynamic> data) async {
    return await crud0.runTransaction(pathGroups, groupnr, data);
  }

  Future<void> uploadTelbz(String eventID, Map<String, dynamic> data) async {
    data['Timestamp'] = DateTime.now().toString();
    data['TeleblitzType']= "Teleblitz";
    return await crud0.runTransaction(pathEvents, eventID, data);
  }
}
