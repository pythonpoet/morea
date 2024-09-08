import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/group.dart';
import 'package:morea/services/utilities/blockedUserChecker.dart';

Stream<Map<String, dynamic>> getGroupData(
    CrudMedthods crudMedthods, String groupID) async* {
  await for (DocumentSnapshot dsEventData
      in crudMedthods.streamDocument(pathGroups, groupID)) {
    yield dsEventData.data()! as Map<String, dynamic>;
  }
}

List<String> sortHomeFeedByStartDate(Map<String, GroupData> mapGroupData) {
  List<String> sort = <String>[];
  Map<String, String> unsorted = Map<String, String>();
  mapGroupData.forEach((String groupID, GroupData groupData) {
    if (groupData.homeFeed!.homeFeed != null)
      groupData.homeFeed!.homeFeed.forEach((eventID, homeFeedEntry) {
        unsorted[eventID] = homeFeedEntry.eventStartTimeStamp!;
      });
  });
  if (unsorted == null) return [];
  unsorted.forEach((String eventID, strTimestamp) {
    if (sort.length == 0)
      sort.add(eventID);
    else if (sort.length == 1) if (DateTime.parse(unsorted[sort[0]]!)
            .difference(DateTime.parse(strTimestamp))
            .inMinutes >=
        0)
      sort.add(eventID);
    else
      sort.insert(0, eventID);
    else {
      for (int i = 0; i < sort.length - 1; i++)
        if (DateTime.parse(unsorted[[i]]!)
                .difference(DateTime.parse(strTimestamp))
                .inMinutes >=
            0) if (DateTime.parse(strTimestamp)
                .difference(DateTime.parse(unsorted[sort[i + 1]]!))
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
  CrudMedthods? crud0;
  //Attributes
  GroupLicence? groupLicence;
  GroupOption? groupOption;
  HomeFeed? homeFeed;
  PriviledgeEntry? priviledge;
  Map<String, dynamic> groupData;
  Map<String, RoleEntry> roles = Map<String, RoleEntry>();
  Map<String, dynamic>? groupUserData;
  String? groupID, groupNickName;
  GroupData({required this.groupData, this.groupUserData}) {
    print('GroupData groupData ' + this.groupData.toString());
    print('GroupData groupUserData ' + this.groupUserData.toString());
    readGroup(this.groupData, this.groupUserData);
  }

  void readGroup(
      Map<String, dynamic> groupMap, Map<String, dynamic>? groupUserData) {
    //turnOn/OFF groupMapTest
    if (true) {
      if (groupMap.containsKey("groupID"))
        this.groupID = groupMap["groupID"];
      else
        throw "groupID cant be empty";

      if (groupMap.containsKey(groupMapgroupNickName))
        this.groupNickName = groupMap[groupMapgroupNickName];
      else
        throw "$groupMapgroupNickName cant be emty";

      if (groupMap.containsKey(groupMapHomeFeed)) {
        this.homeFeed = HomeFeed();
        this
            .homeFeed!
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

      if (groupUserData != null) {
        print('reading group');
        this.priviledge = PriviledgeEntry(data: groupUserData);
        priviledge!.readRole(globalConfigRoles, this.roles);
        if (groupMap.containsKey(groupMapGroupLicence))
          this.groupLicence = GroupLicence(
              Map<String, dynamic>.from(groupMap[groupMapGroupLicence]));
        else
          throw "$groupMapGroupLicence has to be non-null";
      }
      if (groupMap.containsKey(groupMapGroupOption))
        this.groupOption = GroupOption(
            Map<String, dynamic>.from(groupMap[groupMapGroupOption]));
      else
        throw "$groupMapGroupOption has to be non-null";
    }
  }

  Future<void> uploadHomeFeedEntry(
      String userID,
      String eventID,
      String eventEndTimeStamp,
      String eventStartTimeStamp,
      Map<String, dynamic> data,
      CrudMedthods crudMedthods) async {
    HomeFeedEntry homeFeedEntry = HomeFeedEntry(
        uploadedByUserID: [userID],
        uploadedTimeStamp: [DateTime.now().toString()],
        eventEndTimeStamp: eventEndTimeStamp,
        eventStartTimeStamp: eventStartTimeStamp);
    this.homeFeed!.homeFeed = {eventID: homeFeedEntry};
    //Upload the HomeFeed
    Map<String, dynamic> map = homeFeed!.pack();
    return await crudMedthods.runTransaction(
      pathGroups,
      this.groupID!,
      {},
      function: (snap) {
        Map<String, dynamic> snapData = snap.data()! as Map<String, dynamic>;
        snapData[groupMapHomeFeed] = map;
        return snapData;
      },
    );
  }

  setParentPriviledge(String displayName) {
    if (this.groupOption!.parentialControl.enabled!) {
      Map<String, dynamic> data = {
        groupMapDisplayName: displayName,
        groupMapPriviledgeEntryType:
            this.groupOption!.parentialControl.roleType!,
        groupMapGroupJoinDate: ["Fri Sep 08 2023"],
        groupMapPriviledgeEntryLocation:
            this.groupOption!.parentialControl.roleLocation!,
      };
      this.priviledge = PriviledgeEntry(data: data);
      this.priviledge!.roleLocation =
          this.groupOption!.parentialControl.roleLocation!;
      this.priviledge!.roleType = this.groupOption!.parentialControl.roleType!;
      this.priviledge!.readRole(globalConfigRoles, this.roles);
    }
  }
}

class HomeFeed {
  Map<String, HomeFeedEntry> homeFeed = Map<String, HomeFeedEntry>();

  Iterable<HomeFeedEntry> get values => homeFeed.values;

  String getEventStartDate(String eventID) {
    return homeFeed[eventID]!.eventStartTimeStamp!;
  }

  void readMap(Map<String, dynamic> data) {
    print("TP1");
    if (!data.isEmpty) {
      for (String eventID in data.keys) {
        print("TP2");
        this.homeFeed[eventID] = HomeFeedEntry();
        if (data[eventID].containsKey(groupMapUploadeByUserID))
          this.homeFeed[eventID]!.uploadedByUserID =
              List<String>.from(data[eventID][groupMapUploadeByUserID]);
        else
          throw "$groupMapUploadeByUserID of event: $eventID has to be non-null";

        if (data[eventID].containsKey(groupMapUploadedTimeStamp))
          this.homeFeed[eventID]!.uploadedTimeStamp =
              List<String>.from(data[eventID][groupMapUploadedTimeStamp]);
        else
          throw "$groupMapUploadedTimeStamp of event: $eventID has to be non-null";

        if (data[eventID].containsKey(groupMapEventStartTimeStamp))
          this.homeFeed[eventID]!.eventStartTimeStamp =
              data[eventID][groupMapEventStartTimeStamp];
        else
          throw "$groupMapEventStartTimeStamp of event: $eventID has to be non-null";

        if (data[eventID].containsKey(groupMapEventEndTimeStamp))
          this.homeFeed[eventID]!.eventEndTimeStamp =
              data[eventID][groupMapEventEndTimeStamp];
        else
          throw "$groupMapEventEndTimeStamp of event: $eventID has to be non-null";
      }
    }
  }

  Map<String, dynamic> pack() {
    return homeFeed.map((key, value) => MapEntry(key, value.pack()));
  }
}

class HomeFeedEntry {
  List<String>? uploadedByUserID;
  List<String>? uploadedTimeStamp;
  List<String>? participatingGroups;
  String? eventStartTimeStamp;
  String? eventEndTimeStamp;

  HomeFeedEntry(
      {this.uploadedByUserID,
      this.uploadedTimeStamp,
      this.eventEndTimeStamp,
      this.eventStartTimeStamp});

  // ignore: missing_return
  Map<String, dynamic>? pack() {
    if (_validate())
      return Map.from({
        groupMapUploadeByUserID: this.uploadedByUserID,
        groupMapUploadedTimeStamp: this.uploadedTimeStamp,
        groupMapEventEndTimeStamp: this.eventEndTimeStamp,
        groupMapEventStartTimeStamp: this.eventStartTimeStamp
      });
    return null;
  }

  bool _validate() {
    if (this.eventEndTimeStamp == null)
      throw '$groupMapEventEndTimeStamp cant be null';
    if (this.eventStartTimeStamp == null)
      throw '$groupMapEventEndTimeStamp cant be null';
    if (this.uploadedByUserID == null)
      throw '$groupMapUploadeByUserID cant be null';
    if (this.uploadedTimeStamp == null)
      throw '$groupMapUploadedTimeStamp cant be null';
    return true;
  }
}

class GroupOption {
  List<String>? groupUpperClass;
  Map<String, GroupLowerHirarchyEntry>? groupLowerClass;

  ParentialControl parentialControl = ParentialControl();

  //Admin
  bool? adminGroupMemberBrowser;
  bool? enableDisplayName;

  //Events
  bool? eventTeleblitzEnable;
  //Chat
  bool? chatEnable;
  GroupOption(Map<String, dynamic> data) {
    if (data.containsKey(groupMapGroupUpperClass))
      groupUpperClass = List<String>.from(data[groupMapGroupUpperClass]);
    if (data.containsKey(groupMapParentalControl)) {
      if (data[groupMapParentalControl]["enabled"]) {
        this.parentialControl.enabled = true;
        this.parentialControl.roleLocation =
            data[groupMapParentalControl][groupMapPriviledgeEntryLocation];
        this.parentialControl.roleType =
            data[groupMapParentalControl][groupMapPriviledgeEntryType];
      } else
        this.parentialControl.enabled = false;
    } else
      this.parentialControl.enabled = false;

    if (data.containsKey("groupMapLowerClass")) {
      groupLowerClass =
          Map<String, dynamic>.from(data["groupMapLowerClass"] as Map).map(
              (groupID, entry) => MapEntry<String, GroupLowerHirarchyEntry>(
                  groupID, GroupLowerHirarchyEntry(entry)));
    }
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
    List<String> list = <String>[];
    this
        .groupLowerClass!
        .forEach((key, value) => list.add(value.groupNickName!));
    return list;
  }

  List<String> getLowerGroupsIDs() {
    List<String> list = <String>[];
    this.groupLowerClass!.forEach((key, value) => list.add(value.groupID!));
    return list;
  }
}

class ParentialControl {
  String? roleLocation, roleType;
  bool? enabled;
}

class GroupLicence {
  String? path, document;
  GroupLicenceType? groupLicenceType;
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
  String? groupID, groupNickName;
  GroupLowerHirarchyEntry(Map data) {
    Map<String, dynamic> data2 = Map<String, dynamic>.from(data);
    groupID = data2[userMapgroupID];
    groupNickName = data2[groupMapgroupNickName];
  }
}
