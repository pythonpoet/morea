import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Grundbausteine/root_page.dart';
import 'package:morea/Widgets/standart/restartWidget.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/utilities/notification.dart';
import 'morealayout.dart';
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentTabIndex = 0;

  onTapped(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), title: Text("Home")),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search), title: Text("Search")),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person), title: Text("User Info"))
          ]),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Text('Page 2 of tab $index'),
                  ),
                  child: Container(
                    color: Colors.blue,
                  ),
                );
                break;
              case 1:
                return Container(
                  color: Colors.red,
                );
                break;
              case 2:
                return Container(
                  color: Colors.green,
                );
                break;
              default:
                return Container(
                  color: Colors.yellow,
                );
                break;
            }
          });
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        // Body Where the content will be shown of each page index
        body: Container(),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentTabIndex,
            onTap: onTapped,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text("Home")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), title: Text("Search")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), title: Text("User Info"))
            ]),
      );
    }
  }
}
