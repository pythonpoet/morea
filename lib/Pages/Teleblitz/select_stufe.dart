import 'package:flutter/material.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';
import 'select_teleblitz_type.dart';

class SelectStufe extends StatelessWidget {
  SelectStufe(this.moreaFire);

  final MoreaFirebase moreaFire;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Stufe wählen"),
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
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "Stufe auswählen",
                      style: MoreaTextStyle.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Biber",
                      style: MoreaTextStyle.lable,
                    ),
                    contentPadding: EdgeInsets.only(
                      right: 15,
                      left: 15,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SelectTeleblitzType('Biber', moreaFire)));
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        thickness: 1,
                        color: Colors.black26,
                      )),
                  ListTile(
                    title: Text(
                      "Wombat",
                      style: MoreaTextStyle.lable,
                    ),
                    contentPadding: EdgeInsets.only(
                      right: 15,
                      left: 15,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            SelectTeleblitzType('Wombat (Wölfe)', moreaFire),
                      ));
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        thickness: 1,
                        color: Colors.black26,
                      )),
                  ListTile(
                    title: Text(
                      "Nahani",
                      style: MoreaTextStyle.lable,
                    ),
                    contentPadding: EdgeInsets.only(
                      right: 15,
                      left: 15,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SelectTeleblitzType(
                                  'Nahani (Meitli)', moreaFire)));
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        thickness: 1,
                        color: Colors.black26,
                      )),
                  ListTile(
                    title: Text(
                      "Drason",
                      style: MoreaTextStyle.lable,
                    ),
                    contentPadding:
                        EdgeInsets.only(right: 15, left: 15, bottom: 15),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SelectTeleblitzType(
                                  'Drason (Buebe)', moreaFire)));
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
