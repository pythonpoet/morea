import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/morea_firestore.dart';
import 'change_teleblitz.dart';
import 'change_teleblitz_v2.dart';

class SelectTeleblitzType extends StatelessWidget{

  SelectTeleblitzType(this.stufe, this.moreaFire);

  String stufe;
  MoreaFirebase moreaFire;
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Typ Teleblitz auswählen'),
      ),
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          return Container(
            decoration: BoxDecoration(
              color: MoreaColors.orange,
              image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  alignment: Alignment.bottomCenter),
            ),
            child: Container(
              margin: EdgeInsets.all(20),
              constraints: BoxConstraints(minWidth: viewportConstraints.maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Typ auswählen",
                      style: MoreaTextStyle.title
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(thickness: 1, color: Colors.black26,)
                  ),
                  ListTile(
                    title: Text(
                      'Normal',
                      style: TextStyle(fontSize: 18)
                    ),
                    subtitle: Text(
                      'Normaler Teleblitz mit Beginn und Schluss'
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ChangeTeleblitzV2(
                        this.stufe, "normal", moreaFire
                      )
                    )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    contentPadding: EdgeInsets.only(right: 15, left: 15,),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(thickness: 1, color: Colors.black26,)
                  ),
                  ListTile(
                    title: Text(
                        'Ausfall Aktivität',
                        style: TextStyle(fontSize: 18)
                    ),
                    subtitle: Text(
                        'Ein Teleblitz mit einem Feld für den Grund des Ausfalls'
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ChangeTeleblitz(
                          stufe: this.stufe, formType: 'keineAktivitaet',
                        )
                    )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    contentPadding: EdgeInsets.only(right: 15, left: 15,),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(thickness: 1, color: Colors.black26,)
                  ),
                  ListTile(
                    title: Text(
                        'Ferien',
                        style: TextStyle(fontSize: 18)
                    ),
                    subtitle: Text(
                        'Ein Teleblitz mit einem Feld für das Ende der Ferien'
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ChangeTeleblitz(
                          stufe: this.stufe, formType: 'ferien',
                        )
                    )),
                    trailing: Icon(Icons.arrow_forward_ios),
                    contentPadding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
                  ),
                ],
              ),
              decoration: MoreaShadow.teleblitz,
            ),
            alignment: Alignment.topCenter,
          );
        }
      ),
    );
  }


}