import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/MiData.dart';

class User {
  String displayName,
      pfadiName,
      groupID,
      vorName,
      nachName,
      pos,
      email,
      adresse,
      geburtstag,
      handynummer,
      ort,
      plz,
      geschlecht,
      userID;
  List<String> subscribedGroups = new List<String>();
  Map<String, int> groupPrivilege = new Map();
  Map<String, Map<String, String>> childMap;
  Map<String, dynamic> _userMap, groupMap;
  CrudMedthods crud0;

  User(this.crud0);

  Future getUserData(Map<String, dynamic> userMap) async {
    _userMap = userMap;
    if (_userMap.containsKey(userMapgroupID))
      groupID = _userMap[userMapgroupID];
    if (_userMap.containsKey(userMapVorName))
      vorName = _userMap[userMapVorName];
    if (_userMap.containsKey(userMapNachName))
      nachName = _userMap[userMapNachName];
    if (_userMap.containsKey(userMapPos)) pos = _userMap[userMapPos];
    if (_userMap.containsKey(userMapEmail)) email = _userMap[userMapEmail];
    if (_userMap.containsKey(userMapAdresse))
      adresse = _userMap[userMapAdresse];
    if (_userMap.containsKey(userMapGeburtstag))
      geburtstag = _userMap[userMapGeburtstag];
    if (_userMap.containsKey(userMapHandynummer))
      handynummer = _userMap[userMapHandynummer];
    if (_userMap.containsKey(userMapOrt)) ort = _userMap[userMapOrt];
    if (_userMap.containsKey(userMapPLZ)) plz = _userMap[userMapPLZ];
    if (_userMap.containsKey(userMapSubscribedGroups))
      subscribedGroups = List<String>.from(_userMap[userMapSubscribedGroups]);
    if (_userMap.containsKey(userMapUID)) userID = _userMap[userMapUID];
    if (_userMap.containsKey(userMapPfadiName)) {
      pfadiName = _userMap[userMapPfadiName];
      displayName = pfadiName;
    } else {
      displayName = vorName;
    }
    if (_userMap.containsKey(userMapGeschlecht)) geschlecht = _userMap[userMapGeschlecht];
    if ((pos == userMapLeiter) || (pos == userMapTeilnehmer)) {
      groupMap =
          (await crud0.getDocument(pathGroups, _userMap[userMapgroupID])).data;
      if (groupMap["Priviledge"].containsKey(_userMap[userMapUID]))
        groupPrivilege[groupID] =
            groupMap["Priviledge"][_userMap[userMapUID]]["Priviledge"];
      else
        groupPrivilege[groupID] = 0;
    } else {
      if (_userMap.containsKey(userMapKinder)) {
        Map<String, String> kinderMap =
            Map<String, String>.from(_userMap[userMapKinder]);
        childMap = await createChildMap(kinderMap);
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
      if (!subscribedGroups.contains(childUserDat[userMapgroupID]))
        subscribedGroups.add(childUserDat[userMapgroupID]);
    }
    parentGroupPrivilege(childMap);
    return childMap;
  }

  parentGroupPrivilege(Map<String, Map<String, String>> childMap) {
    for (String groupID in childMap.keys) groupPrivilege[groupID] = 2;
  }

  Map<String, dynamic> generateUserMap() {
    Map<String, dynamic> userMap = new Map();
    userMap[userMapAdresse] = adresse;
    userMap[userMapEmail] = email;
    if (geburtstag != null) userMap[userMapGeburtstag] = geburtstag.toString();
    if (handynummer != null) userMap[userMapHandynummer] = handynummer;
    userMap[userMapNachName] = nachName;
    userMap[userMapOrt] = ort;
    userMap[userMapPLZ] = plz;
    if (pfadiName != null) userMap[userMapPfadiName] = pfadiName;
    userMap[userMapPos] = pos;
    userMap[userMapUID] = userID;
    userMap[userMapVorName] = vorName;
    userMap[userMapAccountCreated] = DateTime.now().toString();
    userMap[userMapGeschlecht] = geschlecht;
    return userMap;
  }

  Future<dynamic> createMoreaUser(
      Auth auth, _password, moreafire, onSignedIn) async {
    try {
      userID = await auth.createUserWithEmailAndPassword(email, _password);
      print('Registered user: $userID');
      if (userID != null) {
        //Creates userMap
        await moreafire.createUserInformation(generateUserMap());
        //writes Devicetoken to collection of groupID
        if (groupID != null) {
          moreafire.subscribeToGroup(groupID);
          //Writes tn rights to groupMap
          await moreafire.groupPriviledgeTN(
              groupID, userID, (pfadiName == ' ' ? vorName : pfadiName));
        }

        //uploads devtoken to userMap
        moreafire.uploadDevTocken(userID);

        //sends user to rootpage
        onSignedIn();
      }
      return userID;
    } catch (e) {
      return e;
    }
  }
}
