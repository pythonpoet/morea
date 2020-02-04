import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class AboutThisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Über dieses App"),
      ),
      body: Column(
        children: <Widget>[
          new Text("Dieses App ist geil"),
          new Row(
            children: <Widget>[
              new Text("Erzähle allen davon"),
              new IconButton(
                icon: Icon(Icons.share),
                onPressed: () => {
                  Share.share("Jo lad der das App au mal abe und chum id Pfadi")
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
