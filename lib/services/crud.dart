import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/services/utilities/dwi_format.dart';
import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class BaseCrudMethods {
  Future<QuerySnapshot> getCollection(String path);

  Stream<QuerySnapshot> streamCollection(String path);

  Stream<QuerySnapshot> streamOrderCollection(String path, String order);

  Future<DocumentSnapshot> getDocument(String path, String document);

  Stream<DocumentSnapshot> streamDocument(String path, String document);

  Future<bool> waitOnDocumentChanged(String path, String document);

  Future<void> setData(String path, String document, Map<String, dynamic> data);

  Future<void> runTransaction(
      String path, String document, Map<String, dynamic> data);

  Future deletedocument(String path, String document);

  Future<void> setDataWithoutDocumentName(
      String path, Map<dynamic, dynamic> data);

  Future<DocumentSnapshot> getMessage(String path, String document);
}

class CrudMedthods implements BaseCrudMethods {
  DWIFormat dwiformat = new DWIFormat();
  Firestore db;

  CrudMedthods(Firestore firestore) {
    this.db = firestore;
  }

  Future<QuerySnapshot> getCollection(String path) async {
    path = dwiformat.pathstring(path);
    return await Firestore.instance.collection(path).getDocuments();
  }

  Stream<QuerySnapshot> streamCollection(String path) {
    return Firestore.instance.collection(path).snapshots();
  }

  Stream<QuerySnapshot> streamOrderCollection(String path, String order) {
    path = dwiformat.pathstring(path);
    return Firestore.instance.collection(path).orderBy(order).snapshots();
  }

  Future<DocumentSnapshot> getDocument(String path, String document) async {
    document = dwiformat.simplestring(document);
    path = dwiformat.pathstring(path);
    print("get Doc: $path/$document");
    return await Firestore.instance.collection(path).document(document).get();
  }

  Stream<DocumentSnapshot> streamDocument(String path, String document) {
    print("stream doc: $path/$document");
    return Firestore.instance.collection(path).document(document).snapshots();
  }

  Future<bool> waitOnDocumentChanged(String path, String document) async {
    Stream<bool> value;
    StreamController<bool> controller = new BehaviorSubject();
    value = controller.stream;
    controller.add(false);
    db.collection(path).document(document).snapshots().distinct().skip(1).listen((onData)=> controller.add(true));
    await value.firstWhere((bool item) => item);
    controller.close();
    return true;
  }

  Future<void> setData(
      String path, String document, Map<String, dynamic> data) async {
    print("set doc: $path/$document");
    path = dwiformat.pathstring(path);
    await Firestore.instance
        .collection(path)
        .document(document)
        .setData(data)
        .catchError((e) {
      print(e);
      print("tried to upload data: " + data.toString());
    });
  }

  Future<void> runTransaction(
      String path, String document, Map<String, dynamic> data) async {
    DocumentReference docRef = db.collection(path).document(document);

    try {
      TransactionHandler transactionHandler = (Transaction tran) async {
        await tran.get(docRef).then((DocumentSnapshot snap) async {
          if (snap.exists) {
            await tran.update(docRef, data);
          } else {
            await tran.set(docRef, data);
          }
        }).catchError((err) => {throw err});
      };
      return await db.runTransaction(transactionHandler);
    } catch (e) {
      print(e);
    }
  }

  Future deletedocument(String path, String document) async {
    document = dwiformat.simplestring(document);
    path = dwiformat.pathstring(path);
    await Firestore.instance
        .collection(path)
        .document(document)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> setDataWithoutDocumentName(
      String path, Map<dynamic, dynamic> data) async {
    path = dwiformat.pathstring(path);
    await Firestore.instance
        .collection(path)
        .document()
        .setData(data)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> updateMessage(
      String path, String document, Map<dynamic, dynamic> data) async {
    path = dwiformat.pathstring(path);
    await Firestore.instance
        .collection(path)
        .document(document)
        .setData(data)
        .catchError((e) {
      print(e);
    });
  }

  Future<DocumentSnapshot> getMessage(String path, String document) async {
    return await Firestore.instance.collection(path).document(document).get();
  }
}
