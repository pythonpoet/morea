import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/morea_firestore.dart';
import 'change_teleblitz.dart';

class SelectTeleblitzType extends StatelessWidget {
  SelectTeleblitzType(this.stufe, this.moreaFire);

  final String stufe;
  final MoreaFirebase moreaFire;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Typ Teleblitz auswählen'),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Typ auswählen", style: MoreaTextStyle.title),
                ),
                ListTile(
                  title: Text('Normal', style: MoreaTextStyle.lable),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Normaler Teleblitz mit Beginn und Schluss',
                      style: MoreaTextStyle.subtitle,
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ChangeTeleblitz(this.stufe, 'normal', moreaFire))),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding:
                      EdgeInsets.only(right: 15, left: 15, bottom: 10, top: 10),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text('Ausfall Aktivität', style: MoreaTextStyle.lable),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Ein Teleblitz mit einem Feld für den Grund des Ausfalls',
                      style: MoreaTextStyle.subtitle,
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ChangeTeleblitz(
                          this.stufe, 'keineAktivitaet', moreaFire))),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding:
                      EdgeInsets.only(right: 15, left: 15, bottom: 10, top: 10),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text('Ferien', style: MoreaTextStyle.lable),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Ein Teleblitz mit einem Feld für das Ende der Ferien',
                      style: MoreaTextStyle.subtitle,
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ChangeTeleblitz(this.stufe, 'ferien', moreaFire))),
                  trailing: Icon(Icons.arrow_forward_ios),
                  contentPadding:
                      EdgeInsets.only(right: 15, left: 15, bottom: 15, top: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
