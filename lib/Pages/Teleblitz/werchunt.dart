import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:async/async.dart';

class WerChunt extends StatefulWidget {
  WerChunt({this.auth, this.onSigedOut, this.crud, this.userInfo});
  var userInfo;
  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BasecrudMethods crud;
  @override
  State<StatefulWidget> createState() => _WerChuntState();
}

class _WerChuntState extends State<WerChunt> {
  Auth auth0 = new Auth();
  final formKey = new GlobalKey<FormState>();


  String _pfadiname, _userUID, _stufe;
  DocumentSnapshot qsuserInfo, dsanmeldedat;
  Map<String, String> anmeldeDaten;
  List<String> lchunt=[' '], lchuntnoed=[' '];


  void getuserinfo()async {
   await auth0.getUserInformation().then((results) {
      setState(() {
        qsuserInfo = results;
        _pfadiname = qsuserInfo.data['Pfadinamen'];
        _stufe = qsuserInfo.data['Stufe'];
      });
    });
  }
 sortlist()async{
    String stufe = auth0.formatstring(widget.userInfo['Stufe']);
    QuerySnapshot qsdata = await Firestore.instance.collection('uebung')
       .document(stufe).collection(auth0.getuebungsdatum())
      .getDocuments();
      
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
      }
  }
  @override
  void initState() {
    super.initState();
     getuserinfo();
    sortlist();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
    length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Wer chunt?'),
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
