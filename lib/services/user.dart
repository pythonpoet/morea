import 'dart:core';
import 'dart:developer';
import 'package:morea/constants/enums.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/Group/group_data.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/group.dart';
import 'package:morea/services/morea_firestore.dart';

String? sessionUserID, sessionUserName;

class User {
  late String displayName,
      vorName,
      nachName,
      pos,
      email,
      adresse,
      geburtstag,
      ort,
      plz,
      geschlecht,
      userID;
  String? pfadiName, handynummer;
  //List<String> subscribedGroups = new List<String>();
  List<String> groupIDs = <String>[];
  Map<String, RoleEntry>? groupPrivilege = new Map();
  Map<String, Map<String, String>>? childMap;
  Map<String, dynamic>? _userMap, groupMap, elternMap;
  CrudMedthods crud0;
  Map<String, GroupData>? subscribedGroups = new Map<String, GroupData>();
  late PriviledgeGroup priviledgeGroup;

  User(this.crud0);

  getTeilnehmer() async {
    if (_userMap!.containsKey(userMapGroupIDs))
      groupIDs = List<String>.from(_userMap![userMapGroupIDs]);
    else
      throw "$userMapGroupIDs has to be non-null";

    if (_userMap!.containsKey(userMapVorName)) {
      vorName = _userMap![userMapVorName];
      sessionUserName = vorName;
    } else
      throw "$userMapVorName has to be non-null";

    if (_userMap!.containsKey(userMapNachName))
      nachName = _userMap![userMapNachName];
    else
      throw "$userMapNachName has to be non-null";

    if (_userMap!.containsKey(userMapEmail))
      email = _userMap![userMapEmail];
    else
      throw "$userMapEmail has to be non-null";

    if (_userMap!.containsKey(userMapAdresse))
      adresse = _userMap![userMapAdresse];
    else
      throw "$userMapAdresse has to be non-null";

    if (_userMap!.containsKey(userMapGeburtstag))
      geburtstag = _userMap![userMapGeburtstag];
    else
      throw "$userMapGeburtstag has to be non-null";

    if (_userMap!.containsKey(userMapOrt))
      ort = _userMap![userMapOrt];
    else
      throw "$userMapOrt has to be non-null";

    if (_userMap!.containsKey(userMapPLZ))
      plz = _userMap![userMapPLZ];
    else
      throw "$userMapPLZ has to be non-null";

    if (_userMap!.containsKey(userMapUID)) {
      userID = _userMap![userMapUID];
      sessionUserID = userID;
    } else
      throw "$userMapUID has to be non-null";

    if (_userMap!.containsKey(userMapGeschlecht))
      geschlecht = _userMap![userMapGeschlecht];
    else
      throw "$userMapGeschlecht has to be non-null";

    if (_userMap!.containsKey(userMapHandynummer))
      handynummer = _userMap![userMapHandynummer];
    //Handynummer can be empty (Because children without a Mobilephone are able to register).

    if (_userMap!.containsKey(userMapPfadiName)) {
      if (_userMap![userMapPfadiName] != '' &&
          _userMap![userMapPfadiName] != null) {
        pfadiName = _userMap![userMapPfadiName];
        displayName = pfadiName!;
      } else {
        displayName = vorName;
      }
    } else {
      displayName = vorName;
    }
    for (String groupID in groupIDs) {
      var someVar = (await crud0.getDocument(
          '$pathGroups/$groupID/$pathPriviledge', this.userID));
      GroupData groupData = new GroupData(
          groupData: (await crud0.getDocument(pathGroups, groupID)).data()!
              as Map<String, dynamic>,
          groupUserData: someVar.data()! as Map<String, dynamic>);

      subscribedGroups![groupID] = groupData;
    }
  }

  getElterData() async {
    if (_userMap!.containsKey(userMapVorName))
      vorName = _userMap![userMapVorName];
    else
      throw "$userMapVorName has to be non-null";

    if (_userMap!.containsKey(userMapNachName))
      nachName = _userMap![userMapNachName];
    else
      throw "$userMapNachName has to be non-null";

    if (_userMap!.containsKey(userMapEmail))
      email = _userMap![userMapEmail];
    else
      throw "$userMapEmail has to be non-null";

    if (_userMap!.containsKey(userMapAdresse))
      adresse = _userMap![userMapAdresse];
    else
      throw "$userMapAdresse has to be non-null";

    if (_userMap!.containsKey(userMapOrt))
      ort = _userMap![userMapOrt];
    else
      throw "$userMapOrt has to be non-null";

    if (_userMap!.containsKey(userMapPLZ))
      plz = _userMap![userMapPLZ];
    else
      throw "$userMapPLZ has to be non-null";

    if (_userMap!.containsKey(userMapUID))
      userID = _userMap![userMapUID];
    else
      throw "$userMapUID has to be non-null";

    if (_userMap!.containsKey(userMapHandynummer))
      handynummer = _userMap![userMapHandynummer];
    else
      throw "$userMapHandynummer has to be non-null";

    if (_userMap!.containsKey(userMapGroupIDs))
      groupIDs = List<String>.from(_userMap![userMapGroupIDs]);
    //groupID can be null (Because parents don't have to be asigned to a group).

    if (_userMap!.containsKey(userMapGeburtstag))
      geburtstag = _userMap![userMapGeburtstag];
    //geburtstag can be null (Because we don't have to know the age of a parent).

    if (_userMap!.containsKey(userMapGeschlecht))
      geschlecht = _userMap![userMapGeschlecht];
    //geschlecht can be null (Becase we don't have to know the sex of a parent)

    if (_userMap!.containsKey(userMapPfadiName)) {
      if (_userMap![userMapPfadiName] != '' &&
          _userMap![userMapPfadiName] != null) {
        pfadiName = _userMap![userMapPfadiName];
        displayName = pfadiName!;
      } else {
        displayName = vorName;
      }
    } else {
      displayName = vorName;
    }
    // Add parents groups to subscribedgroups
    if (this.groupIDs.length > 0) {
      for (String groupID in groupIDs) {
        GroupData groupData = GroupData(
            groupData: (await crud0.getDocument(pathGroups, groupID)).data()!
                as Map<String, dynamic>,
            groupUserData: (await crud0.getDocument(
                    '$pathGroups/$groupID/$pathPriviledge', this.userID))
                .data()! as Map<String, dynamic>);

        subscribedGroups![groupID] = groupData;
      }
    }
    // Add childs groups to subscribedgroups
    if (_userMap!.containsKey(userMapKinder)) {
      Map<String, String> kinderMap =
          Map<String, String>.from(_userMap![userMapKinder]);
      childMap = await createChildMap(kinderMap);
    }
  }

