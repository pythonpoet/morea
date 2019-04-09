import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:morea/services/Getteleblitz.dart';

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);

  Future<String> createUserWithEmailAndPassword(String email, String password);

  Future<void> sendPasswordResetEmail(String email);

  Future<String> currentUser();

  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Info teleblitzinfo = new Info();

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
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Stream<QuerySnapshot> getAgenda(stufe) {
    return Firestore.instance
        .collection('Stufen')
        .document(stufe)
        .collection('Agenda')
        .snapshots();
  }

  Future uploadtoAgenda(stufe, name, data) async {
    stufe = formatstring(stufe);
    name = formatstring(name);
    await Firestore.instance
        .collection('Stufen')
        .document(stufe)
        .collection('Agenda')
        .document(name)
        .setData(data)
        .catchError((e) {
      print(e);
    });
  }

  Future deletedocument(String path, String document) async {
    document = formatstring(document);
    await Firestore.instance
        .collection(path)
        .document(document)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> uploaddevtocken(stufe, token, userUID) async {
    stufe = formatstring(stufe);
    Map<String, String> tokendata = {'devtoken': token, 'UID': userUID};
    await Firestore.instance
        .collection('Stufen')
        .document(stufe)
        .collection('Devices')
        .document(token.toString())
        .setData(tokendata)
        .catchError((e) {
      print(e);
    });
  }

  Stream<QuerySnapshot> getChildren() {
    return Firestore.instance.collection('user').snapshots();
  }

  Stream<DocumentSnapshot> getPendingParents(childuid){
    return Firestore.instance.collection('user').document(childuid).snapshots();
  }

  Future<void> pendParent(childuid, parent, parentuid) async {
    var old =
        await Firestore.instance.collection('user').document(childuid).get();
    Map<String, dynamic> parentMap = {};

    for (var u in old.data['Eltern-pending'].keys) {
      parentMap[u] = old[u];
    }
    if (parentMap[parent] == null) {
      parentMap[parent] = parentuid;
      await Firestore.instance
          .collection('user')
          .document(childuid)
          .updateData({'Eltern-pending': parentMap});
    }
  }

  Future<void> setChildToParent(parentuid, childname, childuid) async {
    var old =
        await Firestore.instance.collection('user').document(parentuid).get();
    Map<dynamic, dynamic> childmap = {};

    for (var u in old.data['Kinder'].keys) {
      childmap[u] = old[u];
    }
    childmap[childname] = childuid;
    await Firestore.instance
        .collection('user')
        .document(parentuid)
        .updateData({'Kinder': childmap});
  }
}
