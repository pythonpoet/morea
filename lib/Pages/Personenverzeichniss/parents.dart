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
  void initState() {
    super.initState();
    this.createList(widget.profile["Eltern-pending"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Eltern bestätigen"),
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: this._elternPending.keys.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                title: Text(List.of(this._elternPending.keys)[index]),
                trailing: RaisedButton(
                  onPressed: () {
                    var parentuid = List.of(this._elternPending.keys)[index];
                    if (widget.profile["Eltern"] == null) {
                      widget.profile["Eltern"] = this._elternPending;
                    } else {
                      widget.profile["Eltern"][List.of(
                          this._elternPending.keys)[index]] =
                      List.of(this._elternPending.values)[index];
                    }
                    this._elternPending.remove(
                        List.of(this._elternPending.keys)[index]);
                    widget.profile["Eltern-pending"] = this._elternPending;
                    auth.updateUserInformation(
                        mapUserData(), widget.profile['UID']);
                    auth.setChildToParent(parentuid, widget.profile['Vorname'], widget.profile['UID']);
                  },
                  child: Text("Annehmen"),
                ),
              );
            },
          ),
        ));
  }

  createList(info) {
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
      'Stufe': widget.profile['Stufe']
    };
    return userInfo;
  }
}
