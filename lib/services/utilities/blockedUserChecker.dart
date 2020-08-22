import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/Pages/Grundbausteine/root_page.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/Group/group_data.dart';

//First Document pulled from Firebase
Map<String, PriviledgeEntry> globalConfigRoles;

Future<AuthStatus> check4BlockedAuthStatus(
    String userID, Firestore firestore) async {
  Map<String, dynamic> init =
      (await Firestore.instance.collection(pathConfig).document(pathInit).get())
          .data;
  List<String> blockedDevTokens = new List.from(init[configMapBlockedDevToken]);
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  

    if (int.parse(init[configMapMinAppVerson]) > int.parse(appVersion))
      return AuthStatus.blockedByAppVersion;
    if (blockedDevTokens.contains(firebaseMessaging.getToken()))
      return AuthStatus.blockedByDevToken;
    return userID == null ? AuthStatus.notSignedIn : AuthStatus.loading;
}
Map<String, PriviledgeEntry> initGetGroupConfigRoles({Map<String,dynamic> data}){
  if(data != null){
    if(data.containsKey(groupMapRoles))
        globalConfigRoles = (data[groupMapRoles] as Map<String,dynamic>).map(
          (key, value) => MapEntry(key, PriviledgeEntry().read(value)));
    else
      throw "$groupMapRoles can't be empty";
  }
  return globalConfigRoles;
}
