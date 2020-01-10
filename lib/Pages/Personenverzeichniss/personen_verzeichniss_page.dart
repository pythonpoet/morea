import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Personenverzeichniss/view_userprofile_page.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';

class PersonenVerzeichnisState extends StatefulWidget {
  PersonenVerzeichnisState({this.moreaFire, this.crud0});
  final MoreaFirebase moreaFire;
  final CrudMedthods crud0;
  @override
  State<StatefulWidget> createState() => PersonenVerzeichnisStatePage();
}

class PersonenVerzeichnisStatePage extends State<PersonenVerzeichnisState> with TickerProviderStateMixin{
  MoreaLoading moreaLoading;

  
  @override
  void initState() {
    moreaLoading = new MoreaLoading(this);
    super.initState();
    
  }
  @override
  void dispose() {
    moreaLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
    length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Personen'),
          backgroundColor: Color(0xff7a62ff),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Drason',
              ),
              
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            personen("4013")
          ],
        ),
      ),
    );
  }

  Widget personen(String groupID){
    return Container(
      child: FutureBuilder(
        future: widget.crud0.getDocument(pathGroups,groupID),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> groupSnap){
          if(!groupSnap.hasData)
          return moreaLoading.loading();
          List<Map<String,Map<String,dynamic>>> person = new List();

          Map<String,dynamic>.from(groupSnap.data[groupMapPriviledge]).forEach((k,v) => person.add({k:Map<String,dynamic>.from(v)}));
          return Container(
            child: ListView.builder(
              itemCount: person.length,
              itemBuilder: (context, int index){
                print(person[index].values.firstWhere((k,v){
                  return false;
                }));
                return ListTile(
                  title: new Text("2"),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  /*navigatetoprofile(userdata){
    Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new ViewUserProfilePageState( qsAllUsers, Map<String,dynamic>.from(userdata))));
  }*/
}