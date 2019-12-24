import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Personenverzeichniss/view_userprofile_page.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';

class PersonenVerzeichnisState extends StatefulWidget {
  PersonenVerzeichnisState({this.userInfo});
  final Map userInfo;
  @override
  State<StatefulWidget> createState() => PersonenVerzeichnisStatePage();
}

class PersonenVerzeichnisStatePage extends State<PersonenVerzeichnisState> {
  Auth auth0 = new Auth();
  List woelfe=[' '], nahani=[' '], drason=[' '], biber=[' '], pios=[' '], leiter=[' '];
  QuerySnapshot qsAllUsers;
  sortlist()async{
    await Firestore.instance.collection('user')
      .getDocuments().then((qsdata){
        qsAllUsers = qsdata;
        for(int i=0; i < qsdata.documents.length; i++){
        switch (qsdata.documents[i].data[userMapgroupID]) {
          case "3776":
            if(woelfe[0] == ' '){
            woelfe[0]=qsdata.documents[i].data;
            }else{
            woelfe.add(qsdata.documents[i].data);
            }  
            break;
          case "3776":
            if(nahani[0] == ' '){
            nahani[0]=qsdata.documents[i].data;
            }else{
            nahani.add(qsdata.documents[i].data);
            }  
            break;
          case '4013':
            if(drason[0] == ' '){
            drason[0]=qsdata.documents[i].data;
            }else{
            drason.add(qsdata.documents[i].data);
            }  
            break;
          case '3775':
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
                    onTap: () => navigatetoprofile(woelfe[index]));
                  }else{
                    return new ListTile(
                    title: new Text(woelfe[index]['Pfadinamen'].toString()),
                    onTap: () => navigatetoprofile(woelfe[index]));
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
                    onTap: () => navigatetoprofile(nahani[index]));
                  }else{
                    return new ListTile(
                    title: new Text(nahani[index]['Pfadinamen'].toString()),
                    onTap: () => navigatetoprofile(nahani[index]));
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
                    onTap: () => navigatetoprofile(drason[index])
                    );
                  }else{
                    return new ListTile(
                    title: new Text(drason[index]['Pfadinamen'].toString()),
                    onTap: () => navigatetoprofile(drason[index])
                    );
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
                    onTap: () => navigatetoprofile(biber[index]));
                  }else{
                    return new ListTile(
                    title: new Text(biber[index]['Pfadinamen'].toString()),
                    onTap: () => navigatetoprofile(biber[index]));
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
                    onTap: () => navigatetoprofile(pios[index]));
                  }else{
                    return new ListTile(
                    title: new Text(pios[index]['Pfadinamen'].toString()),
                    onTap: () => navigatetoprofile(pios[index]));
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
  navigatetoprofile(userdata){
    Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new ViewUserProfilePageState( qsAllUsers, Map<String,dynamic>.from(userdata))));
  }
}