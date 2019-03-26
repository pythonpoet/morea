import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_userprofile_page.dart';

class PersonenVerzeichnisState extends StatefulWidget {
  PersonenVerzeichnisState({this.userInfo});
  var userInfo;
  @override
  State<StatefulWidget> createState() => PersonenVerzeichnisStatePage();
}

class PersonenVerzeichnisStatePage extends State<PersonenVerzeichnisState> {
  Auth auth0 = new Auth();
  List woelfe=[' '], nahani=[' '], drason=[' '], biber=[' '], pios=[' '], leiter=[' '];
  final profilekey = new GlobalKey<FormState>();

  sortlist()async{
    await Firestore.instance.collection('user')
      .getDocuments().then((qsdata){
        for(int i=0; i < qsdata.documents.length; i++){
        switch (qsdata.documents[i].data['Stufe']) {
          case 'Wombat (Wölfe)':
            if(woelfe[0] == ' '){
            woelfe[0]=qsdata.documents[i].data;
            }else{
            woelfe.add(qsdata.documents[i].data);
            }  
            break;
          case 'Nahani (Meitli)':
            if(nahani[0] == ' '){
            nahani[0]=qsdata.documents[i].data;
            }else{
            nahani.add(qsdata.documents[i].data);
            }  
            break;
          case 'Drason (Buebe)':
            if(drason[0] == ' '){
            drason[0]=qsdata.documents[i].data;
            }else{
            drason.add(qsdata.documents[i].data);
            }  
            break;
          case 'Biber':
            if(biber[0] == ' '){
            biber[0]=qsdata.documents[i].data;
            }else{
            biber.add(qsdata.documents[i].data);
            }  
            break;
          case 'Pios':
            if(pios[0] == ' '){
            pios[0]=qsdata.documents[i].data;
            }else{
            pios.add(qsdata.documents[i].data);
            }  
            break;
        }
        if(qsdata.documents[i].data['Stufe']=='Leiter'){
          if(leiter[0].isEmpty){
            leiter[0]=qsdata.documents[i].data;
          }else{
            leiter.add(qsdata.documents[i].data);
          }  
        }
      }
    });
    setState((){});
  }
  viewprofile(context, profile){
    showDialog(
      context: context,
      builder: (_) => 
        new SimpleDialog(
          children: <Widget>[
           Form(
             key: profilekey,
             child: Container(
               child: Column(
                 children: <Widget>[
                   TextFormField(
                     decoration: InputDecoration(
                       labelText: 'Vorname'
                     ),
                     initialValue: profile['Vorname'],
                     validator: (value) =>
                      value.isEmpty ? 'Vorname darf nicht leer sein' : null,
                      onSaved: (value) => profile['Vorname'] = value,
                   )
                 ],
               ),
             )
           )
          ],
        )
    );
    
    
  }
  @override
  void initState() {
    super.initState();
    sortlist();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
    length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('User'),
          backgroundColor: Color(0xff7a62ff),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Wölf',
              ),
              Tab(
                text: 'Nahanis',
              ),
              Tab(
                text: 'Drason',
              ),
              Tab(
                text: 'Biber',
              ),
              Tab(
                text: 'Pios'
                )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            woelfstufe(),
            nahanisstufe(),
            drasonstufe(),
            biberstufe(),
            piosstufe()
          ],
        ),
      ),
    );
  }
  Widget woelfstufe(){
    if(woelfe[0] !=' '){
      return Container(
              child: ListView.builder(
                itemCount: woelfe.length,
                itemBuilder: (context , int index){
                  if(woelfe[index]['Pfadinamen'].toString()== ''){
                    return new ListTile(
                    title: new Text(woelfe[index]['Vorname'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: woelfe[index],))));
                  }else{
                    return new ListTile(
                    title: new Text(woelfe[index]['Pfadinamen'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: woelfe[index],))));
                  }
                  
                }
              ),
            );
    }else{
      return new Center(
        child: new Text('Für diese Stufe ist niemand registriert', style: TextStyle(fontSize: 20)),
      );
    }
  }
  Widget nahanisstufe(){
    if(nahani[0] !=' '){
      return Container(
              child: ListView.builder(
                itemCount: nahani.length,
                itemBuilder: (context , int index){
                  if(nahani[index]['Pfadinamen'].toString()== ''){
                    return new ListTile(
                    title: new Text(nahani[index]['Vorname'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: nahani[index],))));
                  }else{
                    return new ListTile(
                    title: new Text(nahani[index]['Pfadinamen'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: nahani[index],))));
                  }
                  
                }
              ),
            );
    }else{
      return new Center(
        child: new Text('Für diese Stufe ist niemand registriert', style: TextStyle(fontSize: 20)),
      );
    }
  }
  Widget drasonstufe(){
    if(drason[0] !=' '){
      return Container(
              child: ListView.builder(
                itemCount: drason.length,
                itemBuilder: (context , int index){
                  if(drason[index]['Pfadinamen'].toString()== ''){
                    return new ListTile(
                    title: new Text(drason[index]['Vorname'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: drason[index],)))
                    );
                  }else{
                    return new ListTile(
                    title: new Text(drason[index]['Pfadinamen'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: drason[index],))));
                  }
                  
                }
              ),
            );
    }else{
      return new Center(
        child: new Text('Für diese Stufe ist niemand registriert', style: TextStyle(fontSize: 20)),
      );
    }
  }
  Widget biberstufe(){
    if(biber[0] !=' '){
      return Container(
              child: ListView.builder(
                itemCount: biber.length,
                itemBuilder: (context , int index){
                  if(biber[index]['Pfadinamen'].toString()== ''){
                    return new ListTile(
                    title: new Text(biber[index]['Vorname'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: biber[index],))));
                  }else{
                    return new ListTile(
                    title: new Text(biber[index]['Pfadinamen'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: biber[index],))));
                  }
                  
                }
              ),
            );
    }else{
      return new Center(
        child: new Text('Für diese Stufe ist niemand registriert', style: TextStyle(fontSize: 20)),
      );
    }
  }
  Widget piosstufe(){
    if(pios[0] !=' '){
      return Container(
              child: ListView.builder(
                itemCount: pios.length,
                itemBuilder: (context , int index){
                  if(pios[index]['Pfadinamen'].toString() == ''){
                    return new ListTile(
                    title: new Text(pios[index]['Vorname'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: pios[index],))));
                  }else{
                    return new ListTile(
                    title: new Text(pios[index]['Pfadinamen'].toString()),
                    onTap:  () => Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new ViewUserProfilePageState(profile: pios[index],))));
                  }
                  
                }
              ),
            );
    }else{
      return new Center(
        child: new Text('Für diese Stufe ist niemand registriert', style: TextStyle(fontSize: 20)),
      );
    }
  }
}