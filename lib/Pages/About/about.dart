import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:share/share.dart';

class AboutThisApp extends StatelessWidget {
  final String aboutText =
      "Warum haben wir eine App für die Pfadi Morea kreiert?\nHeutzutage will man alles mit dem Handy machen können, vom chatten bis zum eBanking. Also wollten wir euch dies auch für die Pfadi ermöglichen. Unser Ziel ist es, gewisse Abläufe für euch zu vereinfachen, so haben wir den E-Mail-Verteiler in die App integriert, so dass ihr automatisch in den Verteiler aufgenommen werdet, wenn ihr euch für die App registriert.";

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
                  child: new Text(
                    "Die Pfadi Morea hat eine App!?",
                    style: MoreaTextStyle.lable,
                  ),
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(aboutText),
                    new IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () => {
                        Share.share(
                            "Möchtest du auch in die Pfadi? Lade dir unsere Pfadi Morea App im Playstore/Applestore herunter und komm vorbei!")
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
