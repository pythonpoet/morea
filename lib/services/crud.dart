import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dwi_format.dart';

abstract class BaseCrudMethods {
  Future<QuerySnapshot> getCollection(String path);

  Stream<QuerySnapshot> streamCollection(String path);

  Stream<QuerySnapshot> streamOrderCollection(String path, String order);

  Future<DocumentSnapshot> getDocument(String path, String document);

  Stream<DocumentSnapshot> streamDocument(String path, String document);

  Future<bool> waitOnDocumentChanged(String path, String document);

  Future<void> setData(
      String path, String document, Map<dynamic, dynamic> data);

  Future deletedocument(String path, String document);

  Future<void> setDataMessage(
      String path, Map<dynamic, dynamic> data);
}

class CrudMedthods implements BaseCrudMethods {
  DWIFormat dwiformat = new DWIFormat();

  Future<QuerySnapshot> getCollection(String path) async {
    path = dwiformat.pathstring(path);
    return await Firestore.instance.collection(path).getDocuments();
  }

  Stream<QuerySnapshot> streamCollection(String path) {
    path = dwiformat.pathstring(path);
    return Firestore.instance.collection(path).snapshots();
  }

  Stream<QuerySnapshot> streamOrderCollection(String path, String order) {
    path = dwiformat.pathstring(path);
    return Firestore.instance.collection(path).orderBy(order).snapshots();
  }

  Future<DocumentSnapshot> getDocument(String path, String document) async {
    document = dwiformat.simplestring(document);
    path = dwiformat.pathstring(path);
    return await Firestore.instance.collection(path).document(document).get();
  }

  Stream<DocumentSnapshot> streamDocument(String path, String document) {
    return Firestore.instance.collection(path).document(document).snapshots();
  }

  Future<bool> waitOnDocumentChanged(String path, String document) async {
    Stream<bool> value;
    var controller = new StreamController<bool>();

    value = controller.stream;
    controller.add(false);
    Firestore.instance.collection(path).snapshots().listen((onData) {
      onData.documentChanges.forEach((change) async {
        if (change.oldIndex == change.newIndex) {
          controller.add(true);
        }
      });
    });

    return value.firstWhere((bool item) => item);
  }

  Future<void> setData(
      String path, String document, Map<dynamic, dynamic> data) async {
    document = dwiformat.simplestring(document);
    path = dwiformat.pathstring(path);
    await Firestore.instance
        .collection(path)
        .document(document)
        .setData(data)
        .catchError((e) {
      print(e);
    });
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

  Future<void> setDataMessage(
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
}
