import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/Teleblitz/telbz_firestore.dart';
import 'package:morea/services/cloud_functions.dart';
import 'package:morea/services/utilities/dwi_format.dart';
import 'auth.dart';
import 'crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart' as random;

abstract class BaseMoreaFirebase {
  String get getDisplayName;

  String get getPfandiName;

  String get getGroupID;

  String get getVorName;

  String get getNachName;

  String get getPos;

  //String get getHomeFeedMainEventID;

  String get getEmail;

  List<String> get getSubscribedGroups;

  Map<String, dynamic> get getGroupMap;

  Map<String, dynamic> get getUserMap;

  Map<String, Map<String, String>> get getChildMap;

  Future<void> createUserInformation(Map userInfo);

  Future<void> updateUserInformation(String userUID, Map userInfo);

  Future<DocumentSnapshot> getUserInformation(String userUID);

  Stream<QuerySnapshot> getChildren();

  Stream<QuerySnapshot> getMessages(String groupnr);

  Future<void> setMessageRead(String userUID, String messageID, String groupnr);

  Stream<QuerySnapshot> streamCollectionWerChunnt(String eventID);
}

class MoreaFirebase extends BaseMoreaFirebase {
  CrudMedthods crud0;
  Auth auth0 = new Auth();
  DWIFormat dwiformat = new DWIFormat();
  TeleblizFirestore tbz;
  Map<String, dynamic> _userMap, _groupMap;
  Map<String, int> _groupPrivilege= new Map();
  Map<String, Map<String, String>>_childMap;
  String _displayName,
      _pfadiName,
      _groupID,
      _vorName,
      _nachName,
      _pos,
      //_homeFeedMainEventID,
      _email;
  Map<String, dynamic> _messagingGroups;
  List<String> _subscribedGroups = new List<String>();
  Firestore firestore;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  MoreaFirebase(Firestore firestore, {List groupIDs}) {
    this.firestore = firestore;
    crud0 = new CrudMedthods(firestore);
    if (groupIDs != null) tbz = new TeleblizFirestore(firestore, groupIDs);
  }

  String get getDisplayName => _displayName;

  String get getPfandiName => _pfadiName;

  String get getGroupID => _groupID;

  String get getVorName => _vorName;

  String get getNachName => _nachName;

  String get getPos => _pos;

  String get getEmail => _email;

  //String get getHomeFeedMainEventID => _homeFeedMainEventID;

  List<String> get getSubscribedGroups => _subscribedGroups;

  Map<String, dynamic> get getGroupMap => _groupMap;

  Map<String, dynamic> get getUserMap => _userMap;

  Map<String, Map<String, String>> get getChildMap => _childMap;
  Map<String, int> get getGroupPrivilege => _groupPrivilege;

  Future<void> getData(String userID) async {
    _userMap = Map<String, dynamic>.from(
        (await crud0.getDocument(pathUser, userID)).data);
    _pfadiName = _userMap[userMapPfadiName];
    _groupID = _userMap[userMapgroupID];
    _vorName = _userMap[userMapVorName];
    _nachName = _userMap[userMapNachName];
    _pos = _userMap[userMapPos];
    _email = _userMap[userMapEmail];
    _subscribedGroups =
        List<String>.from(_userMap[userMapSubscribedGroups] ?? []);
    if (_pfadiName == '')
      _displayName = _vorName;
    else
      _displayName = _pfadiName;
    if ((_pos == userMapLeiter) || (_pos == userMapTeilnehmer)) {
      _groupMap =
          (await crud0.getDocument(pathGroups, _userMap[userMapgroupID])).data;
      if(_groupMap["Priviledge"].containsKey(_userMap[userMapUID]))
      _groupPrivilege[_groupID] = _groupMap["Priviledge"][_userMap[userMapUID]]["Priviledge"];
      else _groupPrivilege[_groupID] = 0;
     
    } else {
      if (_userMap.containsKey(userMapKinder)) {
        Map<String, String> kinderMap =
            Map<String, String>.from(_userMap[userMapKinder]);
        _childMap = await createChildMap(kinderMap);
      }
    }
  }

