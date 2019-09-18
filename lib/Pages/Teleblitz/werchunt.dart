import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/Getteleblitz.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:async/async.dart';
import 'package:morea/services/dwi_format.dart';

class WerChunt extends StatefulWidget {
  WerChunt({this.auth, this.onSigedOut, this.crud, this.userInfo});
  var userInfo;
  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BaseCrudMethods crud;
  @override
  State<StatefulWidget> createState() => _WerChuntState();
}

class _WerChuntState extends State<WerChunt> {
  Auth auth0 = new Auth();
  final formKey = new GlobalKey<FormState>();
  Info teleblitzinfo = new Info();
  MoreaFirebase moreafire = new MoreaFirebase();
  DWIFormat dwiFormat = new DWIFormat();

  DocumentSnapshot qsuserInfo, dsanmeldedat;
  Map<String, String> anmeldeDaten;
  List<String> lchunt=[' '], lchuntnoed=[' '];


 sortlist()async{
    String stufe = dwiFormat.simplestring(widget.userInfo['Stufe']);
    String datum = dwiFormat.simplestring(teleblitzinfo.datum);

    QuerySnapshot qsdata = await moreafire.getTNs(stufe, datum);
      
      for(int i=0; i < qsdata.documents.length; i++){
        if(qsdata.documents[i].data['Anmeldung']=='Chunt'){
          if(lchunt[0]==' '){
            lchunt[0]=qsdata.documents[i].data['Anmeldename'];
          }else{
            lchunt.add(qsdata.documents[i].data['Anmeldename']);
          }  
        }else if(qsdata.documents[i].data['Anmeldung']=='Chunt nöd'){
          if(lchuntnoed[0]==' '){
            lchuntnoed[0]= qsdata.documents[i].data['Anmeldename'];
          }else{
             lchuntnoed.add(qsdata.documents[i].data['Anmeldename']);
          }           
        }else{
          print('Firesotre für uebung anmelden ist komisch');
        }
        setState(() {
          
        });
      }
}
  @override
  void initState() {
    sortlist();
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
            chunt(),
            chuntnoed()
          ],
        ),
      ),
    );
  }
  Widget chunt(){
    return Container(
              child: ListView.builder(
                itemCount: lchunt.length,
                itemBuilder: (context , int index){
                  return new ListTile(
                    title: new Text(lchunt[index]),
                  );
                }
              ),
            );
  }
  Widget chuntnoed(){
    return new Container(
      child: ListView.builder(
        itemCount: lchuntnoed.length,
        itemBuilder: (context , int index){
          return new ListTile(
            title: new Text(lchuntnoed[index]),
          );
        }
      ),
    );
  }


}
