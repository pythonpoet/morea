import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Grundbausteine/login_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/services/auth.dart';
import 'package:intl/date_symbol_data_local.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth, this.firestore});

  final BaseAuth auth;
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

enum AuthStatus { notSignedIn, homePage, messagePage, agendaPage, profilePage }

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.homePage;
      });
    });
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
        break;

      case AuthStatus.messagePage:
        return MessagesPage(

        );
        break;

      case AuthStatus.agendaPage:
        // TODO: Handle this case.
        break;

      case AuthStatus.profilePage:
        // TODO: Handle this case.
        break;
    }
  }
}
