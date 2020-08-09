import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
/*
Use-Case:
  This Class is the backend to all group related actions.
  
Developed:
  David Wild - 2.08.20

Description:
  initialisation:
    stream groupID
    crud0
  
  Functions:
    streamGroupMap
     - readGroupMap
    createGroup
    joinGroup
    adminGroup 
*/
abstract class BaseMoreGroup{
  void streamGroupMap(Stream<String> groupID);
  void readGroupMap(Map<String, dynamic> groupMap);
  Future<void>createGroup(Map<String, dynamic> group);
  Future<void>joinGroup(String groupID);
  Future<void>inviteUsers(List<String> luserIDs);
  //TODO functions
  //TODO fix groupMap doc structure
}

class MoreaGroup extends BaseMoreGroup{

  //Objects
  CrudMedthods crud0;
  //Attributes
  Stream<String> smGroupID;
  Stream<DocumentSnapshot> _sDSGroupMap;
  List<String> homeFeed;
  Map<String, Map<String, dynamic>> priviledge;

  MoreaGroup({this.smGroupID, @required this.crud0}){
    streamGroupMap(smGroupID);
  }
  void streamGroupMap(Stream<String> smGroupID)async{
    await for(String groupID in smGroupID){
      _sDSGroupMap = crud0.streamDocument(pathGroups, groupID);

      await for(DocumentSnapshot dSGroupMap in _sDSGroupMap)
        readGroupMap(dSGroupMap.data);
    }
  }

  void readGroupMap(Map<String, dynamic> groupMap){
    //turnOn/OFF groupMapTest
    if(true){
      if(groupMap.containsKey(groupMapHomeFeed))
        this.homeFeed = groupMap[groupMapHomeFeed];
      else
         throw "$groupMapHomeFeed has to be non-null";

      if(groupMap.containsKey(groupMapPriviledge))
        this.priviledge = groupMap[groupMapPriviledge];
        
    }
  }
  Future<void> createGroup(Map<String, dynamic> groupMap){

  }
  Future<void> inviteUsers(List<String> luserIDs){

  }
  Future<void> joinGroup(String groupID){

  }

}