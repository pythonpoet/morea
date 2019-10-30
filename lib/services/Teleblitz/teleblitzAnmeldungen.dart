import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/Teleblitz/download_teleblitz.dart';
import 'package:morea/services/crud.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseTeleblitzAnmeldungen{
   Stream<List<String>> getTNAngemolden(String eventID);
   Stream<List<String>> getTNAbgemolden(String eventID);
}
class TeleblitzAnmeldungen extends BaseTeleblitzAnmeldungen{
  StreamController<List<String>> _anmeldeController = new BehaviorSubject();
  StreamController<List<String>> _abmeldeController = new BehaviorSubject();
  CrudMedthods crud0;
  Stream<QuerySnapshot> sDSAnAbmeldungen;

  Stream<List<String>> get getAnmeldungen => _anmeldeController.stream;
  Stream<List<String>> get getAbmeldungen => _abmeldeController.stream;

  TeleblitzAnmeldungen(Firestore firestore, String eventID){
    crud0 = new CrudMedthods(firestore);
    _anmeldeController.addStream(this.getTNAngemolden(eventID));
    _abmeldeController.addStream(this.getTNAbgemolden(eventID));
  }
  @override
  void dispose(){
    _anmeldeController.close();
    _abmeldeController.close();
  }

  Stream<List<String>> getTNAngemolden(String eventID)async*{
      sDSAnAbmeldungen =
          crud0.streamCollection("$pathEvents/$eventID/$pathAnmeldungen");
    Map<String, dynamic> mAnmdeldungen;
    List<DocumentSnapshot> dsAnmeldungen = new List<DocumentSnapshot>(); 
    List<String> lSAnmeldungen = new List<String>();

    yield* sDSAnAbmeldungen.map((QuerySnapshot qSAnmeldungen){
      dsAnmeldungen = qSAnmeldungen.documents;
      lSAnmeldungen.removeRange(0, lSAnmeldungen.length);
      for(DocumentSnapshot dSAnmeldung in dsAnmeldungen){
        mAnmdeldungen = dSAnmeldung.data;
        if(mAnmdeldungen.containsValue(eventMapAnmeldeStatusPositiv))
          lSAnmeldungen.add(dSAnmeldung.data[eventMapAnmeldeUID]);
      }
      return lSAnmeldungen;
    });
  }
  Stream<List<String>> getTNAbgemolden(String eventID)async*{
      sDSAnAbmeldungen =
          crud0.streamCollection("$pathEvents/$eventID/$pathAnmeldungen");
    Map<String, dynamic> mAnmdeldungen;
    List<DocumentSnapshot> dsAnmeldungen = new List<DocumentSnapshot>(); 
    List<String> lSAnmeldungen = new List<String>();

    yield* sDSAnAbmeldungen.map((QuerySnapshot qSAnmeldungen){
      dsAnmeldungen = qSAnmeldungen.documents;
      lSAnmeldungen.removeRange(0, lSAnmeldungen.length);
      for(DocumentSnapshot dSAnmeldung in dsAnmeldungen){
        mAnmdeldungen = dSAnmeldung.data;
        if(mAnmdeldungen.containsValue(eventMapAnmeldeStatusNegativ))
          
          lSAnmeldungen.add(dSAnmeldung.data[eventMapAnmeldeUID]);
      }
      return lSAnmeldungen;
    });
  }
}