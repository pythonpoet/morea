import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/mailchimp_api_manager.dart';
import 'package:showcaseview/showcaseview.dart';
import 'change_profil.dart';

class Profile extends StatefulWidget {
  final auth;
  final MoreaFirebase moreaFire;
  final Map<String, Function> navigationMap;
  final FirebaseFirestore firestore;

  Profile(
      {required this.auth,
      required this.moreaFire,
      required this.navigationMap,
      required this.firestore});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Map userInfo;
  List nachrichtenGruppen = [];
  Auth auth0 = Auth();
  TextEditingController password = TextEditingController();
  MailChimpAPIManager mailChimpAPIManager = MailChimpAPIManager();
  late CrudMedthods crud0;
  GlobalKey _floatingActionButtonKey = GlobalKey();
  GlobalKey _floatingActionButtonKey2 = GlobalKey();

  _ProfileState();

  @override
  void initState() {
    super.initState();
    this.userInfo = widget.moreaFire.getUserMap;
    crud0 = CrudMedthods(widget.firestore);
  }

  @override
  Widget build(BuildContext context) {
    if (this.userInfo['Pfadinamen'] == null) {
      this.userInfo['Pfadinamen'] = '';
    }
    return Scaffold(
      backgroundColor: MoreaColors.bottomAppBar,
      drawer: moreaDrawer(
          this.userInfo['Pos'],
          widget.moreaFire.getDisplayName!,
          this.userInfo['Email'],
          context,
          widget.moreaFire,
          crud0,
          _signedOut),
      floatingActionButtonLocation: _locationFloatingActionButton(),
      floatingActionButton: Showcase(
        key: _floatingActionButtonKey,
        targetShapeBorder: CircleBorder(),
        description: 'Hier kannst du dein Profil ändern',
        disableMovingAnimation: true,
        child: Showcase.withWidget(
          key: _floatingActionButtonKey2,
          disableMovingAnimation: true,
          targetShapeBorder: CircleBorder(),
          height: 300,
          width: 150,
          container: Container(
            padding: EdgeInsets.all(5),
            constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: Colors.white),
            child: Column(
              children: [
                Text(
                  'Anpassung an deinem Profil hier, ändern auch dein Profil für den E-Mail-Verteiler',
                ),
              ],
            ),
          ),
          child: moreaEditActionbutton(
              route: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ChangeProfile(
                      auth: widget.auth,
                      moreaFire: widget.moreaFire,
                      navigationMap: widget.navigationMap,
                      updateProfile: updateProfile,
                      crud0: crud0,
                    );
                  }))),
        ),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Profil',
                    style: MoreaTextStyle.title,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Name',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      userInfo['Pfadinamen'] == ''
                          ? userInfo['Vorname'] + ' ' + userInfo['Nachname']
                          : userInfo['Vorname'] +
                              ' ' +
                              userInfo['Nachname'] +
                              ' v/o ' +
                              userInfo['Pfadinamen'],
                      style: MoreaTextStyle.subtitle,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.only(left: 15, right: 15, bottom: 5),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Adresse',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          userInfo['Adresse'] + ', ',
                          style: MoreaTextStyle.subtitle,
                        ),
                        Text(
                          userInfo['PLZ'] + ' ' + userInfo['Ort'],
                          style: MoreaTextStyle.subtitle,
                        )
                      ],
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'E-Mail-Adresse',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      userInfo['Email'],
                      style: MoreaTextStyle.subtitle,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Handynummer',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      userInfo['Handynummer'],
                      style: MoreaTextStyle.subtitle,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Geschlecht',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      userInfo['Geschlecht'],
                      style: MoreaTextStyle.subtitle,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                userInfo.containsKey("Geburtstag")
                    ? ListTile(
                        title: Text(
                          'Geburtstag',
                          style: MoreaTextStyle.lable,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            userInfo['Geburtstag'],
                            style: MoreaTextStyle.subtitle,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(
                            left: 15, right: 15, bottom: 5, top: 5),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: MoreaColors.orange,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => tutorial(),
          )
        ],
      ),
      bottomNavigationBar: _bottomAppBarBuilder(),
    );
  }

  void _signedOut() {
    widget.navigationMap[signedOut]!();
  }

  void updateProfile() async {
    await widget.moreaFire.getData(userInfo['UID']);
    this.userInfo = widget.moreaFire.getUserMap;
  }

  FloatingActionButtonLocation _locationFloatingActionButton() {
    if (widget.moreaFire.getPos == "Leiter") {
      return FloatingActionButtonLocation.centerDocked;
    } else {
      return FloatingActionButtonLocation.endFloat;
    }
  }

  BottomAppBar _bottomAppBarBuilder() {
    if (widget.moreaFire.getPos == "Leiter") {
      return moreaLeiterBottomAppBar(
          widget.navigationMap, 'Ändern', MoreaBottomAppBarActivePage.profile);
    } else {
      return moreaChildBottomAppBar(widget.navigationMap);
    }
  }

  void tutorial() {
    ShowCaseWidget.of(context)
        .startShowCase([_floatingActionButtonKey, _floatingActionButtonKey2]);
  }
}
