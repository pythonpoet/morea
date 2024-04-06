import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/cloud_functions.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';

abstract class BaseChildParendPend {
  Future<String> childGenerateRequestString(Map<String, dynamic> userMap);
}

class ChildParendPend extends BaseChildParendPend {
  CrudMedthods crud0;
  MoreaFirebase moreaFirebase;

  ChildParendPend({required this.crud0, required this.moreaFirebase});

  Future<String> childGenerateRequestString(
      Map<String, dynamic> userMap) async {
    var someData = (await callFunction(getcallable("childPendRequest"),
            param: Map<String, dynamic>.from({
              userMapPos: userMap[userMapPos],
              userMapUID: userMap[userMapUID],
              userMapGroupIDs: userMap[userMapGroupIDs],
              mapTimestamp: DateTime.now().toIso8601String()
            })))
        .data;
    return someData.toString();
  }

  Future<bool> waitOnUserDataChange(String userID) async {
    return await crud0.waitOnDocumentChanged(pathUser, userID);
  }

  Future<void> deleteRequest(String request) async {
    return await crud0.deletedocument(pathRequest, request);
  }

  Future<void> parentSendsRequestString(
      String requestStr, Map<String, dynamic> userMap) async {
    callFunction(getcallable("parendPendAccept"),
        param: Map.from({
          userMapPos: userMap[userMapPos],
          userMapUID: userMap[userMapUID],
          pathRequest: requestStr,
          mapTimestamp: DateTime.now().toIso8601String()
        }));
    return null;
  }

  Future<String> parentCreatesUser(String _email, String _password) async {
    return (await callFunction(getcallable("createAccount"),
            param: Map.from({"email": _email, "password": _password})))
        .data;
  }

  Future<void> createChildAndPendIt(
      String _childEmail,
      String _childPasswort,
      Map<String, dynamic> childData,
      Map<String, dynamic> parentData,
      BuildContext context) async {
    Auth childAuth = new Auth();
    try {
      String childUID =
          await this.parentCreatesUser(_childEmail, _childPasswort);
      childData[userMapUID] = childUID;
      await crud0.setData(pathUser, childUID, childData);
      (childData[userMapGroupIDs] as List<String>).forEach((groupID) {
        moreaFirebase.groupPriviledgeTN(
            groupID,
            childUID,
            (childData[userMapPfadiName] == ' '
                ? childData[userMapVorName]
                : childData[userMapPfadiName]),
            childData);
      });
      moreaFirebase.subscribeToGroup(childData[userMapGroupIDs]);
      String requestStr = await this.childGenerateRequestString(childData);
      return parentSendsRequestString(requestStr, parentData);
    } catch (error) {
      AuthProblems problem =
          childAuth.checkForAuthErrors(context, error as PlatformException);
      childAuth.displayAuthError(problem, context);
      return null;
    }
  }
}
