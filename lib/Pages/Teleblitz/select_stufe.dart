import 'package:flutter/material.dart';
import 'change_teleblitz.dart';

class SelectStufe extends StatelessWidget {
  SelectStufe();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stufe wählen"),
        backgroundColor: Color(0xff7a62ff)
      ),
      body: Container(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Stufe auswählen",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: FlatButton(
                  child: Text(
                    "Biber",
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () => Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                          new ChangeTeleblitz(
                            stufe: "Biber",
                          ))),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: FlatButton(
                  child: Text(
                    "Wombat",
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () => Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                          new ChangeTeleblitz(
                            stufe: "Wombat (Wölfe)",
                          ))),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: FlatButton(
                  child: Text(
                    "Nahani",
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () => Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                          new ChangeTeleblitz(
                            stufe: "Nahani (Meitli)",
                          ))),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlueAccent, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: FlatButton(
                  child: Text(
                    "Drason",
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () => Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                          new ChangeTeleblitz(
                            stufe: "Drason (Buebe)",
                          ))).then((onValue){
                            Navigator.pop(context);
                          }),
                ),
              ),
            ],
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black26),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          margin: EdgeInsets.all(50),
          constraints: BoxConstraints(maxWidth: 250, maxHeight: 350),
        ),
        alignment: Alignment.topCenter,
      ),
    );
  }
}
