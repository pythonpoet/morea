import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/morea_firestore.dart';

class WerChunnt {
  final StreamController _controller = StreamController<List<List<String>>>();

  final MoreaFirebase moreaFire;
  final String eventID;

  WerChunnt(this.moreaFire, this.eventID) {
    initChunnt();
  }

  void dispose() {
    print("Ending WerchunntStream");
    this._controller.close();
  }

  Stream<List<List<String>>> get stream => _controller.stream;

  void initChunnt() {
    moreaFire.streamCollectionWerChunnt(eventID).listen((data) {
      List<String> chunnt = [];
      List<String> chunntNoed = [];
      List<DocumentSnapshot> documents = data.docs;
      for (DocumentSnapshot document in documents) {
        if (document.data()['AnmeldeStatus'] == eventMapAnmeldeStatusPositiv) {
          chunnt.add(document.data()['Name']);
        } else {
          chunntNoed.add(document.data()['Name']);
        }
      }
      _controller.add([chunnt, chunntNoed]);
    });
  }
}
