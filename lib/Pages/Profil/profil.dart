import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Profil/change_phone_number.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/mailchimp_api_manager.dart';
import 'package:morea/services/utilities/url_launcher.dart';

import 'change_address.dart';
import 'change_email.dart';
import 'change_message_groups.dart';
import 'change_name.dart';
import 'change_password.dart';
import 'change_profil.dart';

class Profile extends StatefulWidget {
  final auth;
  final MoreaFirebase moreaFire;
  final Map<String, Function> navigationMap;
  final Firestore firestore;

  Profile(
      {@required this.auth,
      @required this.moreaFire,
      @required this.navigationMap,
      @required this.firestore});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map userInfo;
  List nachrichtenGruppen = [];
  Auth auth0 = Auth();
  TextEditingController password = TextEditingController();
  final _passwordKey = GlobalKey<FormState>();
  String oldEmail;
  String newPassword;
  MailChimpAPIManager mailChimpAPIManager = MailChimpAPIManager();
  Urllauncher urllauncher = Urllauncher();
  CrudMedthods crud0;

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
      this.userInfo['Pfadinamen'] = this.userInfo['Name'];
    }
    return Scaffold(
      drawer: moreaDrawer(this.userInfo['Pos'], widget.moreaFire.getDisplayName, this.userInfo['Email'], context, widget.moreaFire, crud0, _signedOut),
      floatingActionButtonLocation: _locationFloatingActionButton(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        backgroundColor: MoreaColors.violett,
        shape: CircleBorder(side: BorderSide(color: Colors.white)),
        onPressed: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ChangeProfile(
            auth: widget.auth,
            moreaFire: widget.moreaFire,
            navigationMap: widget.navigationMap,
            updateProfile: updateProfile,
          );
        })),
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
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Name',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Text(
                    userInfo['Vorname'] +
                        ' ' +
                        userInfo['Nachname'] +
                        ' v/o ' +
                        userInfo['Pfadinamen'],
                    style: MoreaTextStyle.normal,
                  ),
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
                  subtitle: Text(
                    userInfo['Adresse'] +
                        ', ' +
                        userInfo['PLZ'] +
                        ' ' +
                        userInfo['Ort'],
                    style: MoreaTextStyle.normal,
                  ),
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
                    subtitle: Text(
                      userInfo['Email'],
                      style: MoreaTextStyle.normal,
                    ),
                    onTap: () => urllauncher.openMail(userInfo['Email'])),
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
                  subtitle: Text(
                    userInfo['Handynummer'],
                    style: MoreaTextStyle.normal,
                  ),
                  onTap: () => urllauncher.openPhone(userInfo['Handynummer']),
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
                  subtitle: Text(
                    userInfo['Geschlecht'],
                    style: MoreaTextStyle.normal,
                  ),
                ),Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 1,
                      color: Colors.black26,
                    )),
                ListTile(
                  title: Text(
                    'Geburtstag',
                    style: MoreaTextStyle.lable,
                  ),
                  subtitle: Text(
                    userInfo['Geburtstag'],
                    style: MoreaTextStyle.normal,
                  ),
                ),
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
      ),
      bottomNavigationBar: _bottomAppBarBuilder(),
    );
  }

  void _signedOut() async {
    try {
      await widget.auth.signOut();

      widget.navigationMap[signedOut]();
    } catch (e) {
      print(e);
    }
  }

  void updateProfile() async{
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
      return moreaLeiterBottomAppBar(widget.navigationMap, 'Ändern');
    } else {
      return moreaChildBottomAppBar(widget.navigationMap);
    }
  }
}
