import 'dart:async';
import 'package:flutter/material.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/child_parent_pend.dart';
import 'parents.dart';
import 'package:morea/services/morea_firestore.dart';

class ProfilePageState extends StatefulWidget {
  ProfilePageState({this.profile, this.moreaFire, this.crud0, this.signOut});

  final MoreaFirebase moreaFire;
  final CrudMedthods crud0;
  final Function signOut;

  var profile;

  // MergeChildParent mergeChildParent = new MergeChildParent(firestore);

  @override
  State<StatefulWidget> createState() => ProfilePageStatePage();
}

class ProfilePageStatePage extends State<ProfilePageState> {
  /*static ProfilePageStatePage _instance;

  factory ProfilePageStatePage() => _instance ??= new ProfilePageStatePage._();

  ProfilePageStatePage._();*/

  MergeChildParent mergeChildParent;
  MoreaFirebase moreaFire;
  CrudMedthods crud0;
  ChildParendPend childParendPend;
  bool hatEltern = false,
      hatKinder = false,
      display = false,
      newKidDisplay = false;
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
    if ((widget.profile['Eltern'] != null) &&
        (widget.profile['Eltern'].length != 0)) {
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

  void childaktuallisieren() async {
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

  void documentChangeListender() async {
    await Future.delayed(Duration(seconds: 2));
    await childParendPend.waitOnUserDataChange(widget.profile[userMapUID]);
    display = false;
    setState(() {});
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

  void newKidakt() {
    if (newKidDisplay) {
      newKidDisplay = false;
    } else {
      newKidDisplay = true;
    }
    setState(() {});
  }

  Future<void> getElternMap() async {
    List elternUID = List.from(widget.profile['Eltern'].values);
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

  void setProfileState() {
    setState(() {});
  }

  @override
  void dispose() {
    //_instance.dispose();

    controller.close();
    super.dispose();
  }

  @override
  void initState() {
    mergeChildParent = new MergeChildParent(widget.crud0, widget.moreaFire);
    moreaFire = widget.moreaFire;
    crud0 = widget.crud0;
    childParendPend = new ChildParendPend(
        crud0: widget.crud0, moreaFirebase: widget.moreaFire);
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
              ),
              body: Stack(
                children: <Widget>[
                  MoreaBackgroundContainer(
                    child: SingleChildScrollView(
                        child: MoreaShadowContainer(
                      child: viewChildprofile(context),
                    )),
                  ),
                  Align(
                    child: display
                        ? mergeChildParent.childShowQrCode(
                            widget.profile,
                            context,
                            this.childaktuallisieren,
                            childParendPend.deleteRequest)
                        : Container(),
                  )
                ],
              )));
    } else {
      return Container(
          child: Scaffold(
              appBar: AppBar(
                title: Text(widget.profile['Vorname'].toString()),
              ),
              body: Stack(
                children: <Widget>[
                  MoreaBackgroundContainer(
                    child: SingleChildScrollView(
                        child: MoreaShadowContainer(
                            child: viewParentprofile(context))),
                  ),
                  new Align(
                    child: display
                        ? mergeChildParent.parentScannsQrCode(widget.profile,
                            this.parentaktuallisieren, context, widget.signOut)
                        : Container(),
                  ),
                  new Align(
                      child: newKidDisplay
                          ? mergeChildParent.registernewChild(widget.profile,
                              context, this.setProfileState, this.newKidakt, widget.signOut)
                          : Container())
                ],
              )));
    }
  }

  Widget viewChildprofile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Eltern',
              style: MoreaTextStyle.title,
            ),
          ),
          hatEltern ? elternAnzeigen() : Container(),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text(
                  'Mit Eltern Koppeln',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () => {childaktuallisieren()},
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xff7a62ff),
                textColor: Colors.white,
              ),
            ],
          ),
          SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }

  Widget viewParentprofile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Kinder',
              style: MoreaTextStyle.title,
            ),
          ),
          hatKinder ? kinderAnzeigen() : Container(),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
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
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text(
                  'Neues Kind registrieren',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () => this.newKidakt(),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xff7a62ff),
                textColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget elternAnzeigen() {
    if (elternMapList[0] != 'Liam Bebecho') {
      return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: elternMapList.length,
          itemBuilder: (context, int index) {
            Map<String, dynamic> elternMap =
                Map<String, dynamic>.from(elternMapList[index]);
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 3),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      '${elternMap['Pos']}:',
                      style: MoreaTextStyle.lable,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Name',
                      style: MoreaTextStyle.lable,
                    ),
                    subtitle: Text(
                      '${elternMap["Vorname"]} ${elternMap["Nachname"]}',
                      style: MoreaTextStyle.normal,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'E-Mail-Adresse',
                      style: MoreaTextStyle.lable,
                    ),
                    subtitle: Text(
                      elternMap['Email'],
                      style: MoreaTextStyle.normal,
                    ),
                  ),
                ],
              ),
            );
          });
    } else {
      return Container();
    }
  }

  Widget kinderAnzeigen() {
    if (kinderMapList[0] != 'Walter') {
      return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: kinderMapList.length,
          itemBuilder: (context, int index) {
            Map<String, dynamic> kinderMap =
                Map<String, dynamic>.from(kinderMapList[index]);
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 3),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'Name',
                      style: MoreaTextStyle.lable,
                    ),
                    subtitle: Text(
                      '${kinderMap["Vorname"]} ${kinderMap["Nachname"]}',
                      style: MoreaTextStyle.normal,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'E-Mail-Adresse',
                      style: MoreaTextStyle.lable,
                    ),
                    subtitle: Text(
                      kinderMap['Email'],
                      style: MoreaTextStyle.normal,
                    ),
                  ),
                ],
              ),
            );
          });
    } else {
      return Container();
    }
  }
}
