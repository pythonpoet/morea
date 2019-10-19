import 'package:morea/services/Teleblitz/telbz_firestore.dart';

import 'Getteleblitz.dart';
import 'auth.dart';
import 'crud.dart';
import 'dwi_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart' as random;

abstract class BaseMoreaFirebase {
  Future<void> createUserInformation(Map userInfo);

  Future<void> updateUserInformation(String userUID, Map userInfo);

  Future<DocumentSnapshot> getUserInformation(String userUID);

  Stream<QuerySnapshot> getChildren();

  Future<void> pendParent(
      String child_UID, String parent_UID, String parent_name);

  Stream<DocumentSnapshot> streamPendingParents(String child_UID);

  Future<void> setChildToParent(
      String child_UID, String parent_UID, String child_name);

  Future<void> uebunganmelden(
      String eventID, String userUID, String anmeldeUID, String anmeldeStatus);

  Future<QuerySnapshot> getTNs(String groupnr, String datum);

  Future<Map> getteleblitz(String groupnr);

  Future uploadteleblitz(String groupnr, Map data);

  Future<bool> refreshteleblitz(String groupnr);

  Stream<QuerySnapshot> getAgenda(String groupnr);

  Future uploadtoAgenda(String groupnr, String name, Map data);

  Future<void> uploaddevtocken(
      var messagingGroups, String token, String userUID);

  Stream<QuerySnapshot> getMessages(String groupnr);

  Future<void> setMessageRead(String userUID, String messageID, String groupnr);

  String upLoadChildRequest(String childUID);
}

class MoreaFirebase extends BaseMoreaFirebase {
  Info teleblitzinfo = new Info();
  CrudMedthods crud0;
  Auth auth0 = new Auth();
  DWIFormat dwiformat = new DWIFormat();
  TeleblizFirestore tbz;
  

  MoreaFirebase(Firestore firestore){
    crud0 = new CrudMedthods(firestore);
    tbz = new TeleblizFirestore(firestore);
  }

  Future<void> createUserInformation(Map userInfo) async {
    String userUID = await auth0.currentUser();
    await crud0.setData('user', userUID, userInfo);
    return null;
  }

  Future<void> updateUserInformation(
    String userUID,
    Map userInfo,
  ) async {
    userUID = dwiformat.simplestring(userUID);
    await crud0.setData('user', userUID, userInfo);
    return null;
  }

  Future<DocumentSnapshot> getUserInformation(String userUID) async {
    return await crud0.getDocument('user', userUID);
  }
  Future<DocumentSnapshot> getGroupInformation(String groupID)async{
    return await crud0.getDocument("groups", groupID);
  }

  Stream<QuerySnapshot> getChildren() {
    return crud0.streamCollection('user');
  }

  //Funktioniert das wück?
  Future<void> pendParent(
      String childUID, String parentUID, String parentName) async {
    Map<String, dynamic> parentMap = {};
    var old = await getUserInformation(childUID);

    if ((old.data['Eltern-pending'] != null) &&
        (old.data['Eltern-pending'].length != 0)) {
      parentMap = Map<String, dynamic>.from(old.data['Eltern-pending']);
    }
    if (parentMap[parentName] == null) {
      parentMap[parentName] = parentUID;
      Map newUserData = old.data;
      newUserData['Eltern-pending'] = parentMap;
      updateUserInformation(childUID, newUserData);
    }
  }

  Stream<DocumentSnapshot> streamPendingParents(String childUID) {
    return crud0.streamDocument('user', childUID);
  }

  Future<void> setChildToParent(
      String childUID, String parentUID, String childName) async {
    Map<String, dynamic> childMap = {};
    var old = await getUserInformation(parentUID);

    if ((old.data['Kinder'] != null) && (old.data['Kinder'].length != 0)) {
      childMap = Map<String, dynamic>.from(old.data['Kinder']);
    }
    if (childMap[childName] == null) {
      childMap[childName] = childUID;
      Map newUserData = old.data;
      newUserData['Kinder'] = childMap;
      updateUserInformation(parentUID, newUserData);
    }
  }

  Future<void> uebunganmelden(
      String eventID, String userUID, String anmeldeUID, String anmeldeStatus) async {
        crud0.runTransaction("events/$eventID/Anmeldungen", anmeldeUID, Map<String, dynamic>.from({
      "AnmeldeStatus":  anmeldeStatus,
      "AnmedeUID":      anmeldeUID,
      "UID":            userUID,
      "Timestamp":      DateTime.now()
    }));
    return null;
  }

  Future<void> uploadteleblitz(String groupID, Map data) async{
    String eventID =  groupID +  data['datum'].toString().replaceAll('Samstag, ', '');
    Map<String, String> akteleblitz = {
      'AktuellerTeleblitz': eventID
    };
       
    await tbz.uploadTelbzAkt(groupID, akteleblitz);
    return await tbz.uploadTelbz(eventID, data);
  }
  Future<String> createEventID()async{
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
    if ( DateTime.now().difference(letztesaktdat).inMinutes > 1) {
      return true;
    }
    return false;
  }

    //TODO Telebliz 
  Future<QuerySnapshot> getTNs(String stufe, String datum) async {
    /*
    String uebungsdatum = teleblitzinfo.datum;
    stufe = dwiformat.simplestring(stufe);
    return await crud0.getCollection('uebung/$stufe/$datum');*/
  }

  Stream<QuerySnapshot> getAgenda(String groupnr) {
    return crud0.streamOrderCollection('groups/$groupnr/Agenda', 'Order');
  }

  Future<void> uploadtoAgenda(String groupnr, String name, Map data) async {
    name = dwiformat.simplestring(name);
    crud0.runTransaction('groups/$groupnr/Agenda', name, data);
    return null;
  }

//TODO Macht immer son error
  Future<void> uploaddevtocken(
      var messagingGroups, String token, String userUID) async {
    Map<String, dynamic> tokendata = {'devtoken': token};
    for (var u in messagingGroups.keys) {
      if (messagingGroups[u]) {
        await crud0.setData('groups/$u/Devices', userUID, tokendata);
      }
    }
    return null;
  }

  String upLoadChildRequest(String childUID) {
    Map<String, String> data = {
      'purpose': 'child-pend-request',
      'child-UID': childUID,
      'timestamp': DateTime.now().toIso8601String()
    };
    String qrCodeString = random.randomAlphaNumeric(78);
    crud0.setData('user/requests/pend', qrCodeString, data);
    return qrCodeString;
  }

  Stream<QuerySnapshot> getMessages(String groupnr) {
    return crud0.streamCollection('/groups/$groupnr/messages');
  }

  Future<void> uploadMessage(groupnr, Map data) async {
    await crud0.setDataMessage('groups/$groupnr/messages', data);
    return null;
  }

  Future<void> setMessageRead(
      String userUID, String messageID, String groupnr) async {
    userUID = dwiformat.simplestring(userUID);
    var oldMessage =
        await crud0.getMessage('/groups/$groupnr/messages', messageID);
    oldMessage.data['read'][userUID] = true;
    await crud0.updateMessage(
        'groups/$groupnr/messages', messageID, oldMessage.data);
    return null;
  }
}
