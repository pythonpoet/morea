import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void testFirebaseAuth() {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    print(_firebaseAuth.createUserWithEmailAndPassword(
        email: "adam@eva.mapf", password: "123456"));
  }

  void testCloudFunction() {
    Firestore.instance
        .collection('books')
        .document()
        .setData({'title': 'title', 'author': 'author'});
  }

  void testHttp() async {
    var url = 'http://example.com/whatsit/create';
    var response =
        await http.post(url, body: {'name': 'doodle', 'color': 'blue'});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    print(await http.read('https://morea.ch'));
  }

  void testIntl() {
    Intl.defaultLocale = 'pt_BR';
  }

  void testlaunchURL() async {
    const url = 'https://flutter.dev';
    print("object");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void testshare() {
    Share.share('check out my website https://example.com');
  }

  void testMaskedtext() {
    var controller = new MaskedTextController(mask: '000.000.000-00');
  }

  void testRandom() {
    print("RandomNumber" + randomBetween(10, 20).toString());
  }
  void testBarcodeScan(){
  BarcodeScanner.scan();
  }
  void testFCM(){
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  }

  Widget testButton(String text, Function execution) {
    return RaisedButton(
      child: Text(text),
      onPressed: execution,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("i Live");
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Testing libs for Pfadi Morea app"),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Test-Methods',
            ),
            testButton("AUTH", testFirebaseAuth),
            testButton("Firestore", this.testCloudFunction),
            testButton("HTTP", this.testHttp),
            testButton("Intl", this.testIntl),
            testButton("Launch URL", this.testlaunchURL),
            testButton("Random", this.testRandom),
            testButton("Share", this.testshare),
            testButton("Masket Text", testMaskedtext),
            testButton("Barconscann", this.testBarcodeScan),
            testButton("FCM", testFCM),
            ExpandablePanel(
              header: Text("Expanable"),
              collapsed: Text(
                "collapsed",
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              expanded: QrImage(
                data: 'This is a simple QR code',
                version: QrVersions.auto,
                size: 320,
                gapless: false,
              ),
              tapHeaderToExpand: true,
              hasIcon: true,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
