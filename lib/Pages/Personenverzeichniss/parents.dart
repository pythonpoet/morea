import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';

class Parents extends StatefulWidget {
  Parents({this.profile});

  var profile;

  @override
  State<StatefulWidget> createState() => ParentsState();
}

class ParentsState extends State<Parents> {
  Map<String, dynamic> _elternPending = {};
  Auth auth = Auth();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Eltern bestätigen"),
        ),
        body: StreamBuilder(
            stream: auth.getPendingParents(widget.profile['UID']),
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
                                auth.updateUserInformation(
                                    mapUserData(), widget.profile['UID']);
                                auth.setChildToParent(
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
                                auth.updateUserInformation(mapUserData(), widget.profile['UID']);
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
