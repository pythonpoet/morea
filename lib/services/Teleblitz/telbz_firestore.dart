import 'dart:async';
import 'package:async/async.dart' show StreamGroup;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseTeleblitzFirestore {
  Stream<Map<String, List<String>>> get getMapHomeFeed;
  Stream<Map<String, Map<String, Map<String,dynamic>>>> get getMapofEvents;

  Future<String> getTelbzAkt(String groupnr);
  Future<Map> getTelbz(String eventID);
  Stream<List<String>> streamHomeFeed(String groupID);
  Stream<Map<String,dynamic>> steramTelebliz(eventID);

  Stream<Map<String, List<String>>> streamMapHomeFeed(List<String> groupIDs);
  Stream<Map<String, Map<String, Map<String,dynamic>>>>streamMapofGroupEvents();
  Stream<Map<String, Map<String,dynamic>>> steamMapofEvents(List<String> eventIDs);
  Future<bool> eventIDExists(String eventID);

  Future<void> uploadTelbzAkt(String groupnr, Map<String, dynamic> data);
  Future<void> uploadTelbz(String eventID, Map<String, dynamic> data);
}

class TeleblizFirestore implements BaseTeleblitzFirestore {
  CrudMedthods crud0;
  Map<String, String> _aktTeleblitze = new Map<String,String>();
  Map<String, dynamic> _teleblitze = new Map<String,dynamic>();
  StreamController<Map<String, List<String>>> _mapHomeFeedController = new BehaviorSubject();
  StreamController<Map<String, Map<String, Map<String,dynamic>>>> _mapofEventsController = new BehaviorSubject();
  
  Stream<Map<String, List<String>>> get getMapHomeFeed => _mapHomeFeedController.stream;
  Stream<Map<String, Map<String, Map<String,dynamic>>>> get getMapofEvents => _mapofEventsController.stream;

  TeleblizFirestore(Firestore firestore, List<String> groupIDs) {
    crud0 = CrudMedthods(firestore);
    _mapHomeFeedController.addStream(this.streamMapHomeFeed(groupIDs));
    _mapofEventsController.addStream(this.streamMapofGroupEvents());
  }


  Stream<List<String>> streamHomeFeed(String groupID)async*{
    Stream<DocumentSnapshot> sDhomeFeed = crud0.streamDocument(pathGroups, groupID); 
    yield* sDhomeFeed.map((DocumentSnapshot dsHomeFeed){
       return new List<String>.from(dsHomeFeed.data[groupMapHomeFeed]);
    }); 
  }
  Stream<Map<String, List<String>>> streamMapHomeFeed(List<String> groupIDs)async*{
    Stream<Map<String, List<String>>> listHomeFeed;
    for(String groupID in groupIDs){
        Stream<List<String>>somestream = streamHomeFeed(groupID);
        listHomeFeed = somestream.map((List<String> homeFeed){
          return Map<String,List<String>>.from({groupID:homeFeed});
         });
    }
    yield* listHomeFeed;
  }
  Stream<Map<String,dynamic>> steramTelebliz(eventID)async*{
    yield* crud0.streamDocument(pathEvents, eventID).map((dsEvent){
      return dsEvent.data;
    });
  }
  Stream<Map<String, Map<String,dynamic>>> steamMapofEvents(List<String> eventIDs)async*{  
    for (String eventID in eventIDs){
     await for(Map<String, dynamic>event in this.steramTelebliz(eventID)){
        yield Map<String, Map<String,dynamic>>.from({eventID:event});
     }
    }
    
  }
  Stream<Map<String, Map<String, Map<String,dynamic>>>>streamMapofGroupEvents()async*{
    Stream<Map<String, List<String>>> streamListHomeFeed = this.getMapHomeFeed;

    await for(Map<String, List<String>>listHomeFeed in streamListHomeFeed){
      for(var homeFeed in listHomeFeed.entries){
        await for(Map<String, Map<String, dynamic>>mapofEvents in steamMapofEvents(homeFeed.value)){
          yield Map<String,Map<String, Map<String, dynamic>>>.from({homeFeed.key:mapofEvents});
        }
      }
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
    return await crud0.runTransaction(pathEvents, eventID, data);
  }
}
