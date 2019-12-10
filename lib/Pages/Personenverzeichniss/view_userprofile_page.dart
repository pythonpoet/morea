import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/utilities/url_launcher.dart';
import 'edit_userprofile_page.dart';
 

class ViewUserProfilePageState extends StatelessWidget {
  ViewUserProfilePageState(this.allUsers, this.profile);
  final Map<String,dynamic> profile;
  final QuerySnapshot allUsers;
  final Urllauncher urllauncher = new Urllauncher();
 
  @override
  Widget build(BuildContext context) {
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
                  child: viewprofile(),
                ));
              },
            ),
            floatingActionButton: new FloatingActionButton(
              elevation: 1.0,
              child: new Icon(Icons.edit),
              backgroundColor: Color(0xff7a62ff),
              onPressed: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new EditUserProfilePage(profile: profile,)))
            )));
  }

  Widget viewprofile() {
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
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Rolle:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Pos'],
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
                          child: InkWell(
                            child:  Container(
                              child: Text(
                        profile['Handynummer']?? "",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 0, 255),
                          decoration: TextDecoration.underline),
                      )),
                      onTap: () =>urllauncher.openPhone(profile['Handynummer']?? "007"),
                          ),)
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
                          style: TextStyle(fontSize: 20,
                          ),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                            child: Container(
                              child: Text(
                        profile['Email'],
                        style: TextStyle(fontSize: 20,
                        color: Color.fromARGB(255, 0, 0, 255),
                          decoration: TextDecoration.underline),
                      )),
                      onTap: () => urllauncher.openMail(profile['Email']),
                          ))
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
            )
          ),
           SizedBox(height: 15,),
          profile.containsKey(userMapEltern)? Column(children: parentWidget())  :  Container(),
        ],
      ),
      
    );
  }
  List<Widget> parentWidget(){
    List<Widget> elternWidget = new List();
    for(Map<String,dynamic> eltern in getParentMap()){
      elternWidget.add(
        Column(
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
                              'Rolle:',
                              style: TextStyle(fontSize: 20),
                            ),
                          )),
                          Expanded(
                              child: Container(
                                  child: Text(
                            eltern[userMapPos],
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
                              'Vorname:',
                              style: TextStyle(fontSize: 20),
                            ),
                          )),
                          Expanded(
                              child: Container(
                                  child: Text(
                            eltern['Vorname'],
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
                            eltern['Nachname'],
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
                              'Telefon:',
                              style: TextStyle(fontSize: 20),
                            ),
                          )),
                          Expanded(
                              child: InkWell(
                                child:  Container(
                                  child: Text(
                            eltern['Handynummer'],
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 0, 0, 255),
                              decoration: TextDecoration.underline),
                          )),
                          onTap: () =>urllauncher.openPhone(eltern['Handynummer']),
                              ),)
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
                              style: TextStyle(fontSize: 20,
                              ),
                            ),
                          )),
                          Expanded(
                              child: InkWell(
                                child: Container(
                                  child: Text(
                            eltern['Email'],
                            style: TextStyle(fontSize: 20,
                            color: Color.fromARGB(255, 0, 0, 255),
                              decoration: TextDecoration.underline),
                          )),
                          onTap: () => urllauncher.openMail(eltern['Email']),
                              ))
                        ],
                      ),
                    ),
                    ],
                  ))),
                  SizedBox(height: 15,)
          ],
        )
              );
    }
    return elternWidget;
  }
  getParentMap(){
    List<Map> elternMap = new List();
    if(profile.containsKey(userMapEltern)){
      Map<String,String> elt = Map<String,String>.from(profile[userMapEltern]);
      List<String> elternUID = new List();
      elternUID.addAll(elt.values);
      allUsers.documents.forEach((test){
        if(elternUID.contains(test.documentID)){
          elternMap.add(Map<String,dynamic>.from(test.data));
        }
      });
    }
    return elternMap;
  }
  
}
