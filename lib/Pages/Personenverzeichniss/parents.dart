import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';

class Parents extends StatefulWidget {
  Parents({this.profile});

  var profile;

  @override
  State<StatefulWidget> createState() => ParentsState();
}

class ParentsState extends State<Parents> {
  List<String> _elternPending = [];
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
            itemCount: this._elternPending.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                title: Text(this._elternPending[index]),
                trailing: RaisedButton(
                  onPressed: () {
                    if (widget.profile["Eltern"] == null) {
                      widget.profile["Eltern"] = [this._elternPending[index]];
                    } else {
                      widget.profile["Eltern"].add(this._elternPending[index]);
                    }
                    this._elternPending.removeAt(index);
                    widget.profile["Eltern-pending"] = this._elternPending;
                    auth.updateUserInformation(mapUserData(), widget.profile['UID']);
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
      for (var u in eltern) {
        this._elternPending.add(u);
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
      'Eltern': widget.profile['Eltern']
    };
    return userInfo;
  }
}
