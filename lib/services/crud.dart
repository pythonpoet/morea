import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:morea/services/auth.dart';

abstract class BasecrudMethods{
  Future<String> addData(carData, String dateipfad);
  Future<QuerySnapshot> getData(String dateipfad );
}
class crudMedthods implements BasecrudMethods {
  Auth auth = new Auth();

  Future<String> addData(carData, String dateipfad ) async {
    if (auth.currentUser() != null){
      Firestore.instance.collection(dateipfad).add(carData).catchError((e){
        print(e);
      });
      }else{
      print('You need to be logged in');
    }

  }
  Future<QuerySnapshot> getData(String dateipfad ) async {
    return await Firestore.instance.collection(dateipfad).getDocuments();
  }
}
