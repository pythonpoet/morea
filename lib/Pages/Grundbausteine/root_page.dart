import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Grundbausteine/blockedByAppVersion_page.dart';
import 'package:morea/Pages/Grundbausteine/blockedByDevToken_page.dart';
import 'package:morea/Pages/Grundbausteine/login_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Profil/profil.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/morea_strings.dart' as prefix0;
import 'package:morea/services/auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/blockedUserChecker.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth, this.firestore});

  final BaseAuth auth;
  final Firestore firestore;

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

enum AuthStatus {
  loading,
  notSignedIn,
  blockedByAppVersion,
  blockedByDevToken,
  homePage,
  messagePage,
  agendaPage,
  profilePage
}

class _RootPageState extends State<RootPage> with TickerProviderStateMixin {
  Auth auth = Auth();
  AuthStatus authStatus = AuthStatus.loading;
  MoreaFirebase moreaFire;
  Map<String, Function> navigationMap;
  MoreaLoading moreaLoading;

  @override
  void initState() {
    super.initState();
    moreaLoading = MoreaLoading(this);
    initializeDateFormatting();
    authStatusInit();

    //für Navigation in den verschiedenen Pages
    navigationMap = {
      prefix0.signedIn: this.signedIn,
      prefix0.signedOut: this.signedOut,
      prefix0.toHomePage: this.homePage,
      prefix0.toMessagePage: this.messagePage,
      prefix0.toAgendaPage: this.agendaPage,
      prefix0.toProfilePage: this.profilePage,
    };
  }

  //Checks if App has the min required Version
  //Checks if User has been Blocked by DevToken
  //Checks if User is logged in or out
  //Returns the fitting AuthStatus

  Future authStatusInit() async {
    authStatus = await check4BlockedAuthStatus(
        await auth.currentUser(), widget.firestore);
    if (authStatus == AuthStatus.homePage) {
      await initMoreaFire();
    }
    setState(() {});
  }

  //initializes MoreaFirebase and downloads User Data with getData()

  Future<void> initMoreaFire() async {
    this.moreaFire = new MoreaFirebase(widget.firestore);
    await this.moreaFire.getData(await auth.currentUser());
    this.moreaFire.initTeleblitz();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: auth,
          onSignedIn: this.signedIn,
        );
        break;

      case AuthStatus.homePage:
        return new HomePage(
          auth: auth,
          firestore: widget.firestore,
          navigationMap: navigationMap,
        );
        break;
      case AuthStatus.blockedByAppVersion:
        return new BlockedByAppVersion();
        break;

      case AuthStatus.blockedByDevToken:
        return new BlockedByDevToken();
        break;

      case AuthStatus.messagePage:
        return MessagesPage(
          auth: auth,
          moreaFire: moreaFire,
          navigationMap: this.navigationMap,
        );
        break;

      case AuthStatus.agendaPage:
        return AgendaState(
          auth: auth,
          navigationMap: navigationMap,
          moreaFire: moreaFire,
          firestore: widget.firestore,
        );
        break;

      case AuthStatus.profilePage:
        return Profile(
          auth: auth,
          moreaFire: moreaFire,
          navigationMap: navigationMap,
        );
        break;
      case AuthStatus.loading:
        return Container(
          child: moreaLoading.loading(),
          color: Colors.white,
        );
        break;
    }
  }

  //Functions for the Navigation
  //Switches authStatus and rebuilds RootPage

  void signedIn() async {
    await initMoreaFire();
    setState(() {
      authStatus = AuthStatus.homePage;
    });
  }

  void homePage({dispose}) {
    if (!(authStatus == AuthStatus.homePage)) {
      if (dispose != null) {
        dispose();
      }
      setState(() {
        authStatus = AuthStatus.homePage;

      });
    }
  }

  void messagePage({dispose}) {
    if (!(authStatus == AuthStatus.messagePage)) {
      if (dispose != null) {
        dispose();
      }
      setState(() {
        authStatus = AuthStatus.messagePage;
      });
    }
  }

  void agendaPage({dispose}) {
    if (!(authStatus == AuthStatus.agendaPage)) {
      if (dispose != null) {
        dispose();
      }
      setState(() {
        authStatus = AuthStatus.agendaPage;

      });
    }
  }

  void profilePage({dispose}) {
    if (!(authStatus == AuthStatus.profilePage)) {
      setState(() {
        authStatus = AuthStatus.profilePage;
      });
    }
  }

  void signedOut() {
    moreaFire = null;
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }


}
