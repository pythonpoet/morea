import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:morea/services/Getteleblitz.dart';

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<String> currentUser();
  Future<void> signOut();
  /*String checkForErrors(Error e){

  }*/
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Info teleblitzinfo =  new Info();

  Future<String> signInWithEmailAndPassword(String email, String password)async{
    FirebaseUser user = await  _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }
  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = await  _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }
  Future<void> sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
  Future<void> createUserInformation(Map userInfo) async {
    String userUID =  await currentUser();
    await Firestore.instance.collection('user').document(userUID).setData(userInfo).catchError((e){
      print(e);
    });
  }
  Future<String> currentUser() async {
    FirebaseUser user = await  _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }
  Future<String> userEmail() async {
    FirebaseUser user = await  _firebaseAuth.currentUser();
    return user != null ? user.email : null;
  }
  Future<void> signOut() async {
    return  _firebaseAuth.signOut();
  }
}
