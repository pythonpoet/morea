import 'dart:async';

import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/Group/group_data.dart';
import 'package:morea/services/Teleblitz/telbz_firestore.dart';
import 'package:morea/services/cloud_functions.dart';
import 'package:morea/services/user.dart';
import 'package:morea/services/utilities/dwi_format.dart';
import 'package:rxdart/rxdart.dart';
import 'auth.dart';
import 'crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart' as random;

abstract class BaseMoreaFirebase {
  String get getDisplayName;

  String get getPfandiName;

  List<String> get getGroupIDs;

  String get getVorName;

  String get getNachName;

  String get getPos;

  //String get getHomeFeedMainEventID;

  String get getEmail;

  Map<String, dynamic> get getGroupMap;

  Map<String, dynamic> get getUserMap;

  Map<String, Map<String, String>> get getChildMap;
  Stream<Map<String, GroupData>> get getGroupDataStream;

  Future<void> createUserInformation(Map userInfo);

  Future<void> updateUserInformation(String userUID, Map userInfo);

  Future<DocumentSnapshot> getUserInformation(String userUID);

  Stream<QuerySnapshot> getChildren();

  Future<void> setMessageRead(String userUID, String messageID, String groupnr);

  Stream<QuerySnapshot> streamCollectionWerChunnt(String eventID);

  Future<String> getMailChimpApiKey();

  Future<String> getWebflowApiKey();

  Future<void> uploadChildUserInformation(Map<String, dynamic> childUserInfo);

  Future<void> priviledgeEltern(String groupID);

  Future<void> upgradeChild(
      Map<String, dynamic> childMap, String oldUID, String password);
}

class MoreaFirebase extends BaseMoreaFirebase {
  CrudMedthods crud0;
  Auth auth0 = new Auth();
  DWIFormat dwiformat = new DWIFormat();
  TeleblizFirestore tbz;
  Map<String, dynamic> _userMap;
  Platform platform = Platform();
  Firestore firestore;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  User moreaUser;

  StreamController<Map<String, GroupData>> sCGroupMaps = BehaviorSubject();

  MoreaFirebase(Firestore firestore, {List groupIDs}) {
    this.firestore = firestore;
    crud0 = new CrudMedthods(firestore);
    moreaUser = new User(crud0);
    if (groupIDs != null) tbz = new TeleblizFirestore(firestore, groupIDs);
  }

  String get getDisplayName => moreaUser.displayName;

  String get getPfandiName => moreaUser.pfadiName;

  List<String> get getGroupIDs => moreaUser.groupIDs;

  String get getVorName => moreaUser.vorName;

  String get getNachName => moreaUser.nachName;

  String get getPos => moreaUser.pos;

  String get getEmail => moreaUser.email;

  String get getGeschlecht => moreaUser.geschlecht;

  Map<String, GroupData> get getMapGroupData => moreaUser.subscribedGroups;

  Map<String, dynamic> get getGroupMap => moreaUser.groupMap;

  Map<String, dynamic> get getUserMap => _userMap;

  Map<String, Map<String, String>> get getChildMap => moreaUser.childMap;

  Map<String, int> get getGroupPrivilege => moreaUser.groupPrivilege;

  int getHighestEventPriviledge(List<String> groupIDs) =>
      moreaUser.getHighestEventPriviledge(groupIDs);

  Stream<Map<String, GroupData>> get getGroupDataStream => sCGroupMaps.stream;

  Future<bool> getData(String userID) async {
    DocumentSnapshot userData = (await crud0.getDocument(pathUser, userID));
    if (!userData.exists) {
      auth0.deleteUserID();
      return false;
    }

    this._userMap = Map<String, dynamic>.from(userData.data);
    await moreaUser.getUserData(_userMap);
    return true;
  }

  initTeleblitz() async {
    List<String> groupIDs = new List<String>();
    tbz = new TeleblizFirestore(firestore, groupIDs);

    for (String groupID in this.getGroupIDs) {
      var someVar = (await crud0.getDocument(
              '$pathGroups/$groupID/$pathPriviledge', moreaUser.userID))
          .data;
      sCGroupMaps.addStream(crud0
          .streamDocument(pathGroups, groupID)
          .map((DocumentSnapshot dSGroup) {
        return Map<String, GroupData>.of({
          dSGroup.documentID:
              GroupData(groupData: dSGroup.data, groupUserData: someVar)
        });
      }));
    }
  }

