import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Grundbausteine/root_page.dart';
import 'package:morea/Widgets/standart/restartWidget.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/utilities/notification.dart';
import 'morealayout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    )
  );
  notificationGetPermission();
  runApp(RestartWidget(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  final Firestore firestore = new Firestore();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Pfadi Morea',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        appBarTheme: AppBarTheme(color: MoreaColors.orange, brightness: Brightness.light),
        primaryIconTheme: IconThemeData(color: Colors.black),
        primaryTextTheme: TextTheme(
          title: TextStyle(color: Colors.black),
          display1: TextStyle(color: Colors.black),
          display2: TextStyle(color: Colors.black),
          display3: TextStyle(color: Colors.black),
          display4: TextStyle(color: Colors.black),
          body1: TextStyle(color: Colors.black),
          body2: TextStyle(color: Colors.black),
          headline: TextStyle(color: Colors.black),
          subhead: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.black),
          button: TextStyle(color: Colors.black),
          subtitle: TextStyle(color: Colors.black),
          overline: TextStyle(color: Colors.black),
        ),
        primarySwatch: MaterialColor(
            MoreaColors.violettInt, MoreaColors.violettMaterialColor),
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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('de', 'CH'),
      ],
    );
  }
}
