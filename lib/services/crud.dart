import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:morea/services/auth.dart';

abstract class BasecrudMethods{
  Future<QuerySnapshot> getData(String dateipfad );
}
class crudMedthods implements BasecrudMethods {
  Auth auth = new Auth();

  Future<QuerySnapshot> getData(String dateipfad ) async {
    return await Firestore.instance.collection(dateipfad).getDocuments();
  }
}
