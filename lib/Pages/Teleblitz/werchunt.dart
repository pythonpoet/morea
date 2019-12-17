import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/morea_firestore.dart';

class WerChunnt {
  final StreamController _controller = StreamController<List<List<String>>>();
  final StreamController _incoming = StreamController();

  final MoreaFirebase moreaFire;
  final String eventID;

  WerChunnt(this.moreaFire, this.eventID){
    initChunnt();
  }

  void dispose() {
    print("Ending WerchunntStream");
    this._incoming.close();
    this._controller.close();
  }

  Stream<List<List<String>>> get stream => _controller.stream.asBroadcastStream();

  void initChunnt() {
    _incoming.sink.addStream(moreaFire.streamCollectionWerChunnt(eventID));
    _incoming.stream.listen((data) {
      List<String> chunnt = [];
      List<String> chunntNoed = [];
      List<DocumentSnapshot> documents = data.documents;
      for (DocumentSnapshot document in documents) {
        if (document.data['AnmeldeStatus'] == eventMapAnmeldeStatusPositiv) {
          print(document.data);
          chunnt.add(document.data['Name']);
        } else {
          print(document.data);
          chunntNoed.add(document.data['Name']);
        }
      }
      _controller.sink.add([chunnt, chunntNoed]);
    });
  }
}
