import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/services/crud.dart';

class MessagesManager {
  CrudMedthods crud0;

  StreamController<List<QueryDocumentSnapshot>> _messagesStreamController =
      StreamController();
  Stream<List<QueryDocumentSnapshot>> get stream =>
      _messagesStreamController.stream;

  StreamSubscription? _subscription;

  MessagesManager(this.crud0);

  dispose() {
    _messagesStreamController.close();
    _subscription!.cancel();
  }

  pause() {
    _subscription!.pause();
  }

  resume() {
    _subscription!.resume();
  }

  getMessages(List<String> subscribedGroups) {
    _subscription = crud0.streamCollection('messages').listen((messages) {
      List<QueryDocumentSnapshot> messagesDocuments = messages.docs;
      messagesDocuments.retainWhere((document) {
        return (document.data()! as Map<String, dynamic>)['receivers']
            .any((receiver) {
          return subscribedGroups.contains(receiver);
        });
      });
      messagesDocuments.sort((a, b) =>
          (b.data()! as Map<String, dynamic>)['timestamp'].toDate().compareTo(
              (a.data()! as Map<String, dynamic>)['timestamp'].toDate()));
      _messagesStreamController.sink.add(messagesDocuments);
    });
  }
}
