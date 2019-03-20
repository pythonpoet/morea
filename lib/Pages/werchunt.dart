import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';

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
  List<String> lchunt, lchuntnoed;


  void getuserinfo()async {
   await auth0.getUserInformation().then((results) {
      setState(() {
        qsuserInfo = results;
        _pfadiname = qsuserInfo.data['Pfadinamen'];
        _stufe = qsuserInfo.data['Stufe'];
      });
    });
  }
  void sortlist()async{
    print(widget.userInfo['Stufe']);
    QuerySnapshot qsdata = await Firestore.instance.collection('uebung')
       .document(widget.userInfo['Stufe']).collection(auth0.getuebungsdatum())
      .getDocuments();
      
      print(qsdata.documents.length);
      for(int i; i < qsdata.documents.length; i++){
        print(i);
        if(qsdata.documents[i]['Anmeldung']=='Chunt'){
          lchunt.add(qsdata.documents[i]['Anmledename']);
        }else if(qsdata.documents[i]['Anmeldung']=='Chunt nöd'){
          lchuntnoed.add(qsdata.documents[i]['Anmledename']);
        }else{
          print('Firesotre für uebung anmelden ist komisch');
        }
        
      }
      print(lchunt);
      print(lchuntnoed);      
  }
  @override
  void initState() {
    super.initState();
     getuserinfo();
    sortlist();
  }

  @override
  Widget build(BuildContext context) {
    
    return new DefaultTabController(
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
   Stream<QuerySnapshot> qsdata = Firestore.instance.collection('uebung')
       .document(_stufe).collection(auth0.getuebungsdatum())
       .snapshots();
   return new Scaffold(
       body: StreamBuilder(
           stream: qsdata,
           builder: (context, AsyncSnapshot<QuerySnapshot> qsdata) {
             if (!qsdata.hasData) return Text('Loading data.. Please waint..');
             return ListView.builder(
                 itemExtent: 80.0,
                 itemCount: qsdata.data.documents.length,
                 itemBuilder: (context, int index) {
                   final DocumentSnapshot _info = qsdata.data.documents[index];
                   if (_info['Anmeldung'] == 'Chunt') {
                     return new ListTile(
                         title: new Text(_info['Anmeldename'])
                     );
                   }else{
                     return SizedBox();

                   }
                 }

             );
           }
       )
   );
}
Widget chuntnoed(){
  Stream<QuerySnapshot> qsdata = Firestore.instance.collection('uebung')
      .document(_stufe).collection(auth0.getuebungsdatum())
      .snapshots();
  return StreamBuilder(
      stream: qsdata,
      builder: (context, AsyncSnapshot<QuerySnapshot> qsdata) {
        if (!qsdata.hasData) return Text('Loading data.. Please waint..');
        Text('Loadsdafklj');
        return ListView.builder(
            itemExtent: 80.0,
            itemCount: qsdata.data.documents.length,
            itemBuilder: (context, int index) {
              final DocumentSnapshot _info = qsdata.data.documents[index];
              if (_info['Anmeldung'] == 'Chunt nöd') {
                return new ListTile(
                    title: new Text(_info['Anmeldename'])
                );
              }else{
                return SizedBox();
              }
            }
        );
      }

  );
}
}
