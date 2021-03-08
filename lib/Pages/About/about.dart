import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/utilities/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Widgets/standart/buttons.dart';

class AboutThisApp extends StatelessWidget {
  final Urllauncher urllauncher = Urllauncher();
  final String aboutText =
      "Warum haben wir eine App für die Pfadi Morea kreiert?\nHeutzutage will man alles mit dem Handy machen können, vom chatten bis zum eBanking. Also wollten wir euch dies auch für die Pfadi ermöglichen. Unser Ziel ist es, gewisse Abläufe für euch zu vereinfachen. So haben wir den E-Mail-Verteiler in die App integriert, so dass ihr automatisch in den Verteiler aufgenommen werdet, wenn ihr euch für die App registriert.\nDie App soll in Zukunft erweitert werden mit Funktionen, die euch das Leben in der Pfadi weiter vereinfachen.\nFalls ihr Ideen für die Weiterentwicklung der App habt oder wenn ihr Fehler findet, dann schreibt uns!";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Über dieses App",
          style: MoreaTextStyle.lable,
        ),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: RichText(
                    text: TextSpan(
                        text: 'Die Pfadi Morea hat eine App!?',
                        style: TextStyle(
                            color: MoreaColors.violett,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: 0.15)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                    left: 20.0,
                  ),
                  child: RichText(
                      text: TextSpan(
                          text: aboutText,
                          style: MoreaTextStyle.normal,
                          children: <TextSpan>[
                        TextSpan(
                            text: '.\nAzb Jarvis und Roran',
                            style: MoreaTextStyle.normal)
                      ])),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: moreaRaisedButton('it@morea.ch', () {
                    launch("mailto:<it@morea.ch>");
                  }),
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
