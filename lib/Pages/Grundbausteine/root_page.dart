import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Grundbausteine/blockedByAppVersion_page.dart';
import 'package:morea/Pages/Grundbausteine/blockedByDevToken_page.dart';
import 'package:morea/Pages/Grundbausteine/login_page.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/services/auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:morea/services/utilities/blockedUserChecker.dart';

  


class RootPage extends StatefulWidget{
  RootPage({this.auth, this.firestore});
  final BaseAuth auth;
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

enum AuthStatus { notSignedIn, signedIn, blockedByAppVersion, blockedByDevToken}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    authStatusInit();
  }
  Future authStatusInit() async {
    authStatus = await check4BlockedAuthStatus(await widget.auth.currentUser(), widget.firestore);
    setState(()  {});
  }

  void signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context){
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: widget.auth,
          onSignedIn: signedIn,
        );

      case AuthStatus.signedIn:
        return new HomePage(
            auth: widget.auth,
          onSigedOut: signedOut,
          firestore: widget.firestore,
        );
      case AuthStatus.blockedByAppVersion:
        return new BlockedByAppVersion();

      case AuthStatus.blockedByDevToken:
        return new BlockedByDevToken();
    }
  }
}
