import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseTeleblitzAnmeldungen {
  Stream<List<String>> getTNAngemolden(String eventID);

  Stream<List<String>> getTNAbgemolden(String eventID);

  Stream<List<String>> get getAnmeldungen;

  Stream<List<String>> get getAbmeldungen;
}

class TeleblitzAnmeldungen extends BaseTeleblitzAnmeldungen {
  StreamController<List<String>> _anmeldeController = new BehaviorSubject();
  StreamController<List<String>> _abmeldeController = new BehaviorSubject();
  late CrudMedthods crud0;
  late Stream<QuerySnapshot> sDSAnAbmeldungen;

  Stream<List<String>> get getAnmeldungen => _anmeldeController.stream;

  Stream<List<String>> get getAbmeldungen => _abmeldeController.stream;

  TeleblitzAnmeldungen(FirebaseFirestore firestore, String eventID) {
    crud0 = new CrudMedthods(firestore);
    _anmeldeController.addStream(this.getTNAngemolden(eventID));
    _abmeldeController.addStream(this.getTNAbgemolden(eventID));
  }

  void dispose() {
    _anmeldeController.close();
    _abmeldeController.close();
  }

  Stream<List<String>> getTNAngemolden(String eventID) async* {
    sDSAnAbmeldungen =
        crud0.streamCollection("$pathEvents/$eventID/$pathAnmeldungen");
    Map<String, dynamic> mAnmdeldungen;
    List<DocumentSnapshot> dsAnmeldungen = <DocumentSnapshot>[];
    List<String> lSAnmeldungen = <String>[];

    yield* sDSAnAbmeldungen.map((QuerySnapshot qSAnmeldungen) {
      dsAnmeldungen = qSAnmeldungen.docs;
      lSAnmeldungen.removeRange(0, lSAnmeldungen.length);
      for (DocumentSnapshot dSAnmeldung in dsAnmeldungen) {
        mAnmdeldungen = dSAnmeldung.data() as Map<String, dynamic>;
        if (mAnmdeldungen.containsValue(eventMapAnmeldeStatusPositiv))
          lSAnmeldungen.add(
              (dSAnmeldung.data() as Map<String, dynamic>)[eventMapAnmeldeUID]);
      }
      return lSAnmeldungen;
    });
  }

  Stream<List<String>> getTNAbgemolden(String eventID) async* {
    sDSAnAbmeldungen =
        crud0.streamCollection("$pathEvents/$eventID/$pathAnmeldungen");
    Map<String, dynamic> mAnmdeldungen;
    List<DocumentSnapshot> dsAnmeldungen = <DocumentSnapshot>[];
    List<String> lSAnmeldungen = <String>[];

    yield* sDSAnAbmeldungen.map((QuerySnapshot qSAnmeldungen) {
      dsAnmeldungen = qSAnmeldungen.docs;
      lSAnmeldungen.removeRange(0, lSAnmeldungen.length);
      for (DocumentSnapshot dSAnmeldung in dsAnmeldungen) {
        mAnmdeldungen = dSAnmeldung.data() as Map<String, dynamic>;
        if (mAnmdeldungen.containsValue(eventMapAnmeldeStatusNegativ))
          lSAnmeldungen.add(
              (dSAnmeldung.data() as Map<String, dynamic>)[eventMapAnmeldeUID]);
      }
      return lSAnmeldungen;
    });
  }
}
