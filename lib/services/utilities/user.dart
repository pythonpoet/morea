import 'dart:developer';

import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';

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
  Map<String, dynamic> _userMap, groupMap, elternMap;
  CrudMedthods crud0;

  User(this.crud0);

  getTeilnehmer() async {
    if (_userMap.containsKey(userMapgroupID))
      groupID = _userMap[userMapgroupID];
    else
      throw "$userMapgroupID has to be non-null";

    if (_userMap.containsKey(userMapVorName))
      vorName = _userMap[userMapVorName];
    else
      throw "$userMapVorName has to be non-null";

    if (_userMap.containsKey(userMapNachName))
      nachName = _userMap[userMapNachName];
    else
      throw "$userMapNachName has to be non-null";

    if (_userMap.containsKey(userMapEmail))
      email = _userMap[userMapEmail];
    else
      throw "$userMapEmail has to be non-null";

    if (_userMap.containsKey(userMapAdresse))
      adresse = _userMap[userMapAdresse];
    else
      throw "$userMapAdresse has to be non-null";

    if (_userMap.containsKey(userMapGeburtstag))
      geburtstag = _userMap[userMapGeburtstag];
    else
      throw "$userMapGeburtstag has to be non-null";

    if (_userMap.containsKey(userMapOrt))
      ort = _userMap[userMapOrt];
    else
      throw "$userMapOrt has to be non-null";

    if (_userMap.containsKey(userMapPLZ))
      plz = _userMap[userMapPLZ];
    else
      throw "$userMapPLZ has to be non-null";

    if (_userMap.containsKey(userMapUID))
      userID = _userMap[userMapUID];
    else
      throw "$userMapUID has to be non-null";

    if (_userMap.containsKey(userMapGeschlecht))
      geschlecht = _userMap[userMapGeschlecht];
    else
      throw "$userMapGeschlecht has to be non-null";

    if (_userMap.containsKey(userMapHandynummer))
      handynummer = _userMap[userMapHandynummer];
    //Handynummer can be empty (Because children without a Mobilephone are able to register).

    if (_userMap.containsKey(userMapSubscribedGroups))
      subscribedGroups = List<String>.from(_userMap[userMapSubscribedGroups]);
    //SubscribedGroups can be empty (Because Children are asigned to a single group by default).

    if (_userMap.containsKey(userMapPfadiName)) {
      pfadiName = _userMap[userMapPfadiName];
      displayName = pfadiName;
    } else {
      displayName = vorName;
    }
    groupMap =
        (await crud0.getDocument(pathGroups, _userMap[userMapgroupID])).data;
    if (groupMap["Priviledge"].containsKey(_userMap[userMapUID]))
      groupPrivilege[groupID] =
          groupMap["Priviledge"][_userMap[userMapUID]]["Priviledge"];
    else
      groupPrivilege[groupID] = 0;
  }

  getElterData() async {
    if (_userMap.containsKey(userMapVorName))
      vorName = _userMap[userMapVorName];
    else
      throw "$userMapVorName has to be non-null";

    if (_userMap.containsKey(userMapNachName))
      nachName = _userMap[userMapNachName];
    else
      throw "$userMapNachName has to be non-null";

    if (_userMap.containsKey(userMapEmail))
      email = _userMap[userMapEmail];
    else
      throw "$userMapEmail has to be non-null";

    if (_userMap.containsKey(userMapAdresse))
      adresse = _userMap[userMapAdresse];
    else
      throw "$userMapAdresse has to be non-null";

    if (_userMap.containsKey(userMapOrt))
      ort = _userMap[userMapOrt];
    else
      throw "$userMapOrt has to be non-null";

    if (_userMap.containsKey(userMapPLZ))
      plz = _userMap[userMapPLZ];
    else
      throw "$userMapPLZ has to be non-null";

    if (_userMap.containsKey(userMapUID))
      userID = _userMap[userMapUID];
    else
      throw "$userMapUID has to be non-null";

    if (_userMap.containsKey(userMapHandynummer))
      handynummer = _userMap[userMapHandynummer];
    else
      throw "$userMapHandynummer has to be non-null";

    if (_userMap.containsKey(userMapSubscribedGroups))
      subscribedGroups = List<String>.from(_userMap[userMapSubscribedGroups]);
    //Subscribedgroup can be null (Because parents are not initialized with their children).

    if (_userMap.containsKey(userMapgroupID))
      groupID = _userMap[userMapgroupID];
    //groupID can be null (Because parents don't have to be asigned to a group).

    if (_userMap.containsKey(userMapGeburtstag))
      geburtstag = _userMap[userMapGeburtstag];
    //geburtstag can be null (Because we don't have to know the age of a parent).

    if (_userMap.containsKey(userMapGeschlecht))
      geschlecht = _userMap[userMapGeschlecht];
    //geschlecht can be null (Becase we don't have to know the sex of a parent)

    if (_userMap.containsKey(userMapPfadiName)) {
      pfadiName = _userMap[userMapPfadiName];
      displayName = pfadiName;
    } else {
      displayName = vorName;
    }

    if (_userMap.containsKey(userMapKinder)) {
      Map<String, String> kinderMap =
          Map<String, String>.from(_userMap[userMapKinder]);
      childMap = await createChildMap(kinderMap);
    }
    if (_userMap[userMapgroupID] == null) {
      groupMap = null;
    } else {
      groupMap =
          (await crud0.getDocument(pathGroups, _userMap[userMapgroupID])).data;
      if (groupMap["Priviledge"].containsKey(_userMap[userMapUID]))
        groupPrivilege[groupID] =
            groupMap["Priviledge"][_userMap[userMapUID]]["Priviledge"];
      else
        groupPrivilege[groupID] = 0;
    }
  }

  Future getUserData(Map<String, dynamic> userMap) async {
    _userMap = userMap;
    if (!_userMap.containsKey(userMapPos))
      throw "$userMapPos has to be non-null";
    pos = _userMap[userMapPos];
    switch (pos) {
      case "Teilnehmer":
        await getTeilnehmer();
        break;
      case "Mutter":
        await getElterData();
        break;
      case "Vater":
        await getElterData();
        break;
      case "Erziehungsberechtigter":
        await getElterData();
        break;
      case "Erziehungsberechtigte":
        await getElterData();
        break;
      case "Leiter":
        await getElterData();
        break;
      default:
        throw "UserMap-pos value: $pos is not implemented";
    }
  }

  Future<Map<String, Map<String, String>>> createChildMap(
      Map<String, String> childs) async {
    Map<String, Map<String, String>> childMap = new Map();
    for (String childUID in childs.keys) {
      Map<String, dynamic> childUserDat =
          (await crud0.getDocument(pathUser, childUID)).data;
      if (childMap.containsKey(childUserDat[userMapgroupID]))
        childMap[childUserDat[userMapgroupID]][childUID] = childs[childUID];
      else
        childMap[childUserDat[userMapgroupID]] = {childUID: childs[childUID]};
      if (!subscribedGroups.contains(childUserDat[userMapgroupID]))
        subscribedGroups.add(childUserDat[userMapgroupID]);
    }
    parentGroupPrivilege(childMap);
    return childMap;
  }

  parentGroupPrivilege(Map<String, Map<String, String>> childMap) {
    for (String groupID in childMap.keys) groupPrivilege[groupID] = 2;
  }

  Map<String, dynamic> generateAndValitateUserMap() {
    Map<String, dynamic> userMap = new Map();
    if (adresse != null)
      userMap[userMapAdresse] = adresse;
    else
      throw "$userMapAdresse can't be null";

    if (email != null)
      userMap[userMapEmail] = email;
    else
      log("$userMapEmail has to be non-null");

    if (vorName != null)
      userMap[userMapVorName] = vorName;
    else
      throw "$userMapVorName has to be non-null";

    if (nachName != null)
      userMap[userMapNachName] = nachName;
    else
      throw "$userMapNachName has to be non-null";

    if (userID != null)
      userMap[userMapUID] = userID;
    else
      log("$userMapUID has to be non-null");

    if (ort != null)
      userMap[userMapOrt] = ort;
    else
      throw "$userMapOrt has to be non-null";

    if (plz != null)
      userMap[userMapPLZ] = plz;
    else
      throw "$userMapPLZ has to be non-null";

    if (pos != null)
      userMap[userMapPos] = pos;
    else
      throw "$userMapPos has to be non-null";

    switch (pos) {
      case "Teilnehmer":
        if (geburtstag != null)
          userMap[userMapGeburtstag] = geburtstag.toString();
        else
          throw "$userMapGeburtstag has to be non-null";

        if (geschlecht != null)
          userMap[userMapGeschlecht] = geschlecht;
        else
          throw "$userMapGeschlecht has to be non-null";

        if (groupID != null)
          userMap[userMapgroupID] = groupID;
        else
          throw "$userMapgroupID has to be non-null";

        if (pfadiName != null) userMap[userMapPfadiName] = pfadiName;
        //Pfadiname can be empty

        if (handynummer != null) userMap[userMapHandynummer] = handynummer;

        if (elternMap != null) userMap[userMapEltern] = elternMap;
        //Handynummer can be empty
        break;
      case "Mutter":
        if (handynummer != null)
          userMap[userMapHandynummer] = handynummer;
        else
          throw "$userMapHandynummer has to be non-null";

        if (geschlecht != null)
          userMap[userMapGeschlecht] = geschlecht;
        else
          throw "$userMapGeschlecht has to be non-null";
        break;
      case "Vater":
        if (handynummer != null)
          userMap[userMapHandynummer] = handynummer;
        else
          throw "$userMapHandynummer has to be non-null";

        if (geschlecht != null)
          userMap[userMapGeschlecht] = geschlecht;
        else
          throw "$userMapGeschlecht has to be non-null";
        break;
      case "Erziehungsberechtigter":
        if (handynummer != null)
          userMap[userMapHandynummer] = handynummer;
        else
          throw "$userMapHandynummer has to be non-null";

        if (geschlecht != null)
          userMap[userMapGeschlecht] = geschlecht;
        else
          throw "$userMapGeschlecht has to be non-null";
        break;
      case "Erziehungsberechtigte":
        if (handynummer != null)
          userMap[userMapHandynummer] = handynummer;
        else
          throw "$userMapHandynummer has to be non-null";

        if (geschlecht != null)
          userMap[userMapGeschlecht] = geschlecht;
        else
          throw "$userMapGeschlecht has to be non-null";
        break;
      default:
        throw "UserMap-pos value: $pos is not implemented";
    }

    userMap[userMapAccountCreated] = DateTime.now().toString();
    return userMap;
  }

  Future<dynamic> createMoreaUser(
      Auth auth, String _password, MoreaFirebase moreafire, onSignedIn) async {
    try {
      userID = await auth.createUserWithEmailAndPassword(email, _password);
      print('Registered user: $userID');
      if (userID != null) {
        //Creates userMap
        await moreafire.createUserInformation(generateAndValitateUserMap());
        //writes Devicetoken to collection of groupID
        if (groupID != null) {
          moreafire.subscribeToGroup(groupID);
          //Writes tn rights to groupMap
          await moreafire.groupPriviledgeTN(
              groupID, userID, (pfadiName == '' ? vorName : pfadiName));
        }

        //uploads devtoken to userMap
        moreafire.uploadDevTocken(userID);

        //sends user to rootpage
        onSignedIn();
      }
      return userID;
    } catch (e) {
      throw e;
    }
  }
}
