
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/services/Teleblitz/teleblitzAnmeldungen.dart';

class WerChunt extends StatefulWidget {
  WerChunt({ this.onSigedOut, this.firestore, this.eventID});
  final String eventID;
  final VoidCallback onSigedOut;
  final Firestore firestore;


  @override
  State<StatefulWidget> createState() => _WerChuntState();
}

class _WerChuntState extends State<WerChunt> {
  TeleblitzAnmeldungen teleblitzAnmeldungen;
  
  
  @override
  void initState() {
    teleblitzAnmeldungen = new TeleblitzAnmeldungen(widget.firestore, widget.eventID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
    length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Wer chunt?'),
          backgroundColor: Color(0xff7a62ff),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Chunt',
              ),
              Tab(
                text: 'Chunt nöd',
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Container(
              child: chunt(),
              height: 50,
            ),
           
            Container(
              child: chuntnoed(),
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
   
  Widget chunt(){
    return StreamBuilder(
      stream: teleblitzAnmeldungen.getAnmeldungen,
      builder: (context,  AsyncSnapshot<dynamic> aSAngemolden){
        if(!aSAngemolden.hasData) return moreaLoadingIndicator();
        if(aSAngemolden.data.length==0) return  Center(child:Text('Niemand hat sich angemolden', style: TextStyle(fontSize: 20),));
        return ListView.builder(
          itemCount: aSAngemolden.data.length,
          itemBuilder: (context, int index){
            return ListTile(
              title: new Text(aSAngemolden.data[index].toString()),
            );
          }
        );
      }
    );
  }
  Widget chuntnoed(){
    return StreamBuilder(
      stream: teleblitzAnmeldungen.getAbmeldungen,
      builder: (context, AsyncSnapshot<dynamic> asAbgemolden){
        if(!asAbgemolden.hasData) return moreaLoadingIndicator();
        if(asAbgemolden.data.length==0) return  Center(child:Text('Niemand hat sich abgemolden', style: TextStyle(fontSize: 20),));
        return ListView.builder(
          itemCount: asAbgemolden.data.length,
          itemBuilder: (context, int index){
            return ListTile(
              title: new Text(asAbgemolden.data[index].toString()),
            );
          }
        );
      }
    );
  }


}
