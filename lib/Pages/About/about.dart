import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:share/share.dart';

class AboutThisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Über dieses App"),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: new Text("Gefällt dir die App?", style: MoreaTextStyle.lable,),
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text("Erzähle allen davon!"),
                    new IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () => {
                        Share.share("Möchtest du auch in die Pfadi? Lade dir unsere Pfadi Morea App im Playstore/Applestore herunter und komm vorbei!")
                      },
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
