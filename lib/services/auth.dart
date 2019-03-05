import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<void> signOut();
  Future<void> createUserInformation(Map userInfo);
  Future<DocumentSnapshot> getUserInformation();
  Future<String> uebunganmelden(Map anmeldedaten, String stufe, String _userUID);
  Future<Map> getteleblitz(_stufe);
  Future<String> ubloadteleblitz(_stufe,data );
}
class Auth implements BaseAuth {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String getuebungsdatum(){
    var now = new DateTime.now();
    var formatter = new DateFormat('E');
    var formatter2 = new DateFormat('dd');
    String formatted = formatter.format(now);
    String formatted2 = formatter2.format(now);
    int date = int.parse(formatted2);
    switch (formatted) {
      case 'Sun':
        date += 6;
        break;
      case 'Mon':
        date += 5;
        break;
      case 'Tue':
        date += 4;
        break;
      case 'Wed':
        date += 3;
        break;
      case 'Thu':
        date += 2;
        break;
      case 'Fri':
        date += 1;
        break;
    }
        String akdate;
        akdate = date.toString();
        var fixdate = new DateFormat('yyyy-MM');
        String fixdateformatted = fixdate.format(now);
        return fixdateformatted + '-' + akdate;
  }

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
  Future<String> uebunganmelden(Map anmeldedaten, String stufe, String _userUID) async {
    String uebungsdatum = getuebungsdatum();
    Firestore.instance.collection('uebung').document(stufe).collection(uebungsdatum).document(_userUID).setData(anmeldedaten).catchError((e){
        print(e);
    });
  }
  Future<Map> getteleblitz(_stufe) async {
    String uebungsdatum = getuebungsdatum();
    await Firestore.instance.collection('Teleblitz').document(_stufe).collection(uebungsdatum).document('spacer').get().then((results){
      if(results.exists){
        return results.data;
      }else{
        return null;
      }
    });
  }
  Future<String> ubloadteleblitz(_stufe,data ) async {
    String uebungsdatum = getuebungsdatum();
    Firestore.instance.collection('Teleblitz').document(_stufe).collection(uebungsdatum).document('spacer').setData(data).catchError((e){
      print(e);
    });
  }
  Future<DocumentSnapshot> getUserInformation() async {
    String userUID =  await currentUser();
    return await Firestore.instance.collection('user').document(userUID).get();
  }
  Future<DocumentSnapshot> getTNs(String stufe)async{
    String uebungsdatum = getuebungsdatum();
    var document = await Firestore.instance.document('user/${stufe}/${uebungsdatum}');
    document.get();
    print(document);

    return await Firestore.instance.collection(stufe).document(uebungsdatum).get();
  }

  Future<String> currentUser() async {
    FirebaseUser user = await  _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return  _firebaseAuth.signOut();
  }
}
