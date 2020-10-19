import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/user.dart';
import 'package:morea/services/utilities/blockedUserChecker.dart';

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
abstract class BaseMoreGroup {
  void streamGroupMap(Stream<String> groupID);
  void readGroupMap(
      Map<String, dynamic> groupMap, String groupID, String userID);
  Future<void> createGroup(Map<String, dynamic> group);
  Future<void> joinGroup(String groupID);
  Future<void> inviteUsers(List<String> luserIDs);
  //TODO functions
  //TODO fix groupMap doc structure
}

class MoreaGroup extends BaseMoreGroup {
  //Objects
  CrudMedthods crud0;
  //Attributes
  Stream<String> smGroupID;
  Stream<DocumentSnapshot> _sDSGroupMap;
  List<String> homeFeed;
  PriviledgeEntry priviledge;
  Map<String, RoleEntry> roles;

  MoreaGroup({this.smGroupID, @required this.crud0}) {
    streamGroupMap(smGroupID);
  }
  void streamGroupMap(Stream<String> smGroupID) async {
    await for (String groupID in smGroupID) {
      _sDSGroupMap = crud0.streamDocument(pathGroups, groupID);

      await for (DocumentSnapshot dSGroupMap in _sDSGroupMap)
        readGroupMap(dSGroupMap.data, groupID, sessionUserID);
    }
  }

  Future<Map<String, dynamic>> getUserPriviledge(
      String groupID, String userID) async {
    return Map<String, dynamic>.from((await crud0.getDocument(
            '$pathGroups/$groupID/$pathPriviledge', userID))
        .data);
  }

  void readGroupMap(Map<String, dynamic> groupMap, groupID, userID) async {
    //turnOn/OFF groupMapTest
    if (true) {
      if (groupMap.containsKey(groupMapHomeFeed))
        this.homeFeed = groupMap[groupMapHomeFeed];
      else
        throw "$groupMapHomeFeed has to be non-null";

      if (groupMap.containsKey(groupMapRoles))
        groupMap[groupMapRoles].map((String key, dynamic value) => this
            .roles[key] = RoleEntry(data: Map<String, dynamic>.from(value)));
      else
        throw "$groupMapRoles has to be non-null";
      Map<String, dynamic> groupUserData =
          await getUserPriviledge(groupID, userID);
      this.priviledge = PriviledgeEntry(data: groupUserData);
      priviledge.readRole(globalConfigRoles, this.roles);
    }
  }

  Future<void> createGroup(Map<String, dynamic> groupMap) {}
  Future<void> inviteUsers(List<String> luserIDs) {}
  Future<void> joinGroup(String groupID) {}
}

class PriviledgeEntry extends RoleEntry {
  String displayName;
  String roleType;
  String roleLocation;
  List<String> groupJoinDate;
  Map<String, dynamic> customInfo;
  Map<String, dynamic> rawPriviledge;
  RoleEntry role;
  PriviledgeEntry({CrudMedthods crud0, Map data}) {
    if (data != null) this.readPriviledgeEntry(Map<String, dynamic>.from(data));
  }

  void readPriviledgeEntry(Map<String, dynamic> data) {
    this.displayName = data[groupMapDisplayName];
    this.roleType = data[groupMapPriviledgeEntryType];
    this.groupJoinDate = List<String>.from(data[groupMapGroupJoinDate]);
    this.roleLocation = data[groupMapPriviledgeEntryLocation];
    this.rawPriviledge = data;
  }

  void readRole(Map<String, RoleEntry> global, Map<String, RoleEntry> local) {
    if (this.roleLocation == 'local') {
      if (local.containsKey(this.roleType)) {
        if (local[groupMapPriviledgeEntryCustomInfo] != null)
          local[this.roleType].customInfoTypes.forEach((key, value) {
            this.customInfo[key] =
                rawPriviledge[groupMapPriviledgeEntryCustomInfo][key];
          });
        this.role = local[this.roleType];
      }
      print("Role ${this.roleLocation} is not defined in $local");
    } else if (this.roleLocation == 'global') {
      if (global.containsKey(this.roleType)) {
        if (global[this.roleType].customInfoTypes != null)
          global[this.roleType].customInfoTypes.forEach((key, value) {
            this.customInfo[key] =
                rawPriviledge[groupMapPriviledgeEntryCustomInfo][key];
          });
        this.role = global[this.roleType];
        print(this.role);
      } else
        print("Role ${this.roleType} is not defined in $global");
    }
  }
}

class RoleEntry {
  //General Priviledge: 0 no w/r, 1 no w but r access, 2  w/r access, 3 w/r acces able to change general for all users.
  int groupPriviledge = 0;
  Map<String, dynamic> customInfoTypes;
  String roleName;

  bool seeMembers;
  bool seeMembersDetail;
  int teleblitzPriviledge;

  RoleEntry({Map<String, dynamic> data}) {
    if (data != null) this.read(data);
  }
  void read(Map<String, dynamic> data) {
    if (data.containsKey(groupMapgroupPriviledge))
      this.groupPriviledge = data[groupMapgroupPriviledge];
    if (data.containsKey(groupMapRolesCustomInfoTypes))
      this.customInfoTypes = data[groupMapRolesCustomInfoTypes];
    this.roleName = data[groupMapRolesRoleName];
    this.seeMembers = data[groupMapPriviledgeEntrySeeMembers];
    this.seeMembersDetail = data[groupMapPriviledgeEntrySeeMembersDetails];
    if (data[eventTeleblitzPriviledge] is int)
      this.teleblitzPriviledge = data[eventTeleblitzPriviledge];
    else if (data[eventTeleblitzPriviledge] is String)
      this.teleblitzPriviledge = int.parse(data[eventTeleblitzPriviledge]);
    else
      throw "Runtype: ${data[eventTeleblitzPriviledge].runtimeType} for teleblitzPriviledge is not supported";
    print(this.teleblitzPriviledge);
  }
}
