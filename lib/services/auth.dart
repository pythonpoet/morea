import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> signOut();
  Future<void> createUserInformation(Map userInfo);
  Future<DocumentSnapshot> getUserInformation();
  Future<void> uebunganmelden(Map anmeldedaten);
}
class Auth implements BaseAuth {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signInWithEmailAndPassword(String email, String password)async{
    FirebaseUser user = await  _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = await  _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }
  Future<void> createUserInformation(Map userInfo) async {
    String userUID =  await currentUser();
    Firestore.instance.collection('user').document(userUID).setData(userInfo).catchError((e){
      print(e);
    });
  }
  Future<void> uebunganmelden(Map anmeldedaten) async {
    Firestore.instance.collection('uebung').document('uebung1').setData(anmeldedaten).catchError((e){
      print(e);
    });
  }
  Future<DocumentSnapshot> getUserInformation() async {
    String userUID =  await currentUser();
    return await Firestore.instance.collection('user').document(userUID).get();
  }

  Future<String> currentUser() async {
    FirebaseUser user = await  _firebaseAuth.currentUser();
    return user.uid;
  }

  Future<void> signOut() async {
    return  _firebaseAuth.signOut();
  }
}
