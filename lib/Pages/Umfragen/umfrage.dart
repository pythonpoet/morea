import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';

class Umfrage extends StatefulWidget {
  @override
  _UmfrageState createState() => _UmfrageState();
}

class _UmfrageState extends State<Umfrage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        backgroundColor: MoreaColors.violett,
        shape: CircleBorder(
          side: BorderSide(color: Colors.white)
        ),
        child: Icon(Icons.person_add),
        onPressed: null,
      ),
      body: MoreaBackgroundContainer(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              elevation: 10,
              pinned: true,
              floating: false,
              expandedHeight: 200,
              backgroundColor: MoreaColors.orange,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text('Test', style: MoreaTextStyle.title,),
              ),
            ),
            SliverFillRemaining(
              child: Column(

              ),
            )
          ],
        ),
      ),
    );
  }
}
