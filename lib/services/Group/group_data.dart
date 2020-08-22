// TODO: 1) Priviledge System 2) Where to Sorte Default Priviledges and GroupOptions aswell as premium location


import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/user.dart';
import 'package:morea/services/utilities/blockedUserChecker.dart';

 Stream<Map<String, dynamic>> getGroupData(CrudMedthods crudMedthods, String groupID)async*{
  await for(DocumentSnapshot dsEventData in crudMedthods.streamDocument(pathGroups, groupID)){
    yield dsEventData.data;
  }
}
List<String> sortHomeFeedByStartDate(Map<String, GroupData> mapGroupData){

  //TODO add Timestamp in Firebase
  List<String> sort = new List<String>();
  Map<String,String> unsorted;
  mapGroupData.forEach((String groupID, GroupData groupData) {

    groupData.homeFeed.forEach((eventID, homeFeedEntry) {
      unsorted[eventID] = homeFeedEntry.eventStartTimeStamp;
     });

   });
  
  unsorted.forEach((String eventID, strTimestamp) {
    if(sort.length == 0)
      sort.add(eventID);
    else if(sort.length == 1)
      if(DateTime.parse(unsorted[sort[0]]).difference(DateTime.parse(strTimestamp)).inMinutes >= 0 )
        sort.add(eventID);
      else 
        sort.insert(0, eventID);
    else{
      for(int i=0; i<sort.length-1; i++)
        if(DateTime.parse(unsorted[[i]]).difference(DateTime.parse(strTimestamp)).inMinutes >= 0 )
          if(DateTime.parse(strTimestamp).difference(DateTime.parse(unsorted[sort[i+1]])).inMinutes >= 0 ){
            sort.insert(i + 1, eventID);
            break;
          }
      sort.add(eventID);

    }
   });
   return sort;
}


enum GroupLicenceType{premium, standart, anarchy}

class GroupData {

    //Objects
  CrudMedthods crud0;
  //Attributes
  GroupLicence groupLicence;
  HomeFeed homeFeed;
  Priviledge priviledge;
  Map<String, dynamic> groupData;
  Map<String, PriviledgeEntry> roles;
  GroupData({this.groupData}){
    if(this.groupData != null)
      readGroup(this.groupData);
  }
    
  void readGroup(Map<String, dynamic> groupMap){
    //turnOn/OFF groupMapTest
    if(true){
      if(groupMap.containsKey(groupMapHomeFeed))
        this.homeFeed.readMap(groupMap[groupMapHomeFeed]);
      else
         throw "$groupMapHomeFeed has to be non-null";
      if(groupMap.containsKey(groupMapRoles))
        this.roles = (groupMap[groupMapRoles] as Map<String,dynamic>).map(
          (key, value) => MapEntry(key, PriviledgeEntry().read(value)));

      if(groupMap.containsKey(groupMapPriviledge))
        this.priviledge.readMap(groupMap[groupMapPriviledge], this.roles);
      else
        throw "$groupMapPriviledge has to be non-null";
        
    }
  }
 
}
class HomeFeed{
  Map<String, HomeFeedEntry> homeFeed;

  Iterable<HomeFeedEntry> get values => homeFeed.values;

  void forEach(void f(String eventID, HomeFeedEntry homeFeedEntry)){

  }
  
  String getEventStartDate(String eventID){
    return homeFeed[eventID].eventStartTimeStamp;
  }
  void readMap(Map<String, dynamic> homeFeed){
    for(String eventID in homeFeed.keys){
      if(homeFeed[eventID].containsKey(groupMapUploadeByUserID))
        this.homeFeed[eventID].uploadedByUserID = homeFeed[eventID][groupMapUploadeByUserID];
      else
         throw "$groupMapUploadeByUserID of event: $eventID has to be non-null";
      
      if(homeFeed[eventID].containsKey(groupMapUploadedTimeStamp))
        this.homeFeed[eventID].uploadedTimeStamp = homeFeed[eventID][groupMapUploadedTimeStamp];
      else
         throw "$groupMapUploadedTimeStamp of event: $eventID has to be non-null";
      
      if(homeFeed[eventID].containsKey(groupMapParticipatingGroups))
        this.homeFeed[eventID].participatingGroups = homeFeed[eventID][groupMapParticipatingGroups];
      else
         throw "$groupMapParticipatingGroups of event: $eventID has to be non-null";
      
      if(homeFeed[eventID].containsKey(groupMapEventStartTimeStamp))
        this.homeFeed[eventID].eventStartTimeStamp = homeFeed[eventID][groupMapEventStartTimeStamp];
      else
         throw "$groupMapEventStartTimeStamp of event: $eventID has to be non-null";

      if(homeFeed[eventID].containsKey(groupMapEventEndTimeStamp))
        this.homeFeed[eventID].eventEndTimeStamp = homeFeed[eventID][groupMapEventEndTimeStamp];
      else
         throw "$groupMapEventEndTimeStamp of event: $eventID has to be non-null";
    }
  }
}
class HomeFeedEntry {
 String uploadedByUserID;
  String uploadedTimeStamp;
  List<String> participatingGroups;
  String eventStartTimeStamp;
  String eventEndTimeStamp;
}
class Priviledge {
  Map<String, PriviledgeEntry> priviledge;
  void readMap(Map<String,dynamic> data, Map<String, PriviledgeEntry> map){
    for(String userID in data.keys){
      if(data[userID].containsKey(groupMapPriviledge))
        this.priviledge[userID] = PriviledgeEntry(data:data[userID][groupMapPriviledge],map: map);
      else
         throw "$groupMapPriviledge of user: $userID has to be non-null";
      if(data[userID].containsKey(groupMapDisplayName))
        this.priviledge[userID].displayName = data[userID][groupMapDisplayName];
      else
         throw "$groupMapDisplayName of user: $userID has to be non-null";
  
      if(data[userID].containsKey(groupMapGroupJoinDate))
        this.priviledge[userID].groupJoinDate = data[userID][groupMapGroupJoinDate];
      else
         throw "$groupMapGroupJoinDate of user: $userID has to be non-null";
    }
    if(!data.containsKey(sessionUserID)){
      if(map.containsKey("guest")){
        this.priviledge[sessionUserID] = map["guest"];
        this.priviledge[sessionUserID].displayName = sessionUserName;
        this.priviledge[sessionUserID].groupJoinDate = Timestamp.now().toString();
      }else
        throw "user: $sessionUserID is not allowd to interact with group";
      
    }
  }
}
class PriviledgeEntry{
  // PriviledgeEntry
  String priviledgeEntryType;
  String priviledgeEntryName;
  String priviledgeEntryLocation;

