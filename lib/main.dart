import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Grundbausteine/login_page.dart';
import 'package:morea/Pages/Grundbausteine/root_page.dart';
import 'package:morea/Widgets/standart/restartWidget.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/utilities/notification.dart';
import 'morealayout.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationGetPermission();
  runApp(RestartWidget(child: MyApp(),));
}

class MyApp extends StatelessWidget {
  final Firestore firestore = new Firestore();
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Pfadi Morea',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        backgroundColor: Colors.white,
        primarySwatch: MaterialColor(
            MoreaColors.appBarInt, MoreaColors.violettMaterialColor),
        fontFamily: 'Raleway',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [MoreaColors.orange, MoreaColors.bottomAppBar],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: RootPage(
              auth: Auth(),
              firestore: firestore,
            )),
      },
    );
  }
}

