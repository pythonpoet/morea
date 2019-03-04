import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';

class WerChunt extends StatefulWidget {
  WerChunt({this.auth, this.onSigedOut, this.crud});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BasecrudMethods crud;
  @override
  State<StatefulWidget> createState() => _WerChuntState();
}
enum FormType {
  leiter,
  teilnemer,
  eltern
}
class _WerChuntState extends State<WerChunt> {
  Auth auth0 = new Auth();
  final formKey = new GlobalKey<FormState>();
  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.teilnemer;

  String _pfadiname,_userUID,_stufe;
  DocumentSnapshot qsuserInfo, dsanmeldedat;
  Map<String,String> anmeldeDaten;
  String TNS;




  void getuserinfo(){
    auth0.getUserInformation().then((results){
      setState(() {
        qsuserInfo = results;
        _pfadiname = qsuserInfo.data['Pfadinamen'];
        _stufe = qsuserInfo.data['Stufe'];
      });
    });
  }
  void gettns(){
    List<String> chunt = new List();
    List<String> nchunt = new List();
    /*
  auth0.getTNs(_stufe).then((results){
    dsanmeldedat = results;
    });*/
  /*
   TNS = dsanmeldedat.data.toString();
   bool i = true;
   int pos=1,posbis;
   print(TNS);
   while (i){
     posbis  = TNS.indexOf(': Chunt',pos);
     if(posbis == -1){
       i = false;
     }else {
       chunt.add(TNS.substring(pos, posbis));
       pos = posbis + ': Chunt'.length;
     }
     i = true;
   }
    while (i){
      posbis  = TNS.indexOf(': NChunt',pos);
      if(posbis == -1){
        i = false;
      }else {
        nchunt.add(TNS.substring(pos, posbis));
        pos = posbis + ': NChunt'.length;
      }
    }
   print(chunt);
   print(nchunt);
   pos = TNS.indexOf(': Chunt',pos);
   print('pos:'+ pos.toString());
*/
}
  Widget _buildListItem(BuildContext context, DocumentSnapshot document){
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
                document['name'],
            ),
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    getuserinfo();
    gettns();
    Stream<QuerySnapshot> qsdata = Firestore.instance.collection('uebung').document(_stufe).collection(auth0.getuebungsdatum()).snapshots();


    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Werchunt'),
      ),
      body: StreamBuilder(
        stream: qsdata,
        builder: (context, qsdata){
          if(!qsdata.hasData) return Text('Loading data.. Please waint..');
          return ListView.builder(
            itemExtent: 80.0,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
                _buildListItem(context, _b))
          );

        }
      )
    );
  }

  List<Widget>TNanzeigen(){
    return [
      new Text(snap)
    ];
  }
  }

