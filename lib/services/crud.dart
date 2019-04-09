import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dwi_format.dart';


abstract class BaseCrudMethods{
  Future<QuerySnapshot> getCollection(String path);
  Stream<QuerySnapshot> streamCollection(String path);
  Stream<QuerySnapshot> streamOrderCollection(String path, String order);

  Future<DocumentSnapshot> getDocument(String path, String document);
  Stream<DocumentSnapshot> streamDocument(String path, String document);
  
  Future<void> setData(String path, String document, Map data);

  Future deletedocument(String path, String document);
}
class CrudMedthods implements BaseCrudMethods {
  DWIFormat dwiformat = new DWIFormat();

  Future<QuerySnapshot> getCollection(String path ) async {
    path = dwiformat.pathstring(path);
    return await Firestore.instance.collection(path).getDocuments();
  }
  Stream<QuerySnapshot> streamCollection(String path)  {
    path = dwiformat.pathstring(path);
    return Firestore.instance.collection(path).snapshots();
  }
  Stream<QuerySnapshot> streamOrderCollection(String path, String order){
    path = dwiformat.pathstring(path);
    return Firestore.instance.collection(path).orderBy(order).snapshots();
  }
  
  Future<DocumentSnapshot> getDocument(String path, String document) async{
    document = dwiformat.simplestring(document);
    path = dwiformat.pathstring(path);
    return await Firestore.instance.collection(path).document(document).get();
  }
  Stream<DocumentSnapshot> streamDocument(String path, String document){
    return Firestore.instance.collection(path).document(document).snapshots();
  }

  Future<void> setData(String path, String document, Map data) async {
    document = dwiformat.simplestring(document);
    path = dwiformat.pathstring(path);
    await Firestore.instance.collection(path).document(document).setData(data).catchError((e){
      print(e);
    });
  }
  Future deletedocument(String path, String document) async{
    document = dwiformat.simplestring(document);
    path = dwiformat.pathstring(path);
    await Firestore.instance.collection(path).document(document).delete().catchError((e){
      print(e);
    });
  }
}
