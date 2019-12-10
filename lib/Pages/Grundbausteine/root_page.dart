import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Grundbausteine/blockedByAppVersion_page.dart';
import 'package:morea/Pages/Grundbausteine/blockedByDevToken_page.dart';
import 'package:morea/Pages/Grundbausteine/login_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/services/auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:morea/services/utilities/blockedUserChecker.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth, this.firestore});

  final BaseAuth auth;
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

enum AuthStatus { notSignedIn, blockedByAppVersion, blockedByDevToken, homePage, messagePage, agendaPage, profilePage}

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
      authStatus = AuthStatus.homePage;
    });
  }

  void messagePage() {
    setState(() {
      authStatus = AuthStatus.messagePage;
    });
  }

  void agendaPage() {
    setState(() {
      authStatus = AuthStatus.agendaPage;
    });
  }

  void profilePage() {
    setState(() {
      authStatus = AuthStatus.profilePage;
    });
  }

  void signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: widget.auth,
          onSignedIn: signedIn,
        );
        break;

      case AuthStatus.homePage:
        return new HomePage(
          auth: widget.auth,
          onSigedOut: signedOut,
          firestore: widget.firestore,
        );
      case AuthStatus.blockedByAppVersion:
        return new BlockedByAppVersion();
        break;

      case AuthStatus.blockedByDevToken:
        return new BlockedByDevToken();
      break;

      case AuthStatus.messagePage:
        return MessagesPage();
        break;

      case AuthStatus.agendaPage:
        return Agenda();
        break;

      case AuthStatus.profilePage:
        return Profile();
        break;

    }
  }
}
