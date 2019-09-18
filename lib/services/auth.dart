import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:morea/services/Getteleblitz.dart';
import 'dwi_core.dart';

//enum PlatformType { isAndroid, isIOS }
enum AuthProblems {
  userNotFound,
  passwordNotValid,
  networkError,
  undefinedError
}

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);

  Future<String> createUserWithEmailAndPassword(String email, String password);

  Future<void> sendPasswordResetEmail(String email);

  Future<String> currentUser();

  Future<void> signOut();

  AuthProblems checkForAuthErrors(
      BuildContext context, PlatformException error);

  Future<void> displayAuthError(AuthProblems errorType, BuildContext context);

  Future<void> changePassword(String newPassword);

  Future<void> reauthenticate(String email, String password);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Info teleblitzinfo = new Info();
  DWICore dwiHardware = new DWICore();

  Future<String> signInWithEmailAndPassword(String email, String password)async{
    FirebaseUser user = (await  _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).catchError((onError){
      print(onError);
    })).user;
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = (await  _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).catchError((onError){
      print(onError);
    })).user;
    return user.uid;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> createUserInformation(Map userInfo) async {
    String userUID = await currentUser();
    await Firestore.instance
        .collection('user')
        .document(userUID)
        .setData(userInfo)
        .catchError((e) {
      print(e);
    });
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<String> userEmail() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.email : null;
  }

  Future<void> changePassword(String newPassword) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.updatePassword(newPassword);
    return null;
  }

  Future<void> reauthenticate(String email, String password) async {
    AuthCredential credential =
        EmailAuthProvider.getCredential(email: email, password: password);
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.reauthenticateWithCredential(credential).then((onValue) {
      return null;
    }).catchError((e) {
      print(e);
      return null;
    });
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  AuthProblems checkForAuthErrors(
      BuildContext context, PlatformException error) {
    PlatformType platform = dwiHardware.getDevicePlatform();
    AuthProblems errorType;
    if (platform == PlatformType.isAndroid) {
      switch (error.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorType = AuthProblems.userNotFound;
          break;
        case 'The password is invalid or the user does not have a password.':
          errorType = AuthProblems.passwordNotValid;
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          errorType = AuthProblems.networkError;
          break;

        default:
          errorType = AuthProblems.undefinedError;
          print('Case ${error.message} is not jet implemented');
      }
    } else if (platform == PlatformType.isIOS) {
      switch (error.code) {
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
    }
    return errorType;
  }

  Future<void> displayAuthError(AuthProblems errorType, BuildContext context) {
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
        errorMessage = 'Etwas ist schief gelaufen';
        break;
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
                        child: RaisedButton(
                            child: new Text(
                              'Ok',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Color(0xff7a62ff),
                            onPressed: () => {Navigator.pop(context)}),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
