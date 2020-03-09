import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

import '../../morea_strings.dart';
import '../../morealayout.dart';

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
  profilePage,
  homePageTutorial
}

class _RootPageState extends State<RootPage> with TickerProviderStateMixin {
  Auth auth = Auth();
  AuthStatus authStatus = AuthStatus.loading;
  MoreaFirebase moreaFire;
  Map<String, Function> navigationMap;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

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
    firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: false));
  }

  @override
  void dispose() {
    print('disposing root');
    super.dispose();
  }

  Future<void> initMoreaFire() async {
    this.moreaFire = new MoreaFirebase(widget.firestore);
    await this.moreaFire.getData(await auth.currentUser());
    await this.moreaFire.initTeleblitz();
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print(message);
      if (message['data']['typeMorea'] == 'Message') {
        showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Neue Nachricht'),
                    actions: <Widget>[
                      RaisedButton(
                        color: MoreaColors.violett,
                        onPressed: () {
                          Navigator.of(context).pop();
                          navigationMap[toMessagePage]();
                        },
                        child: Text(
                          'Ansehen',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      RaisedButton(
                        color: MoreaColors.violett,
                        child: Text(
                          'Später',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
      }
    }, onResume: (Map<String, dynamic> message) async {
      print(message);
      if(message['data']['typeMorea'] == 'Message'){
        navigationMap[prefix0.toMessagePage]();
      }
    }, onLaunch: (Map<String, dynamic> message) async {
      print(message);
      if(message['data']['typeMorea'] == 'Message'){
        navigationMap[prefix0.toMessagePage]();
      }
    });
    authStatus = AuthStatus.homePage;
    setState(() {});
    return true;
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
        );
        break;

      case AuthStatus.homePage:
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) => HomePage(
              auth: auth,
              firestore: widget.firestore,
              navigationMap: navigationMap,
              moreafire: moreaFire,
              tutorial: false,
            ),
          ),
        );
        break;
      case AuthStatus.homePageTutorial:
        return ShowCaseWidget(
          builder: Builder(
            builder: (contex) => HomePage(
              auth: auth,
              firestore: widget.firestore,
              navigationMap: navigationMap,
              moreafire: moreaFire,
              tutorial: true,
          )
          ),
        );
      case AuthStatus.blockedByAppVersion:
        return new BlockedByAppVersion();
        break;

      case AuthStatus.blockedByDevToken:
        return new BlockedByDevToken();
        break;

      case AuthStatus.messagePage:
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) => MessagesPage(
              auth: auth,
              moreaFire: moreaFire,
              navigationMap: this.navigationMap,
              firestore: widget.firestore,
            ),
          ),
        );
        break;

      case AuthStatus.agendaPage:
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) => AgendaState(
              auth: auth,
              navigationMap: navigationMap,
              moreaFire: moreaFire,
              firestore: widget.firestore,
            ),
          ),
        );
        break;

      case AuthStatus.profilePage:
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) => Profile(
              auth: auth,
              moreaFire: moreaFire,
              navigationMap: navigationMap,
              firestore: widget.firestore,
            ),
          ),
        );
        break;
      case AuthStatus.loading:
        return MoreaLoadingWidget(this.signedOut);
        break;
      default:
        return MoreaLoadingWidget(this.signedOut);
    }
  }

  //Functions for the Navigation
  //Switches authStatus and rebuilds RootPage

  void signedIn({bool tutorialautostart}) async {
    await initMoreaFire();
    setState(() {
      if(tutorialautostart){
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
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String deviceID;
    if (Platform.isAndroid) if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      deviceID = androidDeviceInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      deviceID = iosDeviceInfo.identifierForVendor;
    }
    await callFunction(getcallable("deactivateDeviceNotification"),
        param: {'uid': (await auth.currentUser()), 'deviceID': deviceID});
    await auth.signOut();
    await firebaseMessaging.deleteInstanceID();
    moreaFire = null;
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }
}
