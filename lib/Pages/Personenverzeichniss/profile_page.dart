import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/child_parent_pend.dart';
import 'parents.dart';
import 'chilld_Qr_code.dart';
import 'package:morea/services/morea_firestore.dart';

class ProfilePageState extends StatefulWidget {
  ProfilePageState({this.profile, this.firestore, this.crud0});
  final Firestore firestore;
  final CrudMedthods crud0;

  var profile;
 // MergeChildParent mergeChildParent = new MergeChildParent(firestore);

  @override
  State<StatefulWidget> createState() => ProfilePageStatePage();
}

class ProfilePageStatePage extends State<ProfilePageState> {
  static ProfilePageStatePage _instance;

  factory ProfilePageStatePage() => _instance ??= new ProfilePageStatePage._();

  ProfilePageStatePage._();

  MergeChildParent mergeChildParent;
  MoreaFirebase moreaFire;
  CrudMedthods crud0;
  ChildParendPend childParendPend;
  bool hatEltern = false, hatKinder = false, display = false;
  Stream<bool> value;
  var controller = new StreamController<bool>();
  Future<String> qrCodeString;
  List elternMapList = ['Liam Bebecho'], kinderMapList = ['Walter'];
  
 

  void reload() async {
    value = controller.stream;
    controller.add(false);
    
      var newData = await moreaFire.getUserInformation(widget.profile['UID']);
      if (newData.data != widget.profile) {
        widget.profile = newData.data;
        erziungsberechtigte();
      
    }
  }

  Future<void> erziungsberechtigte() async {
    if ((widget.profile['Eltern-pending'] != null) &&
        (widget.profile['Eltern-pending'].length != 0)) {
      await getElternMap();
      hatEltern = true;
      setState(() {});
    } else {
      hatEltern = false;
    }
  }

  Future<void> getkinder() async {
    if ((widget.profile['Kinder'] != null) &&
        (widget.profile['Kinder'].length != 0)) {
      await getKindernMap();
      hatKinder = true;
      setState(() {});
    } else {
      hatKinder = false;
    }
  }

  void childaktuallisieren()async {
    if (display) {
      display = false;
      if (qrCodeString != null) {
        childParendPend.deleteRequest(await qrCodeString);
        qrCodeString = null;
      }
    } else {
      display = true;
      documentChangeListender();
    }
    setState(() {});
  }
  void documentChangeListender()async{
    await Future.delayed(Duration(seconds: 2));
    await childParendPend.waitOnUserDataChange(widget.profile[userMapUID]);
    display = false;
    setState(() {
      
    });
  }
  void parentaktuallisieren() {
    if (display) {
      if (!mergeChildParent.parentReaderror) {
        display = false;
      }
    } else {
      display = true;
    }
    setState(() {});
  }

  Future<void> getElternMap() async {
    List elternUID = List.from(widget.profile['Eltern-pending'].values);
    for (int i = 0; i < elternUID.length; i++) {
      var elternData = await moreaFire.getUserInformation(elternUID[i]);
      if (i == 0) {
        elternMapList[0] = elternData.data;
      } else {
        elternMapList.add(elternData.data);
      }
    }
    return null;
  }

  Future<void> getKindernMap() async {
    List kinderUID = List.from(widget.profile['Kinder'].values);
    for (int i = 0; i < kinderUID.length; i++) {
      var kinderData = await moreaFire.getUserInformation(kinderUID[i]);
      if (i == 0) {
        kinderMapList[0] = kinderData.data;
      } else {
        kinderMapList.add(kinderData.data);
      }
    }
    return null;
  }

  @override
  void initState() {
    mergeChildParent = new MergeChildParent(widget.firestore);
     moreaFire = MoreaFirebase(widget.firestore);
     crud0 = widget.crud0;
     childParendPend = new ChildParendPend(crud0: widget.crud0);
    if (widget.profile['Pos'] == 'Teilnehmer') {
      reload();
      erziungsberechtigte();
    } else {
      getkinder();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profile['Pos'] == 'Teilnehmer') {
      return Container(
          child: Scaffold(
              appBar: AppBar(
                title: Text(widget.profile['Vorname'].toString()),
                backgroundColor: Color(0xff7a62ff),
              ),
              body: Stack(
                children: <Widget>[
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                          child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: viewChildprofile(context),
                      ));
                    },
                  ),
                  new Align(
                    child: display
                        ? mergeChildParent
                            .childShowQrCode(widget.profile, context)
                        : Container(),
                  )
                ],
              )));
    } else {
      return Container(
          child: Scaffold(
              appBar: AppBar(
                title: Text(widget.profile['Vorname'].toString()),
                backgroundColor: Color(0xff7a62ff),
              ),
              body: Stack(
                children: <Widget>[
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                          child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: viewParentprofile(context),
                      ));
                    },
                  ),
                  new Align(
                    child: display
                        ? mergeChildParent.parentScannsQrCode(
                            widget.profile)
                        : Container(),
                  )
                ],
              )));
    }
  }
  

  Widget viewChildprofile(BuildContext context) {
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
              )),
          SizedBox(
            height: 15,
          ),
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
              )),
          SizedBox(
            height: 15,
          ),
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
          hatEltern ? elternAnzeigen() : Container(),
          SizedBox(
            height: 10,
          ),
          Container(
            child: RaisedButton(
              child: Text(
                'Mit Eltern Koppeln',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () => {
                childaktuallisieren()},
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Color(0xff7a62ff),
              textColor: Colors.white,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Container(
            child: Center(
              child: Text(
                'Sind deine Angaben nicht korrekt?\nWende dich bitte an ein Leiter',
                style: new TextStyle(fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget viewParentprofile(BuildContext context) {
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
              )),
          SizedBox(
            height: 15,
          ),
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
              )),
          SizedBox(
            height: 15,
          ),
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
          hatKinder ? kinderAnzeigen() : Container(),
          SizedBox(
            height: 10,
          ),
          Container(
            child: RaisedButton(
              child: Text(
                'Mit Kind Koppeln',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () => parentaktuallisieren(),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Color(0xff7a62ff),
              textColor: Colors.white,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Container(
            child: Center(
              child: Text(
                'Sind deine Angaben nicht korrekt?\nWende dich bitte an ein Leiter',
                style: new TextStyle(fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget elternAnzeigen() {
    if (elternMapList[0] != 'Liam Bebecho') {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Container(
            height: 130 * (elternMapList.length).toDouble(),
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
                    itemBuilder: (context, int index) {
                      Map<String, dynamic> elternMap =
                          Map<String, dynamic>.from(elternMapList[index]);
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
                    })),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget kinderAnzeigen() {
    if (kinderMapList[0] != 'Walter') {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Container(
            height: 130 * (kinderMapList.length).toDouble(),
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
                    itemCount: kinderMapList.length,
                    itemExtent: 130,
                    itemBuilder: (context, int index) {
                      Map<String, dynamic> kinderMap =
                          Map<String, dynamic>.from(kinderMapList[index]);
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('${kinderMap['Pos']}:',
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
                                  kinderMap['Vorname'],
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
                                  kinderMap['Nachname'],
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
                                  kinderMap['Email'],
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
                                  kinderMap['Handynummer'],
                                  style: TextStyle(fontSize: 20),
                                )))
                              ],
                            ),
                          ],
                        ),
                      );
                    })),
          )
        ],
      );
    } else {
      return Container();
    }
  }
}
