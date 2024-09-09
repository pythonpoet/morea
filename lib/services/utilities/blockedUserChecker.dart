import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/Pages/Grundbausteine/root_page.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/group.dart';

//First Document pulled from Firebase
Map<String, RoleEntry> globalConfigRoles = Map<String, RoleEntry>();

Future<AuthStatus> check4BlockedAuthStatus(
    String? userID, FirebaseFirestore firestore) async {
  Map<String, dynamic>? init = (await FirebaseFirestore.instance
          .collection(pathConfig)
          .doc(pathInit)
          .get())
      .data();
  print(init.runtimeType);
  if (init == null) {
    throw "No init doc exists";
  } else {
    if (!init.containsKey(configMapBlockedDevToken))
      throw "create $configMapBlockedDevToken in config --> init";
    List<String> blockedDevTokens =
        new List.from(init[configMapBlockedDevToken]);
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    if (!init.containsKey(configMapMinAppVerson))
      throw "create $configMapMinAppVerson in config --> init";
    if (int.parse(init[configMapMinAppVerson]) > int.parse(appVersion))
      return AuthStatus.blockedByAppVersion;
    if (blockedDevTokens.contains(firebaseMessaging.getToken()))
      return AuthStatus.blockedByDevToken;
    return userID == null ? AuthStatus.notSignedIn : AuthStatus.loading;
  }
}

Map<String, RoleEntry> initGetGroupConfigRoles({Map<String, dynamic>? data}) {
  if (data != null) {
    if (data.containsKey(groupMapRoles))
      for (String key in Map<String, dynamic>.from(data[groupMapRoles]).keys)
        globalConfigRoles[key] = RoleEntry(
            data: Map<String, dynamic>.from(data[groupMapRoles][key]));
    else
      throw "$groupMapRoles can't be empty";
  }
  return globalConfigRoles;
}