  Future getUserData(Map<String, dynamic> userMap) async {
    _userMap = userMap;
    if (!_userMap!.containsKey(userMapPos))
      throw "$userMapPos has to be non-null";
    pos = _userMap![userMapPos];
    switch (_userMap![userMapPos]) {
      case roleTN:
        await getTeilnehmer();
        this.priviledgeGroup = PriviledgeGroup.TN;
        break;
      case roleErziehungsperson:
        await getElterData();
        this.priviledgeGroup = PriviledgeGroup.Erziehungsperson;
        break;
      case roleLeitung:
        await getElterData();
        this.priviledgeGroup = PriviledgeGroup.Leitung;
        break;
      case roleStaLei:
        await getElterData();
        this.priviledgeGroup = PriviledgeGroup.StaLei;
        break;
      case roleAL:
        await getElterData();
        this.priviledgeGroup = PriviledgeGroup.AL;
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
          (await crud0.getDocument(pathUser, childUID)).data()!
              as Map<String, dynamic>;
      print(childUserDat);

      for (String groupID in childUserDat[userMapGroupIDs]) {
        if (childMap.containsKey(groupID))
          childMap[groupID]![childUID] = childs[childUID]!;
        else
          childMap[groupID] = {childUID: childs[childUID]!};
      }
    }
    await parentGroupPrivilege(childMap);
    return childMap;
  }

  parentGroupPrivilege(Map<String, Map<String, String>> childMap) async {
    for (String groupID in childMap.keys) {
      GroupData groupData = GroupData(
          groupData: (await crud0.getDocument(pathGroups, groupID)).data()!
              as Map<String, dynamic>);
      if (groupData.groupOption!.parentialControl.enabled!) {
        if (!this.groupIDs!.contains(groupID)) this.groupIDs!.add(groupID);
        groupData.setParentPriviledge(this._userMap!['displayName']);
        this.subscribedGroups![groupID] = groupData;
      }
    }
  }

  Map<String, dynamic> generateAndValitateUserMap() {
    Map<String, dynamic> userMap = new Map();
    if (adresse != null)
      userMap[userMapAdresse] = adresse;
    else
      print('adresse error');

    if (email != null)
      userMap[userMapEmail] = email;
    else
      log("$userMapEmail has to be non-null");

    if (vorName != null)
      userMap[userMapVorName] = vorName;
    else
      print('vorname error');

    if (nachName != null)
      userMap[userMapNachName] = nachName;
    else
      print('nachname error');

    if (userID != null)
      userMap[userMapUID] = userID;
    else
      log("$userMapUID has to be non-null");

    if (ort != null)
      userMap[userMapOrt] = ort;
    else
      print('ort error');

    if (plz != null)
      userMap[userMapPLZ] = plz;
    else
      print('plz error');

    if (pos != null)
      userMap[userMapPos] = pos;
    else
      print('pos error');

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

        if (groupIDs != null)
          userMap[userMapGroupIDs] = groupIDs;
        else
          throw "$userMapGroupIDs has to be non-null";

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
          print('handynummer error');

        if (geschlecht != null)
          userMap[userMapGeschlecht] = geschlecht;
        else
          print('geschlecht error');
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
      Auth auth, String _password, MoreaFirebase moreafire, onSignedIn,
      {bool tutorial = true}) async {
    try {
      userID = await auth.createUserWithEmailAndPassword(email!, _password);
      print('Registered user: $userID');
      if (userID != null) {
        //Creates userMap
        await moreafire.createUserInformation(generateAndValitateUserMap());
        //writes Devicetoken to collection of groupID
        if (groupIDs != null) {
          //Writes tn rights to groupMap
          for (String groupID in groupIDs!) {
            await moreafire.groupPriviledgeTN(
                groupID,
                userID!,
                (pfadiName == '' ? vorName! : pfadiName!),
                generateAndValitateUserMap());
          }
        }

        //uploads devtoken to userMap
        await moreafire.uploadDevTocken(userID!);

        //sends user to rootpage
        if (tutorial) {
          onSignedIn(tutorialautostart: true);
        } else {
          onSignedIn();
        }
      }
      return userID;
    } catch (e) {
      throw e;
    }
  }

  //Sets variable priviledgeGroup to change the local priviledge group for example, when switching the account priviledge from TN to Leitung
  void setUserPriviledgeGroup(PriviledgeGroup newPriviledgeGroup) {
    this.priviledgeGroup = newPriviledgeGroup;
  }
}
