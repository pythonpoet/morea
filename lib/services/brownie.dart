import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

/*
This class stores Brownie (Cookie) of downloaded files
and stores it at """brownie/{userID}""".

It contains a List of Maps.
Map = 
{
  "Timestamp" : Timestamp,
  "path" : path,
  "location" : location
}
"path" contains the full path of the accessed data.
"location" contains the page witch accessed the data.
*/
abstract class BaseBrownie {
  void crudList(String path, BuildContext context);
  Future<void> uploadCrudList(List crudList);
}

class Brownie extends BaseBrownie {
  String uid;
  Timestamp loadeTime;

  Brownie();

  void crudList(String path, BuildContext context) {}

  Future<void> uploadCrudList(List crudList) {}
}
