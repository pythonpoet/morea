import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/group.dart';
import 'package:morea/services/user.dart';
import 'package:morea/services/utilities/blockedUserChecker.dart';

Stream<Map<String, dynamic>> getGroupData(
    CrudMedthods crudMedthods, String groupID) async* {
  await for (DocumentSnapshot dsEventData
      in crudMedthods.streamDocument(pathGroups, groupID)) {
    yield dsEventData.data;
  }
}

List<String> sortHomeFeedByStartDate(Map<String, GroupData> mapGroupData) {
  //TODO add Timestamp in Firebase
  List<String> sort = new List<String>();
  Map<String, String> unsorted;
  mapGroupData.forEach((String groupID, GroupData groupData) {
    groupData.homeFeed.forEach((eventID, homeFeedEntry) {
      unsorted[eventID] = homeFeedEntry.eventStartTimeStamp;
    });
  });

  unsorted.forEach((String eventID, strTimestamp) {
    if (sort.length == 0)
      sort.add(eventID);
    else if (sort.length == 1) if (DateTime.parse(unsorted[sort[0]])
            .difference(DateTime.parse(strTimestamp))
            .inMinutes >=
        0)
      sort.add(eventID);
    else
      sort.insert(0, eventID);
    else {
      for (int i = 0; i < sort.length - 1; i++)
        if (DateTime.parse(unsorted[[i]])
                .difference(DateTime.parse(strTimestamp))
                .inMinutes >=
            0) if (DateTime.parse(strTimestamp)
                .difference(DateTime.parse(unsorted[sort[i + 1]]))
                .inMinutes >=
            0) {
          sort.insert(i + 1, eventID);
          break;
        }
      sort.add(eventID);
    }
  });
  return sort;
}

enum GroupLicenceType { premium, standart, anarchy }

class GroupData {
  //Objects
  CrudMedthods crud0;
  //Attributes
  GroupLicence groupLicence;
  GroupOption groupOption;
  HomeFeed homeFeed;
  PriviledgeEntry priviledge;
  Map<String, dynamic> groupData;
  Map<String, RoleEntry> roles = Map<String, RoleEntry>();
  Map<String, dynamic> groupUserData;
  GroupData({this.groupData, this.groupUserData}) {
    if (this.groupData != null) readGroup(this.groupData, this.groupUserData);
  }

  Future<void> readGroup(
      Map<String, dynamic> groupMap, Map<String, dynamic> groupUserData) {
    //turnOn/OFF groupMapTest
    if (true) {
      if (groupMap.containsKey(groupMapHomeFeed)) {
        this.homeFeed = HomeFeed()
            .readMap(Map<String, dynamic>.from(groupMap[groupMapHomeFeed]));
      } else
        throw "$groupMapHomeFeed has to be non-null";
      if (groupMap.containsKey(groupMapRoles)) {
        Map<String, dynamic> chash =
            Map<String, dynamic>.from(groupMap[groupMapRoles]);
        for (String key in chash.keys) {
          this.roles[key] =
              RoleEntry(data: Map<String, dynamic>.from(chash[key]));
        }
      } else
        throw "$groupMapRoles has to be non-null";

      this.priviledge = PriviledgeEntry(data: groupUserData);
      priviledge.readRole(globalConfigRoles, this.roles);
      if (groupMap.containsKey(groupMapGroupLicence))
        this.groupLicence = GroupLicence(
            Map<String, dynamic>.from(groupMap[groupMapGroupLicence]));
      else
        throw "$groupMapGroupLicence has to be non-null";

      if (groupMap.containsKey(groupMapGroupOption))
        this.groupOption = GroupOption(
            Map<String, dynamic>.from(groupMap[groupMapGroupOption]));
      else
        throw "$groupMapGroupOption has to be non-null";
    }
  }
}

class HomeFeed {
  Map<String, HomeFeedEntry> homeFeed;

  Iterable<HomeFeedEntry> get values => homeFeed.values;

  void forEach(void f(String eventID, HomeFeedEntry homeFeedEntry)) {}

  String getEventStartDate(String eventID) {
    return homeFeed[eventID].eventStartTimeStamp;
  }

