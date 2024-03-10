import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morea/morea_strings.dart';
import 'dart:async';
import 'package:morea/services/utilities/dwi_core.dart';

import '../morealayout.dart';

//enum PlatformType { isAndroid, isIOS }
enum AuthProblems {
  userNotFound,
  passwordNotValid,
  networkError,
  undefinedError,
  emailNotValid,
  emalAlreadyinUse
}

abstract class BaseAuth {
  String get getUserID;

  String get getUserEmail;

  Future<String> signInWithEmailAndPassword(String email, String password);

  Future<String> createUserWithEmailAndPassword(String email, String password);

  Future<void> sendPasswordResetEmail(String email);

  Future<String> currentUser();

  Future<void> signOut();

  AuthProblems checkForAuthErrors(
      BuildContext context, PlatformException error);

  void displayAuthError(AuthProblems errorType, BuildContext context);

  Future<void> changePassword(String newPassword);

  Future<bool> reauthenticate(String email, String password);

  Future<void> changeEmail(String email);

  Future<void> createUserWithEmailAndPasswordForChild(
      String email, String passowrd);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  DWICore dwiHardware = new DWICore();
  firebase.User _user;

  String get getUserID => _user != null ? _user.uid : "not loaded";

  String get getUserEmail => _user != null ? _user.email : "nod loaded";

  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    this._user = (await _firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password)
            .catchError((onError) {
      throw onError;
    }))
        .user;
    return _user.uid;
  }

  Future<String> createUserWithEmailAndPasswordForChild(
      String email, String password) async {
    firebase.User childUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password))
        .user;
    return childUser.uid;
  }

  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    this._user = (await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    return this._user.uid;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> createUserInformation(Map userInfo) async {
    await FirebaseFirestore.instance
        .collection(pathUser)
        .doc(_user.uid)
        .set(userInfo)
        .catchError((e) {
      print(e);
    });
  }

  Future<String> currentUser() async {
    this._user = _firebaseAuth.currentUser;
    return _user != null ? _user.uid : null;
  }

  Future<String> userEmail() async {
    this._user = _firebaseAuth.currentUser;
    return _user != null ? _user.email : null;
  }

  Future<void> deleteUserID() async {
    FirebaseAuth.instance.currentUser.delete();
  }

  Future<bool> reauthenticate(String email, String password) async {
    bool reAuthenticated;
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    print('got Credential');
    print(email);
    firebase.User user = _firebaseAuth.currentUser;
    print('got current user');
    var result = await user.reauthenticateWithCredential(credential);
    if (result.user == null) {
      print(false);
      reAuthenticated = false;
    } else {
      print(true);
      reAuthenticated = true;
    }
    print('reauthenticated');
    return reAuthenticated;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    return null;
  }

  AuthProblems checkForAuthErrors(
      BuildContext context, PlatformException? error) {
    PlatformType platform = dwiHardware.getDevicePlatform();
    AuthProblems errorType;
    if (platform == PlatformType.isAndroid) {
      switch (error!.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorType = AuthProblems.userNotFound;
          break;
        case 'The password is invalid or the user does not have a password.':
          errorType = AuthProblems.passwordNotValid;
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          errorType = AuthProblems.networkError;
          break;
        case "The email address is badly formatted.":
          errorType = AuthProblems.emailNotValid;
          break;
        case "The email address is already in use by another account.":
          errorType = AuthProblems.emalAlreadyinUse;
          break;

        default:
          errorType = AuthProblems.undefinedError;
          print('Case ${error.message} is not jet implemented');
          break;
      }
    } else if (platform == PlatformType.isIOS) {
      switch (error!.code) {
        case 'Error 17011':
          errorType = AuthProblems.userNotFound;
          break;
        case 'Error 17009':
          errorType = AuthProblems.passwordNotValid;
          break;
        case 'Error 17020':
          errorType = AuthProblems.networkError;
          break;
        // ...
        default:
          errorType = AuthProblems.undefinedError;
          print('Case ${error.message} is not jet implemented');
      }
    } else {
      errorType = AuthProblems.undefinedError;
    }
    return errorType;
  }

  void displayAuthError(AuthProblems errorType, BuildContext context) {
    String errorMessage;
    switch (errorType) {
      case AuthProblems.userNotFound:
        errorMessage = 'Du bist noch nicht registriert';
        break;
      case AuthProblems.passwordNotValid:
        errorMessage = 'Das eingegebene Passwort ist nicht korrekt';
        break;
      case AuthProblems.networkError:
        errorMessage = 'Du brauchst Internet um fortzufahren';
        break;
      case AuthProblems.undefinedError:
        errorMessage =
            'Etwas ist hat nicht funktioniert, bitte kontaktiere ein Leiter';
        break;
      case AuthProblems.emailNotValid:
        errorMessage = "Die eingegebene Email Adresse ist nicht korrekt";
        break;
      case AuthProblems.emalAlreadyinUse:
        errorMessage = "Die eingegebene Email wird bereits verwendet";
    }

    showDialog(
        context: context,
        builder: (BuildContext context) => new Container(
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 100, bottom: 200),
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 50,
                          ),
                          new Text(' Fehler',
                              style: TextStyle(
                                  fontSize: 45, fontWeight: FontWeight.bold)),
                        ],
                      )),
                      new Divider(),
                      Container(
                        child: Center(
                          child: Text(errorMessage,
                              style: TextStyle(fontSize: 25)),
                        ),
                      ),
                      new Divider(),
                      Container(
                        child: ElevatedButton(
                            child: new Text(
                              'Ok',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        MoreaColors.violett)),
                            onPressed: () => {Navigator.pop(context)}),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }

  Future<void> changeEmail(String email) async {
    firebase.User user = _firebaseAuth.currentUser;
    await user.reload();
    await user.updateEmail(email);
    return null;
  }

  Future<void> changePassword(String password) async {
    firebase.User user = _firebaseAuth.currentUser;
    await user.reload();
    await user.updatePassword(password);
    return null;
  }
}
