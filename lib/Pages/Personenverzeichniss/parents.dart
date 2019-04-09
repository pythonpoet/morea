import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:flutter/material.dart';
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
class Parents extends StatefulWidget {
  Parents({this.profile});

  var profile;

  @override
  State<StatefulWidget> createState() => ParentsState();
}

class ParentsState extends State<Parents> {
  Map<String, dynamic> _elternPending = {};
  Auth auth = Auth();
  CrudMedthods crud0bj = new CrudMedthods();
  Auth auth0 = new Auth();
  MoreaFirebase moreafire = new MoreaFirebase();
  Teleblitz tlbz = new Teleblitz();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  Info teleblitzinfo = new Info();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Eltern bestätigen"),
        ),
        body: StreamBuilder(
            stream: moreafire.streamPendingParents(widget.profile['UID']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Text('Loading...'),
                );
              } else {
                var elternpending = snapshot.data['Eltern-pending'];
                return Container(
                  margin: EdgeInsets.all(20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: elternpending.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new ListTile(
                        title: Text(List.of(elternpending.keys)[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                var parentuid =
                                List.of(elternpending.values)[index];
                                var parentname =
                                List.of(elternpending.keys)[index];
                                if (widget.profile["Eltern"] == null) {
                                  widget.profile["Eltern"] = elternpending;
                                } else {
                                  widget.profile["Eltern"][parentname] = parentuid;
                                }
                                this.createList(snapshot.data['Eltern-pending']);
                                this._elternPending.remove(parentname);
                                moreafire.updateUserInformation(
                                   widget.profile['UID'], mapUserData());
                                moreafire.setChildToParent(
                                    parentuid,
                                    widget.profile['Vorname'],
                                    widget.profile['UID']);
                              },
                              child: Text("Annehmen"),
                            ),
                            Container(
                              width: 20,
                            ),
                            RaisedButton(
                              onPressed: (){
                                this.createList(snapshot.data['Eltern-pending']);
                                this._elternPending.remove(List.of(elternpending.keys)[index]);
                                moreafire.updateUserInformation(widget.profile['UID'],mapUserData());
                              },
                              child: Text('Ablehnen'),
                            )
                          ],
                        )
                      );
                    },
                  ),
                );
              }
            }));
  }

  createList(info) {
    this._elternPending.clear();
    var eltern = info;
    if (eltern != null) {
      for (var u in eltern.keys) {
        this._elternPending[u] = eltern[u];
      }
    } else {
      print("Error");
    }
  }

  Map mapUserData() {
    Map<String, dynamic> userInfo = {
      'Vorname': widget.profile['Vorname'],
      'Nachname': widget.profile['Nachname'],
      'Adresse': widget.profile['Adresse'],
      'PLZ': widget.profile['PLZ'],
      'Ort': widget.profile['Ort'],
      'Handynummer': widget.profile['Handynummer'],
      'Pos': widget.profile['Pos'],
      'UID': widget.profile['UID'],
      'Email': widget.profile['Email'],
      'devtoken': widget.profile['devtoken'],
      'Eltern-pending': this._elternPending,
      'Eltern': widget.profile['Eltern'],
      'Stufe': widget.profile['Stufe'],
      'Pfadinamen': widget.profile['Pfadinamen']
    };
    return userInfo;
  }
}
