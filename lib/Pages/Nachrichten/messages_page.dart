import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/Pages/Nachrichten/send_message.dart';
import 'package:morea/morealayout.dart';

import 'single_message_page.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage({this.userInfo, this.firestore});
  var userInfo;
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  MoreaFirebase firestore;
  Auth auth0 = Auth();
  var messages;
  var date;
  var uid;
  var stufe;
  
  
  @override
  void initState() {
    super.initState();
    _getMessages();
    firestore = new MoreaFirebase(widget.firestore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nachrichten'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => SendMessages()));
        },
        child: Icon(Icons.edit),
        backgroundColor: MoreaColors.violett,
      ),
      body: StreamBuilder(
          stream: this.messages,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('Loading...');
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    var document = snapshot.data.documents[index];
                    return _buildListItem(context, document);
                  });
            }
          }),
    );
  }

  _getMessages() async {
    this.uid = await auth0.currentUser();
    var userInfo = await firestore.getUserInformation(uid);
    this.stufe = await userInfo.data['Stufe'];
    setState(() {
      this.messages = firestore.getMessages(this.stufe);
    });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    var message = document;
    if (!(document['read'].containsKey(this.uid))) {
      return Container(
          padding: EdgeInsets.only(right: 20, left: 20),
          child: ListTile(
            key: UniqueKey(),
            title: Text(document['title'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(document['sender'],
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            contentPadding: EdgeInsets.only(),
            leading: CircleAvatar(
              child: Text(document['sender'][0]),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await firestore.setMessageRead(
                  this.uid, document.documentID, this.stufe);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return SingleMessagePage(message);
              }));
            },
          ));
    } else if (!(document['read'][this.uid])) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          key: UniqueKey(),
          title: Text(document['title'],
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(document['sender'],
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          contentPadding: EdgeInsets.only(),
          leading: CircleAvatar(
            child: Text(document['sender'][0]),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () async {
            await firestore.setMessageRead(
                this.uid, document.documentID, this.stufe);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return SingleMessagePage(message);
            }));
          },
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          key: UniqueKey(),
          title: Text(
            document['title'],
          ),
          subtitle: Text(
            document['sender'],
          ),
          contentPadding: EdgeInsets.only(),
          leading: CircleAvatar(
            child: Text(document['sender'][0]),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return SingleMessagePage(message);
            }));
          },
        ),
      );
    }
  }
}
