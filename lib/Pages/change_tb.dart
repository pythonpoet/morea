import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';
import '../services/tb_service.dart';

class ChangeTB extends StatefulWidget {
  ChangeTB({this.auth, this.onSigedOut, this.crud, Key key}) : super(key: key);

  final String title = "Teleblitz Ändern";
  final String filter = "Biber";
  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BasecrudMethods crud;
  @override
  State<StatefulWidget> createState() => _ChangeTBState();
}

class _ChangeTBState extends State<ChangeTB> {
  Auth auth0 = new Auth();
  final formKey = new GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Container(
        child: FutureBuilder(
            future: GetTB(widget.filter).getInfos(),
            builder: (BuildContext context, AsyncSnapshot snapshot){

              if(snapshot.data == null){
                return Container(
                  child: Center(
                    child: Text("Loading..."),
                  ),
                );
              } else {
                return Column(
                    children: [
                      Container(
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: <Widget>[
                              snapshot.data.getTitel(),
                            ],),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.16), offset: Offset(3, 3), blurRadius: 40)],
                          )
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        child: GridView.count(
                                crossAxisCount: 2,
                                children: <Widget>[
                                  TextFormField(
                                    initialValue: snapshot.data.datum,
                                  )
                                ]
                        ),
                      ),

                        Expanded(child: Container()),
                    ]
                );
              }
            }
        ),

      ),
    );
  }
}