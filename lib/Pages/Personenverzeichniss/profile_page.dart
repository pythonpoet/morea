import 'package:flutter/material.dart';
import 'parents.dart';

class ProfilePageState extends StatelessWidget {
  MergeChildParent mergeChildParent = new MergeChildParent();
  ProfilePageState({this.profile});
  var profile;

  @override
  Widget build(BuildContext context) {
    BuildContext context;
    return Container(
        child: Scaffold(
            appBar: AppBar(
              title: Text(profile['Vorname'].toString()),
               backgroundColor: Color(0xff7a62ff),
            ),
            body: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                    child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: viewprofile(context),
                ));
              },
            ),
            ));
  }

  Widget viewprofile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Vorname:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Vorname'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Nachname:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Nachname'],
                        style: TextStyle(fontSize: 20),
                      ))),
                      
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Pfadinamen:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Pfadinamen'],
                        style: TextStyle(fontSize: 20),
                      ))),
                    ],
                  ),
                ),
              ],
            ),
            )
          ),
          SizedBox(height: 15,),
          Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Telefon:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Handynummer'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
                 Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Email:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Email'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
              ],
            ),
            )
          ),
           SizedBox(height: 15,),
          Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Adresse:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Adresse'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Ort:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Ort'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'PLZ:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['PLZ'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
              ],
            ),
            ),       
          ),
          Container(
            child: RaisedButton(
              child: Text('Mit Elternteil Koppeln'),
              onPressed: () => mergeChildParent.parentReadsQrCode(context)//mergeChildParent.childShowQrCode(profile['UID'], context),
            ),
          ),


          SizedBox(height: 24,),
          Container(
            child: Center(
              child: Text(
                'Sind deine Angaben nicht korrekt?\nWende dich bitte an deine Leiter',
                style: new TextStyle(fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}
