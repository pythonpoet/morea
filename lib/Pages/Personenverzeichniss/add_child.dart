import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/services/Getteleblitz.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/Pages/Personenverzeichniss/parents.dart';
import 'package:morea/Pages/Personenverzeichniss/add_child.dart';
import 'package:morea/services/morea_firestore.dart';

class AddChild extends StatefulWidget {
  Auth auth;
  var profile;

  AddChild(Auth this.auth, var this.profile);

  @override
  State<StatefulWidget> createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {
  CrudMedthods crud0bj = new CrudMedthods();
  Auth auth0 = new Auth();
  MoreaFirebase moreafire = new MoreaFirebase();
  Teleblitz tlbz = new Teleblitz();
  Info teleblitzinfo = new Info();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Kind hinzufügen'),
        ),
        body: StreamBuilder(
            stream: moreafire.getChildren(),
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
                                              moreafire.pendParent(
                                                  child['UID'],
                                                  widget.profile['UID'],
                                                  widget.profile['Vorname']);
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