  Future<void> createUserInformation(Map userInfo) async {
    try {
      String userUID = await auth0.currentUser();
      Map<String, dynamic> payload = {'UID': userUID, 'content': userInfo};
      await callFunction(getcallable('createUserMap'), param: payload);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Vorschlag an Maxi
  Future<void> updateUserInformation(String userUID, Map userInfo) {
    if (userInfo[userMapAccountCreated] is Timestamp)
      userInfo[userMapAccountCreated] =
          userInfo[userMapAccountCreated].toString();
    return callFunction(getcallable("updateUserProfile"), param: userInfo);
  }

  Future<HttpsCallableResult> goToNewGroup(
      String userID, String displayName, String oldGroup, String newGroup) {
    return callFunction(getcallable("goToNewGroup"), param: {
      userMapUID: userID,
      "oldGroup": oldGroup,
      "newGroup": newGroup,
      groupMapDisplayName: displayName
    });
  }

  Future<DocumentSnapshot> getUserInformation(String userUID) async {
    return await crud0.getDocument(pathUser, userUID);
  }

  Future<Map<String, dynamic>> getGroupInformation(groupID) async =>
      Map<String, dynamic>.from(
          (await crud0.getDocument(pathGroups, groupID)).data);

  Stream<QuerySnapshot> getChildren() {
    return crud0.streamCollection(pathUser);
  }

  Future<void> childAnmelden(String eventID, String userUID, String anmeldeUID,
      String anmeldeStatus, String name) async {
    crud0.runTransaction(
        "$pathEvents/$eventID/Anmeldungen",
        anmeldeUID,
        Map<String, dynamic>.from({
          "AnmeldeStatus": anmeldeStatus,
          "AnmedeUID": anmeldeUID,
          "UID": userUID,
          "Name": name,
          "Timestamp": DateTime.now()
        }));
    return null;
  }

  Future<void> parentAnmeldet(String eventID, String childUID,
      String anmeldeUID, String anmeldeStatus, String name) async {
    crud0.runTransaction(
        "$pathEvents/$eventID/Anmeldungen",
        childUID,
        Map<String, dynamic>.from({
          "AnmeldeStatus": anmeldeStatus,
          eventMapAnmeldeUID: anmeldeUID,
          "UID": childUID,
          "ParentUID": getUserMap[userMapUID],
          "Timestamp": DateTime.now(),
          "Name": name
        }));
    return null;
  }

  Future<void> createEvent(List<String> groupIDs, String eventEndTimeStamp,
      String eventStartTimeStamp, Map<String, dynamic> data) async {
    //Upload the Event
    data['Timestamp'] = DateTime.now().toString();
    String eventID =
        await this.crud0.setDataWithoutDocumentName(pathEvents, data);

    //Upload homeFeed
    this.uploadHomeFeedEntry(
        eventID, groupIDs, eventEndTimeStamp, eventStartTimeStamp, data);
  }

  Future<void> uploadHomeFeedEntry(
      String eventID,
      List<String> groupIDs,
      String eventEndTimeStamp,
      String eventStartTimeStamp,
      Map<String, dynamic> data) {
    for (String groupID in groupIDs)
      //Upload the HomeFeed
      this.getMapGroupData[groupID].uploadHomeFeedEntry(this.moreaUser.userID,
          eventID, eventEndTimeStamp, eventStartTimeStamp, data, this.crud0);
  }

/*
  Future<void> updateEvent(String eventID, Map<String, dynamic> data,
      {List<String> groupIDADD, List<String> groupIDRM}) async {
    // Check if groupID was removed
    this.crud0.runTransaction(pathEvents, eventID, data);
    if (groupIDADD != null)
      this.uploadHomeFeedEntry(groupIDADD, data[groupMapEventEndTimeStamp],
          data[groupMapEventStartTimeStamp], data);
    if (groupIDRM != null)
      groupIDRM.forEach((groupID) {
        this.deleteHomeFeedEntry(eventID, groupID);
      });
  }
*/
  Future<void> deleteHomeFeedEntry(String eventID, String groupID) async {
    this.crud0.runTransaction(
      pathGroups,
      groupID,
      {},
      function: (snap) {
        snap.data[groupMapHomeFeed].removeWhere((key, value) => key == eventID);
        return snap.data;
      },
    );
  }

  Future<void> deleteEvent(String eventID, List<String> groupIDs) {
    //Remove HomeFeedEntry
    for (String groupID in groupIDs) {
      this.deleteHomeFeedEntry(eventID, groupID);
    }
    //Remove Event
    return this.crud0.deletedocument(pathEvents, eventID);
  }

  Future<void> uploadteleblitz(String groupID, Map data) async {
    //TODO fix weird groupIDs disappearing problem
    List groupIDs = data['groupIDs'];
    String eventID =
        groupID + data['datum'].toString().replaceAll('Samstag, ', '');
    Map<String, List> akteleblitz = {
      groupMapHomeFeed: [eventID]
    };
    await tbz.uploadTelbzAkt(groupID, akteleblitz);
    data['groupIDs'] = groupIDs;
    return await tbz.uploadTelbz(eventID, data);
  }

  Future<String> createEventID() async {
    String eventID;
    do {
      eventID = random.randomNumeric(9);
    } while (await tbz.eventIDExists(eventID));
    return eventID;
  }

  Future<Map> getteleblitz(String eventID) async {
    if (eventID != null) {
      return await tbz.getTelbz(eventID);
    } else {
      return null;
    }
  }

  Future<bool> refreshteleblitz(String eventID) async {
    DateTime letztesaktdat;
    Map telbz = await tbz.getTelbz(eventID);

    if (telbz != null) {
      letztesaktdat = DateTime.parse(telbz['Timestamp']);
    } else {
      letztesaktdat = DateTime.parse('2019-03-07T13:30:16.388642');
    }
    if (DateTime.now().difference(letztesaktdat).inMinutes > 1) {
      return true;
    }
    return false;
  }

  Stream<QuerySnapshot> getAgenda(String groupnr) {
    return crud0.streamOrderCollection('groups/$groupnr/Agenda', 'Order');
  }

  Future<void> uploadtoAgenda(String groupnr, String name, Map data) async {
    name = dwiformat.simplestring(name);
    crud0.runTransaction('groups/$groupnr/Agenda', name, data);
    return null;
  }

  Future<void> subscribeToGroup(String groupID) async {
    await firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure();
    Map<String, dynamic> tokendata = {
      'devtoken': await firebaseMessaging.getToken()
    };
    return await crud0.setData(
        'groups/$groupID/Devices', auth0.getUserID, tokendata);
  }

  Future<void> uploadMessage(Map data) async {
    await callFunction(getcallable('uploadAndNotifyMessage'), param: data);
    return null;
  }

  Future<void> setMessageRead(
      String userUID, String messageID, String groupnr) async {
    var oldMessage = await crud0.getDocument('messages', messageID);
    List newRead = [];
    for (String index in oldMessage.data['read']) {
      newRead.add(index);
    }
    newRead.add(userUID);
    oldMessage.data['read'] = newRead;
    await crud0.setData('messages', messageID, oldMessage.data);
    return null;
  }

  Stream<QuerySnapshot> streamCollectionWerChunnt(String eventID) {
    return crud0.streamCollection("$pathEvents/$eventID/$pathAnmeldungen");
  }

  Future<void> uploadDevTocken(String userID) async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String deviceID;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      deviceID = androidDeviceInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      deviceID = iosDeviceInfo.identifierForVendor;
    }
    await callFunction(getcallable("uploadDevTocken"),
        param: Map<String, String>.from({
          userMapDeviceToken: await firebaseMessaging.getToken(),
          userMapUID: userID,
          "deviceID": deviceID,
        }));
    return null;
  }

