import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/Pages/login_page.dart';
import 'package:morea/Pages/root_page.dart';

void main(){
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

    @override
  Widget build(BuildContext context) {

      return new MaterialApp(
        title: 'Flutter Login',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth()),
      );
  }
}