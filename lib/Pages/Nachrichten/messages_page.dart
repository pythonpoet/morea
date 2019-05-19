import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/morea_firestore.dart';

import 'single_message_page.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage({this.userInfo});

  var userInfo;

  @override
  State<StatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  MoreaFirebase firestore = MoreaFirebase();
  Auth auth0 = Auth();
  var messages;

  @override
  void initState() {
    super.initState();
    _getMessages();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Nachrichten'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: StreamBuilder(
            stream: this.messages,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                print(this.messages);
                return Text('Loading...');
              } else {
                print(snapshot.data);
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data.documents[index];
                      return _buildListItem(context, document);
                    });
              }
            }),
      ),
    );
  }

  _getMessages() async {
    var uid = await auth0.currentUser();
    setState(() {
      this.messages = firestore.getMessages(uid);
    });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    var message = document;
    return ListTile(
      key: UniqueKey(),
      title: Text(document['title']),
      subtitle: Text(document['snippet']),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return SingleMessagePage(message: message);
          }
        )
      ),
    );
  }
}