  Future<void> groupPriviledgeTN(String groupID, String userID,
      String displayName, Map<String, dynamic> customInfo) async {
    return callFunction(getcallable("priviledgeTN"),
        param: Map<String, dynamic>.from({
          "groupID": groupID,
          userMapUID: userID,
          groupMapDisplayName: displayName,
          groupMapPriviledgeEntryType: "Teilnehmer",
          groupMapPriviledgeEntryLocation: "local",
          groupMapPriviledgeEntryCustomInfo: customInfo
        }));
  }

  Future<String> getMailChimpApiKey() async {
    DocumentSnapshot document = await crud0.getDocument('config', 'apiKeys');
    String result = document.data['mailchimp'];
    return result;
  }

  Future<String> getWebflowApiKey() async {
    DocumentSnapshot document = await crud0.getDocument('config', 'apiKeys');
    String result = document.data['webflow'];
    return result;
  }

  @override
  Future<HttpsCallableResult> uploadChildUserInformation(
      Map<String, dynamic> childUserInfo) async {
    return await callFunction(getcallable("createChildUserMap"),
        param: childUserInfo);
  }

  @override
  Future<void> priviledgeEltern(String groupID) async {
    return await callFunction(getcallable('priviledgeEltern'), param: {
      'groupID': groupID,
      'UID': getUserMap[userMapUID],
      'DisplayName': this.getVorName
    });
  }

  @override
  Future<String> upgradeChild(Map<String, dynamic> childMap, String oldChildUID,
      String password) async {
    String uid = await auth0.createUserWithEmailAndPasswordForChild(
        childMap[userMapEmail], password);
    childMap[userMapUID] = uid;
    childMap.remove(userMapChildUID);

    String displayname;
    if (childMap[userMapPfadiName] == null ||
        childMap[userMapPfadiName] == '') {
      displayname = childMap[userMapVorName];
    } else {
      displayname = childMap[userMapPfadiName];
    }

    Map<String, dynamic> payload = {
      'UID': uid,
      'content': childMap,
      'elternList': childMap[userMapEltern].keys.toList(),
      'vorname': childMap[userMapVorName],
      'oldChildUID': oldChildUID,
    };
    await callFunction(getcallable('upgradeChildMap'), param: payload);

    Map<String, dynamic> deletePayload = {
      'UID': oldChildUID,
    };
    await callFunction(getcallable('deleteChildMap'), param: deletePayload);

    Map<String, dynamic> updatePriviledgePayload = <String, dynamic>{
      'UID': uid,
      'groupIDs': childMap[userMapGroupIDs],
      'DisplayName': displayname,
      'oldUID': oldChildUID
    };
    await callFunction(getcallable('updatePriviledge'),
        param: updatePriviledgePayload);
    return uid;
  }
}