  HomeFeed readMap(Map<String, dynamic> homeFeed) {
    for (String eventID in homeFeed.keys) {
      if (homeFeed[eventID].containsKey(groupMapUploadeByUserID))
        this.homeFeed[eventID].uploadedByUserID =
            homeFeed[eventID][groupMapUploadeByUserID];
      else
        throw "$groupMapUploadeByUserID of event: $eventID has to be non-null";

      if (homeFeed[eventID].containsKey(groupMapUploadedTimeStamp))
        this.homeFeed[eventID].uploadedTimeStamp =
            homeFeed[eventID][groupMapUploadedTimeStamp];
      else
        throw "$groupMapUploadedTimeStamp of event: $eventID has to be non-null";

      if (homeFeed[eventID].containsKey(groupMapParticipatingGroups))
        this.homeFeed[eventID].participatingGroups =
            homeFeed[eventID][groupMapParticipatingGroups];
      else
        throw "$groupMapParticipatingGroups of event: $eventID has to be non-null";

      if (homeFeed[eventID].containsKey(groupMapEventStartTimeStamp))
        this.homeFeed[eventID].eventStartTimeStamp =
            homeFeed[eventID][groupMapEventStartTimeStamp];
      else
        throw "$groupMapEventStartTimeStamp of event: $eventID has to be non-null";

      if (homeFeed[eventID].containsKey(groupMapEventEndTimeStamp))
        this.homeFeed[eventID].eventEndTimeStamp =
            homeFeed[eventID][groupMapEventEndTimeStamp];
      else
        throw "$groupMapEventEndTimeStamp of event: $eventID has to be non-null";
    }
    return this;
  }
}

class HomeFeedEntry {
  String uploadedByUserID;
  String uploadedTimeStamp;
  List<String> participatingGroups;
  String eventStartTimeStamp;
  String eventEndTimeStamp;
}

class GroupOption {
  List<String> groupUpperClass;
  Map<String, GroupLowerHirarchyEntry> groupLowerClass;

  //Admin
  bool adminGroupMemberBrowser;
  bool enableDisplayName;

  //Events
  bool eventTeleblitzEnable;
  //Chat
  bool chatEnable;
  GroupOption(Map<String, dynamic> data) {
    if (data.containsKey(groupMapGroupUpperClass))
      groupUpperClass = List<String>.from(data[groupMapGroupUpperClass]);
    if (data.containsKey(groupMapGroupLowerClass))
      groupLowerClass = Map<String, GroupLowerHirarchyEntry>.from(
          Map<String, dynamic>.from(data[groupMapGroupLowerClass])
              .map((key, value) {
        return MapEntry<String, GroupLowerHirarchyEntry>(
            key, GroupLowerHirarchyEntry(value));
      }));
    if (data.containsKey(groupMapAdminGroupMemberBrowser))
      adminGroupMemberBrowser = data[groupMapAdminGroupMemberBrowser];
    if (data.containsKey(groupMapEnableDisplayName))
      enableDisplayName = data[groupMapEnableDisplayName];
    if (data.containsKey(groupMapEventTeleblitzEnable))
      eventTeleblitzEnable = data[groupMapEventTeleblitzEnable];
    if (data.containsKey(groupMapChatEnable))
      chatEnable = data[groupMapChatEnable];
  }
  List<String> getLowerGroupsNickNames() {
    List<String> list = new List<String>();
    this.groupLowerClass.forEach((key, value) => list.add(value.groupNickName));
    return list;
  }

  List<String> getLowerGroupsIDs() {
    List<String> list = new List<String>();
    this.groupLowerClass.forEach((key, value) => list.add(value.groupID));
    return list;
  }
}

class GroupLicence {
  String path, document;
  GroupLicenceType groupLicenceType;
  GroupLicence(Map data_old) {
    Map<String, dynamic> data = Map<String, dynamic>.from(data_old);
    if (!data.containsKey(groupMapGroupLicenceType))
      throw "$groupMapGroupLicenceType has to be non-null";
    switch (data[groupMapGroupLicenceType]) {
      case "groupMapGroupLienceTypePremium":
        /* TODO 
          if(!data.containsKey(groupMapGroupLicenceDocument))
            throw "$groupMapGroupLicenceDocument of groupMap has to be non-null";
          document = data[groupMapGroupLicenceDocument];
          if(!data.containsKey(groupMapGroupLicencePath))
            throw "$groupMapGroupLicencePath of groupMap has to be non-null";
          path = data[groupMapGroupLicencePath]; */
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
  }
}

class GroupLowerHirarchyEntry {
  String groupID, groupNickName;
  GroupLowerHirarchyEntry(Map data) {
    Map<String, dynamic> data2 = Map<String, dynamic>.from(data);
    groupID = data[userMapgroupID];
    groupNickName = data[groupMapgroupNickName];
  }
}
