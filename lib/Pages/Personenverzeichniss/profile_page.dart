import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morea/services/crud.dart';
import 'parents.dart';
import 'chilld_Qr_code.dart';
import 'package:morea/services/morea_firestore.dart';
class ProfilePageState extends StatefulWidget{
  ProfilePageState({this.profile});
  var profile;
  MergeChildParent mergeChildParent = new MergeChildParent();

  @override
  State<StatefulWidget> createState() => ProfilePageStatePage();
}

class ProfilePageStatePage extends State<ProfilePageState> {
  static ProfilePageStatePage _instance;
  factory ProfilePageStatePage() => _instance ??= new ProfilePageStatePage._();
  ProfilePageStatePage._();

  //MergeChildParent mergeChildParent = new MergeChildParent();
  MoreaFirebase moreaFire = MoreaFirebase();
  CrudMedthods crud0 = new CrudMedthods();
  

  bool hatEltern = false, display = false;
  Stream<bool> value;
  var controller = new StreamController<bool>();
  List elternMapList = ['Liam Bebecho'];

  void reload()async{
    value = controller.stream;
    controller.add(false);
    while(true){
      await crud0.waitOnDocumentChanged('user', 'document');
      print('tp1');
      var newData = await moreaFire.getUserInformation(widget.profile['UID']);
        if(newData.data != widget.profile){
            display = false;
            widget.profile = newData.data;    
            erziungsberechtigte();
        }
    }
  }
  Future<void> erziungsberechtigte()async{
    if((widget.profile['Eltern-pending'] != null)&&(widget.profile['Eltern-pending'].length != 0)){
      await getElternMap();
      hatEltern = true;
      setState(() { 
      });
      
    }else{
      hatEltern = false;
    }
  }
  void aktuallisieren(){
    if(display){
      display = false;
    }else{
      display = true;
    }
    setState(() {});
  }
  Future<void> getElternMap()async{
    List elternUID = List.from(widget.profile['Eltern-pending'].values);
    for(int i = 0; i < elternUID.length; i++){
      var elternData = await moreaFire.getUserInformation(elternUID[i]);
      if(i == 0){
        elternMapList[0] = elternData.data;
      }else{
        elternMapList.add(elternData.data);
      }
    }
    return null;
  }
  @override
  void initState() {
    reload();
    erziungsberechtigte();
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.profile['Vorname'].toString()),
               backgroundColor: Color(0xff7a62ff),
            ),
            body: Stack(
              children: <Widget>[
                LayoutBuilder(
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
            new Align(
              child: display? 
              widget.mergeChildParent.childShowQrCode(widget.profile['UID'], context)
              :
              Container(),
            )
              ],
            )
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
                        widget.profile['Vorname'],
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
                        widget.profile['Nachname'],
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
                        widget.profile['Pfadinamen'],
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
                        widget.profile['Handynummer'],
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
                        widget.profile['Email'],
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
                        widget.profile['Adresse'],
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
                        widget.profile['Ort'],
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
                        widget.profile['PLZ'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
              ],
            ),
            ),       
          ),
          hatEltern? 
           elternAnzegen()
            :
            Container(),
          SizedBox(height: 10,),
          Container(
            child: RaisedButton(
              child: Text('Mit Elternteil Koppeln', style: TextStyle(fontSize: 20),),
              onPressed: () =>  aktuallisieren(),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
                  color: Color(0xff7a62ff),
                  textColor: Colors.white,
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
  Widget elternAnzegen(){
    if(elternMapList[0] != 'Liam Bebecho'){
      return Column(
      children: <Widget>[
        SizedBox(height: 15,),
        Container(
        height: 130*(elternMapList.length).toDouble(),
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: elternMapList.length,
                itemExtent: 130,
                itemBuilder: (context, int index)  {
                  
                  Map<String,dynamic> elternMap = Map<String,dynamic>.from(elternMapList[index]);
                  return Container(
                    
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${elternMap['Pos']}:', 
                        style: TextStyle(fontSize: 20)),
                        Row(
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
                        elternMap['Vorname'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                  Row(
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
                        elternMap['Nachname'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                  Row(
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
                        elternMap['Email'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                  Row(
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
                       elternMap['Handynummer'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                      ],
                    ),
                  );
                }
            ) 
         ),       
      )
      ],
    );
    }else{
      return Container();
    }
    
  }
}
