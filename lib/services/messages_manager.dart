import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/services/crud.dart';

class MessagesManager{

  CrudMedthods crud0;

  StreamController<QuerySnapshot> _messagesStreamController = StreamController();

  Stream<QuerySnapshot> get stream => _messagesStreamController.stream;

  MessagesManager(this.crud0);

  dispose(){
    _messagesStreamController.close();
  }

  getMessages(List<String> subscribedGroups){
    print('starting');
    print(subscribedGroups);
    crud0.streamCollection('messages').listen((messages){
      messages.documents.retainWhere((document){
        return document.data['receivers'].any((receiver){
          return subscribedGroups.contains(receiver);
        });
      });
      print(messages);
      _messagesStreamController.sink.add(messages);
    });
  }
}