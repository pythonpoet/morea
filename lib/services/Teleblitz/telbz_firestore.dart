

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';

abstract class BaseTeleblitzFirestore {
  Future<String> getTelbzAkt(String groupnr);
  Future<Map> getTelbz(String eventID);

  Future<bool> eventIDExists(String eventID);

  Future<void> uploadTelbzAkt(String groupnr, Map<String, dynamic> data);
  Future<void> uploadTelbz(String eventID, Map<String, dynamic> data);
}

class TeleblizFirestore implements BaseTeleblitzFirestore {
  CrudMedthods crud0;


  TeleblizFirestore(Firestore firestore) {
    crud0 = CrudMedthods(firestore);
  }
  
  Future<String> getTelbzAkt(String groupnr) async {
    try {
      DocumentSnapshot akteleblitz = await crud0.getDocument('groups', groupnr);
      return akteleblitz.data['AktuellerTeleblitz'];
    } catch (e) {
      print(e.toString());
      return DateTime.parse('2019-03-07T13:30:16.388642').toString();
    }
  }

  Future<Map> getTelbz(String eventID) async {
    try {
      return (await crud0.getDocument('groups', eventID)).data;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> eventIDExists(eventID) async {
    DocumentSnapshot doc = await crud0.getDocument("events", eventID);
    return doc.exists;
  }

  Future<void> uploadTelbzAkt(String groupnr, Map<String, dynamic> data) async {
    return await crud0.runTransaction('groups', groupnr, data);
  }

  Future<void> uploadTelbz(String eventID, Map<String, dynamic> data) async {
    data['Timestamp'] = DateTime.now().toString();
    return await crud0.runTransaction('events', eventID, data);
  }
}