  //User
  String displayName;
  String groupJoinDate;
  
  // Group
  bool groupSeeMembers;
  bool groupSeeMembersDetails;

  // Events
  bool eventTeleblitzRead;
  bool eventTeleblitzEdit;
  bool eventTeleblitzAnmelden;
  bool evnetTeleblitzSeeParticipants;
  bool eventTeleblitzShare;

  PriviledgeEntry({Map<String,dynamic> data, Map<String,PriviledgeEntry> map}){
    if(data.containsKey(groupMapPriviledgeEntryLocation)){
      if(data[groupMapPriviledgeEntryLocation] == "local"){
        if(map.containsKey(data[groupMapPriviledgeEntryType]))
          this.read(map[groupMapPriviledgeEntryType]);
        else 
          throw "Role ${data[groupMapPriviledgeEntryType]} does not exists localy";
      }else if(data[groupMapPriviledgeEntryLocation] == "global"){
        if(globalConfigRoles.containsKey(data[groupMapPriviledgeEntryType]))
          this.read(globalConfigRoles[groupMapPriviledgeEntryType]);
        else 
          throw "Role ${data[groupMapPriviledgeEntryType]} does not exists globaly";
      }
    
    }else
      throw "\"groupMapPriviledgeEntryLocation\" cant be empty";
            

  }

  PriviledgeEntry read(PriviledgeEntry priviledgeEntry){
    this.priviledgeEntryName = priviledgeEntry.priviledgeEntryName;

    this.groupSeeMembers = priviledgeEntry.groupSeeMembers;
    this.groupSeeMembersDetails = priviledgeEntry.groupSeeMembersDetails;
    this.groupJoinDate = priviledgeEntry.groupJoinDate;

    this.eventTeleblitzRead = priviledgeEntry.eventTeleblitzRead;
    this.eventTeleblitzEdit = priviledgeEntry.eventTeleblitzEdit;
    this.eventTeleblitzAnmelden = priviledgeEntry.eventTeleblitzAnmelden;
    this.evnetTeleblitzSeeParticipants = priviledgeEntry.evnetTeleblitzSeeParticipants;
    this.eventTeleblitzShare = priviledgeEntry.eventTeleblitzShare;
    return this;
  }

}
class GroupOption{
  List<String> groupUpperClass;
  Map<String,dynamic> groupLowerClass;
  
  //Admin
  bool adminGroupMemberBrowser;
  bool enableDisplayName;

  //Events
  bool eventTeleblitzEnable;
  //Chat
  bool chatEnabel;
  GroupOption(Map<String,dynamic>data){
    if(data.containsKey(groupMapGroupUpperClass))
      groupUpperClass = data[groupMapGroupUpperClass];
    if(data.containsKey(groupMapGroupLowerClass))
      groupLowerClass = data[groupMapGroupLowerClass];
    if(data.containsKey(groupMapAdminGroupMemberBrowser))
      adminGroupMemberBrowser = data[groupMapAdminGroupMemberBrowser];
    if(data.containsKey(groupMapEnableDisplayName))
      enableDisplayName = data[groupMapEnableDisplayName];
    if(data.containsKey(groupMapEventTeleblitzEnable))
      eventTeleblitzEnable = data[groupMapEventTeleblitzEnable];
    if(data.containsKey(groupMapChatEnable))
      chatEnabel = data[groupMapChatEnable];
  }
}
class GroupLicence{
  String path, document;
  GroupLicenceType groupLicenceType;
  GroupLicence(Map<String,dynamic> data){
    if(data.containsKey(groupMapGroupLicenceType))
      switch (data[groupMapGroupLicenceType]) {
        case "groupMapGroupLienceTypePremium":
          if(!data.containsKey(groupMapGroupLicenceDocument))
            throw "$groupMapGroupLicenceDocument of groupMap has to be non-null";
          document = data[groupMapGroupLicenceDocument];
          if(!data.containsKey(groupMapGroupLicencePath))
            throw "$groupMapGroupLicencePath of groupMap has to be non-null";
          path = data[groupMapGroupLicencePath];
          groupLicenceType = GroupLicenceType.premium;
          break;
        case "groupMapGroupLienceTypeStandart":
          groupLicenceType = GroupLicenceType.standart;
          break;
        case "groupMapGroupLienceTypeAnarchy":
          groupLicenceType = GroupLicenceType.anarchy;
          break;
        default:
          groupLicenceType = GroupLicenceType.standart;
      }
      else
        groupLicenceType = GroupLicenceType.standart;
  }
}



  
  
