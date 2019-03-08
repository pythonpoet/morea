import 'package:flutter/material.dart';
import 'home_page.dart';


class EventState extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text('Events'),
          ),
          body: new Center(
            child: new Text('Noch keine Inhalte',style: new TextStyle(fontSize: 20),),
          ),
        )
    );
  }
}