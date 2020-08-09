import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:morea/services/crud.dart';
/*
Use-Case:
  This Class contains the participates type.
  
Developed:
  David Wild - 9.08.20

Description:
  initialisation:
    stream eventID
    crud0
  
  Functions:
    streamParticipates
     - readParticipates
    getAttendanceList
    getAbsenceList
    
*/



abstract class BaseParticipates{
  Stream<QuerySnapshot> streamParticipates(Stream<String> eventID);
  Stream<Participates> readParticipates(Stream<QuerySnapshot> participates);
  List<String> get getAttenceList;
  List<String> get getAbsenceList;
  
}

class Participates extends BaseParticipates{
  CrudMedthods crud0;
  Stream<String> eventID;

  Participates({this.eventID, @required this.crud0 }){

  }
}