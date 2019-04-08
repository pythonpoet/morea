import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddChild extends StatefulWidget {
  Auth auth;
  var profile;

  AddChild(Auth this.auth, var this.profile);

  @override
  State<StatefulWidget> createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Kind hinzufügen'),
        ),
        body: StreamBuilder(
            stream: widget.auth.getChildren(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                    child: Text(
                  'Laden... einen Moment bitte',
                  style: TextStyle(fontSize: 20),
                ));
              else {
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, int index) {
                      var child = snapshot.data.documents[index];
                      if (child['Pos'] == 'Teilnehmer') {
                        return ListTile(
                          title:
                              Text(child["Vorname"] + ', ' + child['Nachname']),
                          trailing: Icon(Icons.person_add),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title:
                                        Text(child['Vorname'] + ' hinzufügen?'),
                                    content: Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Container(
                                          margin: EdgeInsets.only(right: 20),
                                          child: new RaisedButton(
                                            child: new Text('Ja',
                                                style: new TextStyle(
                                                    fontSize: 20)),
                                            onPressed: () {
                                              widget.auth.pendParent(
                                                  child['UID'],
                                                  widget.profile['Vorname'],
                                                  widget.profile['UID']);
                                              Navigator.of(context).pop();
                                            },
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0)),
                                          ),
                                        )),
                                        Expanded(
                                          child: Container(
                                            child: new RaisedButton(
                                              child: new Text('Nein',
                                                  style: new TextStyle(
                                                      fontSize: 20)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              shape: new RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          30.0)),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                });
                          },
                        );
                      } else {
                        return Container();
                      }
                    });
              }
            }));
  }
}
