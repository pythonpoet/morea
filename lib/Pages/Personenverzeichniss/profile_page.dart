import 'dart:async';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/Widgets/standart/restartWidget.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/child_parent_pend.dart';
import 'parents.dart';
import 'package:morea/services/morea_firestore.dart';

class ProfilePageState extends StatefulWidget {
  ProfilePageState({required this.profile, required this.moreaFire, required this.crud0, required this.signOut});

  final MoreaFirebase moreaFire;
  final CrudMedthods crud0;
  final Function signOut;

  final Map<String, dynamic> profile;

  // MergeChildParent mergeChildParent = new MergeChildParent(firestore);

  @override
  State<StatefulWidget> createState() => ProfilePageStatePage();
}

class ProfilePageStatePage extends State<ProfilePageState> {
  /*static ProfilePageStatePage _instance;

  factory ProfilePageStatePage() => _instance ??= new ProfilePageStatePage._();

  ProfilePageStatePage._();*/

  late MergeChildParent mergeChildParent;
  late MoreaFirebase moreaFire;
  late CrudMedthods crud0;
  late ChildParendPend childParendPend;
  bool hatEltern = false,
      hatKinder = false,
      display = false,
      upgradeKidDisplay = false,
      newKidDisplay = false;
  var controller = new StreamController<bool>();
  List elternMapList = ['Liam Bebecho'], kinderMapList = ['Walter'];
  late Map<String, dynamic> childToUpgradeMap;
  late Map<String, dynamic> profile;

  void reload() async {
    controller.add(false);

    var newData = await moreaFire.getUserInformation(this.profile['UID']);
    if (newData.data != this.profile) {
      this.profile = newData.data()! as Map<String, dynamic>;
      erziungsberechtigte();
    }
  }

  Future<void> erziungsberechtigte() async {
    if ((this.profile.containsKey("Eltern")) &&
        (this.profile['Eltern'].length != 0)) {
      await getElternMap();
      hatEltern = true;
      setState(() {});
    } else {
      hatEltern = false;
    }
  }

  Future<void> getkinder() async {
    this.profile = (await crud0.getDocument(pathUser, this.profile[userMapUID])).data()! as Map<String, dynamic>;
    if ((this.profile['Kinder'] != null) &&
        (this.profile['Kinder'].length != 0)) {
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
    } else {
      display = true;
      documentChangeListender();
    }
    setState(() {});
  }

  void documentChangeListender() async {
    await Future.delayed(Duration(seconds: 2));
    await childParendPend.waitOnUserDataChange(this.profile[userMapUID]);
    display = false;
    setState(() {});
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('Du wurdest mit deinem Elternteil verbunden.'),
            )).then((onvalue) => RestartWidget.restartApp(context));
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

  void upgradeKid(Map<String, dynamic> childMap) {
    if (upgradeKidDisplay) {
      upgradeKidDisplay = false;
    } else {
      upgradeKidDisplay = true;
    }
    this.childToUpgradeMap = childMap;
    setState(() {});
  }

  Future<void> getElternMap() async {
    List elternUID = List.from(this.profile['Eltern'].keys);
    for (int i = 0; i < elternUID.length; i++) {
      var elternData = await moreaFire.getUserInformation(elternUID[i]);
      if (i == 0) {
        elternMapList[0] = elternData.data();
      } else {
        elternMapList.add(elternData.data());
      }
    }
    return null;
  }

  Future<void> getKindernMap() async {
    print("kinder: " + this.profile['Kinder'].toString());
    List kinderUID = List.from(this.profile['Kinder'].keys);
    for (int i = 0; i < kinderUID.length; i++) {
      var kinderData = await moreaFire.getUserInformation(kinderUID[i]);
      if (i == 0) {
        kinderMapList[0] = kinderData.data();
        print(kinderMapList.toString());
      } else {
        kinderMapList.add(kinderData.data());
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
    super.initState();
    this.profile = widget.profile;
    mergeChildParent = MergeChildParent(widget.crud0, widget.moreaFire);
    moreaFire = widget.moreaFire;
    crud0 = widget.crud0;
    childParendPend = ChildParendPend(
        crud0: widget.crud0, moreaFirebase: widget.moreaFire);
    if (this.profile['Pos'] == 'Teilnehmer') {
      reload();
      erziungsberechtigte();
    } else {
      getkinder();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.profile['Pos'] == 'Teilnehmer') {
      return Container(
          child: Scaffold(
              appBar: AppBar(
                title: Text(this.profile['Vorname'].toString()),
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
                            this.profile,
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
                title: Text(this.profile['Vorname'].toString()),
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
                        ? mergeChildParent.parentScannsQrCode(this.profile,
                            this.parentaktuallisieren, context, widget.signOut)
                        : Container(),
                  ),
                  new Align(
                      child: newKidDisplay
                          ? mergeChildParent.registernewChild(
                              this.profile,
                              context,
                              this.setProfileState,
                              this.newKidakt,
                              widget.signOut)
                          : Container()),
                  Align(
                      child: upgradeKidDisplay
                          ? mergeChildParent.upgradeChild(
                              context,
                              this.upgradeKid,
                              this.childToUpgradeMap,
                              widget.signOut)
                          : Container()),
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
              ElevatedButton(
                child: Text(
                  'Mit Eltern Koppeln',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () => {childaktuallisieren()},
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
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
              ElevatedButton(
                child: Text(
                  'MIT KIND VERBINDEN',
                  style: MoreaTextStyle.raisedButton,
                ),
                onPressed: () => parentaktuallisieren(),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Text(
                  'NEUES KIND REGISTRIEREN',
                  style: MoreaTextStyle.raisedButton,
                ),
                onPressed: () => this.newKidakt(),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
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
      return ListView.separated(
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
                kinderMap.containsKey("Email")
                    ? ListTile(
                        title: Text(
                          'E-Mail-Adresse',
                          style: MoreaTextStyle.lable,
                        ),
                        subtitle: Text(
                          kinderMap['Email'],
                          style: MoreaTextStyle.normal,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 15, bottom: 20),
                        child: ElevatedButton(
                          child: Text(
                            'ACCOUNT ERSTELLEN',
                            style: MoreaTextStyle.raisedButton,
                          ),
                          onPressed: () => showUpgradeWarning(kinderMap),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xff7a62ff)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
        separatorBuilder: (context, int index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10),
          );
        },
      );
    } else {
      return Container();
    }
  }

  showUpgradeWarning(Map<String, dynamic> childMap) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Achtung',
                style: MoreaTextStyle.warningTitle,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Bist du sicher, dass du für dein Kind ${childMap["Vorname"]} einen vollständigen Account machen willst?',
                    style: MoreaTextStyle.normal,
                  ),
                  Text(
                    'Das braucht ${childMap["Vorname"]} nur, wenn er auf seinem eigenen Handy die Pfadi Morea App haben will.',
                    style: MoreaTextStyle.normal,
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text(
                    'Abbrechen',
                    style: MoreaTextStyle.flatButton,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)))),
                ),
                ElevatedButton(
                  child: Text(
                    'Account erstellen',
                    style: MoreaTextStyle.raisedButton,
                  ),
                  onPressed: () {
                    this.upgradeKid(childMap);
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xff7a62ff)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 5),
                )
              ],
            ));
  }
}
