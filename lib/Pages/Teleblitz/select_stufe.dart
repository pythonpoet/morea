import 'package:flutter/material.dart';
import 'package:morea/services/morea_firestore.dart';
import 'change_teleblitz.dart';
import 'package:morea/morealayout.dart';
import 'select_teleblitz_type.dart';

class SelectStufe extends StatelessWidget {
  SelectStufe(this.moreaFire);
  MoreaFirebase moreaFire;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stufe wählen"),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Container(
            decoration: BoxDecoration(
              color: MoreaColors.orange,
              image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  alignment: Alignment.bottomCenter),
            ),
            alignment: Alignment.topCenter,
            child: Container(
              decoration: MoreaShadow.teleblitz,
              margin: EdgeInsets.all(20),
              constraints:
                  BoxConstraints(minWidth: viewportConstraints.maxWidth),
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
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(thickness: 1, color: Colors.black26,)
                  ),
                  ListTile(
                    title: Text(
                      "Biber",
                      style: TextStyle(fontSize: 18),
                    ),
                    contentPadding: EdgeInsets.only(right: 15, left: 15,),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            SelectTeleblitzType('Biber', moreaFire)
                      ));
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(thickness: 1, color: Colors.black26,)
                  ),
                  ListTile(
                    title: Text(
                      "Wombat",
                      style: TextStyle(fontSize: 18),
                    ),
                    contentPadding: EdgeInsets.only(right: 15, left: 15,),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SelectTeleblitzType('Wombat (Wölfe)', moreaFire), 
                      ));
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(thickness: 1, color: Colors.black26,)
                  ),
                  ListTile(
                    title: Text(
                      "Nahani",
                      style: TextStyle(fontSize: 18),
                    ),
                    contentPadding: EdgeInsets.only(right: 15, left: 15,),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SelectTeleblitzType('Nahani (Meitli)', moreaFire)
                      ));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(thickness: 1, color: Colors.black26,)
                  ),
                  ListTile(
                    title: Text(
                      "Drason",
                      style: TextStyle(fontSize: 18),
                    ),
                    contentPadding: EdgeInsets.only(right: 15, left: 15, bottom: 15),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SelectTeleblitzType('Drason (Buebe)', moreaFire)
                      ));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
