import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Grundbausteine/root_page.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'Pages/Grundbausteine/login_page.dart';
import 'morealayout.dart';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'Pfadi Morea',
    options: const FirebaseOptions(
      googleAppID: '1:20884476221:android:da0ee1d9ef987290793554',
      //gcmSenderID: '1015173140187',
      apiKey: 'AIzaSyBhmTHDLaRcXPGCuPXrHmG4nvks4_NezT0',
      projectID: 'dev-pfadi-morea',
    ),
  );
  final Firestore firestore = Firestore(app: app);
  await firestore.settings(timestampsInSnapshotsEnabled: true);

  runApp(
    MaterialApp(
        title: 'Morea App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: 'Raleway',
            primarySwatch: MaterialColor(
                MoreaColors.appBarInt, MoreaColors.violettMaterialColor)),
        home: MyApp(firestore: firestore)),
  );
}

class MyApp extends StatelessWidget {
  MyApp({this.firestore});

  final Firestore firestore;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Login',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: MaterialColor(
            MoreaColors.appBarInt, MoreaColors.violettMaterialColor),
      ),
      home: new RootPage(auth: new Auth(), firestore: firestore),
    );
  }
}