  Future<Map<String, Map<String, String>>> createChildMap(
      Map<String, String> childs) async {
    Map<String, Map<String, String>> childMap = new Map();
    for (String vorname in childs.keys) {
      Map<String, dynamic> childUserDat =
          (await crud0.getDocument(pathUser, childs[vorname])).data;
      if (childMap.containsKey(childUserDat[userMapgroupID]))
        childMap[childUserDat[userMapgroupID]][vorname] = childs[vorname];
      else
        childMap[childUserDat[userMapgroupID]] = {vorname: childs[vorname]};
      if (!_subscribedGroups.contains(childUserDat[userMapgroupID]))
        _subscribedGroups.add(childUserDat[userMapgroupID]);
    }
    parentGroupPrivilege(childMap);
    return childMap;
  }
  //TODO GroupPrivilege aus groupMap nehmen
parentGroupPrivilege(Map<String, Map<String, String>> childMap){
  for (String groupID in childMap.keys)
    _groupPrivilege[groupID] = 2;
}
  initTeleblitz() {
    List<String> groupIDs = new List<String>();
    groupIDs.addAll(_subscribedGroups);
    groupIDs.add(_groupID);
    tbz = new TeleblizFirestore(firestore, groupIDs);
  }

  Future<void> createUserInformation(Map userInfo) async {
    String userUID = await auth0.currentUser();
    await crud0.setData(pathUser, userUID, userInfo);
    return null;
  }

  //Vorschlag an Maxi
  Future<void> updateUserInformation(String userUID, Map userInfo){
    if(userInfo[userMapAccountCreated] is Timestamp)
      userInfo[userMapAccountCreated] = userInfo[userMapAccountCreated].toString();
    return callFunction(getcallable("updateUserProfile"),param: userInfo);
  }

  Future<HttpsCallableResult> goToNewGroup(String userID, String displayName, String oldGroup, String newGroup){
    return callFunction(getcallable("goToNewGroup"), param: {
      userMapUID: userID,
      "oldGroup": oldGroup,
      "newGroup": newGroup,
      groupMapDisplayName :displayName
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
        anmeldeUID,
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

  Future<void> uploadteleblitz(String groupID, Map data) async {
    String eventID =
        groupID + data['datum'].toString().replaceAll('Samstag, ', '');
    Map<String, List> akteleblitz = {
      groupMapHomeFeed: [eventID]
    };
    await tbz.uploadTelbzAkt(groupID, akteleblitz);
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
    Map<String, dynamic> tokendata = {'devtoken': await firebaseMessaging.getToken()};
    return await crud0.setData('groups/$groupID/Devices', auth0.getUserID, tokendata);
  }

  Stream<QuerySnapshot> getMessages(String groupnr) {
    return crud0.streamCollection('/groups/$groupnr/messages');
  }

  Future<void> uploadMessage(groupnr, Map data) async {
    await crud0.setDataWithoutDocumentName('groups/$groupnr/messages', data);
    return null;
  }

  Future<void> setMessageRead(
      String userUID, String messageID, String groupnr) async {
    userUID = dwiformat.simplestring(userUID);
    var oldMessage =
        await crud0.getDocument('/groups/$groupnr/messages', messageID);
    List newRead = [];
    for (String index in oldMessage.data['read']) {
      newRead.add(index);
    }
    newRead.add(userUID);
    oldMessage.data['read'] = newRead;
    await crud0.setData('groups/$groupnr/messages', messageID, oldMessage.data);
    return null;
  }

  Stream<QuerySnapshot> streamCollectionWerChunnt(String eventID) {
    return crud0.streamCollection("$pathEvents/$eventID/$pathAnmeldungen");
  }
  Future<void> uploadDevTocken(String userID) async {
    await callFunction(getcallable("uploadDevTocken"),param: Map<String,String>.from(
      {
        userMapDeviceToken: await firebaseMessaging.getToken(),
        userMapUID: userID
      }
    ));
  }
  Future<void> groupPriviledgeTN(String groupID, String userID, String displayName) async {
    return callFunction(getcallable("priviledgeTN"),param: Map<String,String>.from(
      {
        userMapgroupID: groupID,
        userMapUID: userID,
        "displayName": displayName
      }
    ));
  }
}
