import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
import 'package:morea/services/cloud_functions.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/blockedUserChecker.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../Widgets/standart/buttons.dart';
import '../../morea_strings.dart';

class RootPage extends StatefulWidget {
  RootPage({required this.auth, required this.firestore});

  final BaseAuth auth;
  final FirebaseFirestore firestore;

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
  profilePage,
  homePageTutorial
}

class _RootPageState extends State<RootPage> with TickerProviderStateMixin {
  Auth auth = Auth();
  AuthStatus authStatus = AuthStatus.loading;
  MoreaFirebase? moreaFire;
  late Map<String, Function> navigationMap;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initMoreaFire() async {
    this.moreaFire = new MoreaFirebase(widget.firestore);
    if (await this.moreaFire!.getData(await auth.currentUser()) == false) {
      setState(() {
        this.signedOut();
      });
    }
    await this.moreaFire!.initTeleblitz();
    FirebaseMessaging.onMessage.listen((message) {
      print("message recieved");
      if (message.data['typeMorea'] == 'Message') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Neue Nachricht'),
              actions: <Widget>[
                moreaRaisedButton('Ansehen', () {
                  Navigator.of(context).pop();
                  navigationMap[toMessagePage]!();
                }),
                moreaRaisedButton('Später', () {
                  Navigator.of(context).pop();
                })
              ],
            );
          },
        );
      }
    });
    authStatus = AuthStatus.homePage;
    setState(() {});
    return null;
  }

  Future authStatusInit() async {
    authStatus = await check4BlockedAuthStatus(
        await auth.currentUser(), widget.firestore);
    if (authStatus == AuthStatus.loading) {
      initMoreaFire();
    }
    setState(() {});
  }

  //initializes MoreaFirebase and downloads User Data with getData()

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: auth,
          onSignedIn: this.signedIn,
          firestore: widget.firestore,
        );

      case AuthStatus.homePage:
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) => HomePage(
              auth: auth,
              firestore: widget.firestore,
              navigationMap: navigationMap,
              moreafire: moreaFire!,
              tutorial: false,
            ),
          ),
        );
      case AuthStatus.homePageTutorial:
        return ShowCaseWidget(
          builder: Builder(
              builder: (contex) => HomePage(
                    auth: auth,
                    firestore: widget.firestore,
                    navigationMap: navigationMap,
                    moreafire: moreaFire!,
                    tutorial: true,
                  )),
        );
      case AuthStatus.blockedByAppVersion:
        return new BlockedByAppVersion();

      case AuthStatus.blockedByDevToken:
        return new BlockedByDevToken();

      case AuthStatus.messagePage:
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) => MessagesPage(
              auth: auth,
              moreaFire: moreaFire!,
              navigationMap: this.navigationMap,
              firestore: widget.firestore,
            ),
          ),
        );

      case AuthStatus.agendaPage:
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) => AgendaState(
              auth: auth,
              navigationMap: navigationMap,
              moreaFire: moreaFire!,
              firestore: widget.firestore,
            ),
          ),
        );

      case AuthStatus.profilePage:
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) => Profile(
              auth: auth,
              moreaFire: moreaFire!,
              navigationMap: navigationMap,
              firestore: widget.firestore,
            ),
          ),
        );
      case AuthStatus.loading:
        return MoreaLoadingWidget(this.signedOut);
      default:
        return MoreaLoadingWidget(this.signedOut);
    }
  }

  //Functions for the Navigation
  //Switches authStatus and rebuilds RootPage

  void signedIn({bool tutorialautostart = false}) async {
    await initMoreaFire();
    setState(() {
      if (tutorialautostart) {
        authStatus = AuthStatus.homePageTutorial;
      } else {
        authStatus = AuthStatus.homePage;
      }
    });
  }

  void homePage({dispose}) {
    if (!(authStatus == AuthStatus.homePage)) {
      if (dispose != null) {
        dispose();
      }
      try {
        setState(() {
          authStatus = AuthStatus.homePage;
        });
      } catch (e) {
        print(e);
      }
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

  void signedOut() async {
    setState(() {
      authStatus = AuthStatus.loading;
    });
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String deviceID;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      deviceID = androidDeviceInfo.id;
    } else {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      deviceID = iosDeviceInfo.identifierForVendor!;
    }
    await callFunction(getcallable("deactivateDeviceNotification"),
        param: {'uid': (auth.getUserID), 'deviceID': deviceID});
    await auth.signOut();
    await firebaseMessaging.deleteToken();
    moreaFire = null;
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }
}
