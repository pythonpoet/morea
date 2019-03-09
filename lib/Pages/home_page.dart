import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';
import 'werchunt.dart';
import 'change_tb.dart';


class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSigedOut, this.crud});

  final BaseAuth auth;
  final VoidCallback onSigedOut;
  final BasecrudMethods crud;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}
enum FormType {
leiter,
  teilnemer,
  eltern
}
class _HomePageState extends State<HomePage> {

  crudMedthods crud0bj = new crudMedthods();
  Auth auth0 = new Auth();

  final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.teilnemer;

  String _pfadiname = ' ',_userUID = ' ',_stufe = ' ';
  DocumentSnapshot qsuserInfo;
  Map<String,String> anmeldeDaten;



  void submit(String anabmelden) {
    String anmeldung;
    print(qsuserInfo.data['Pfadinamen']);
    anmeldeDaten = {
      'Anmeldename' : this.qsuserInfo.data['Pfadinamen'],
      'Anmeldung': anabmelden
    };
    if(anabmelden == 'Chunt'){
      anmeldung = 'Du hast dich Angemolden';
    }else{
      anmeldung = 'Du hast dich Abgemolden';
    }
    auth0.uebunganmelden(anmeldeDaten, _stufe,_userUID);
    showDialog(context: context, child:
    new AlertDialog(
      title: new Text("Teleblitz"),
      content: new Text(anmeldung),
    )
    );
  }
 void getuserinfo(){
   widget.auth.currentUser().then((userId){
       _userUID = userId;
   });
  auth0.getUserInformation().then((results){
  setState(() {
  qsuserInfo = results;
  });
  try {
    _pfadiname = qsuserInfo.data['Pfadinamen'];
    _stufe = qsuserInfo.data['Stufe'];

    if(_pfadiname == ' '){
      _pfadiname = qsuserInfo.data['Vorname'];
    }
  }catch(e){
    print(e);
  }
  });
}
  void _signedOut() async {
    try {
      await widget.auth.signOut();
      widget.onSigedOut();
    } catch (e) {
      print(e);
    }
  }
  void forminit(){
    try{
      switch(qsuserInfo.data['Pos']){
        case 'Leiter':
          _formType = FormType.leiter;
          break;
      }
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    getuserinfo();
    forminit();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Teleblitz'),
        backgroundColor: Color(0xff7a62ff),
      ),
      drawer: new Drawer(
        child: new ListView(
          children: navigation()
        ),
      ),
      body:Column(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints){
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                       Container(
                         height: 500,
                       )
                      ],
                    ),
                  ),
                );
              },
            )
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: anmeldebutton(),
            ),
          )
        ],
      )
    );
  }

  List<Widget> navigation(){
    if(_formType == FormType.leiter){
      return [
        new UserAccountsDrawerHeader(
          accountName: new Text(_pfadiname),
          accountEmail: new Text('jarvis@morea.ch'),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA')
              )
          ),
        ),
        new ListTile(
          title: new Text('Teleblitz'),
          trailing: new Icon(Icons.flash_on),
        ),
        new ListTile(
          title: new Text('Wer chunt?'),
          trailing: new Icon(Icons.people),
          onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=> new WerChunt()))
        ),
        new ListTile(
          title: new Text('Events'),
          trailing: new Icon(Icons.event),
        ),
        new ListTile(
          title: new Text('Profil'),
          trailing: new Icon(Icons.person),
        ),
        new Divider(),
        new ListTile(
          title: new Text('Logout'),
          trailing: new Icon(Icons.cancel),
          onTap: _signedOut,

        )
      ];
    }else{
        return[
        new UserAccountsDrawerHeader(
          accountName: new Text(_pfadiname),
          accountEmail: new Text('jarvis@morea.ch'),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA')
              )
          ),
        ),
      new ListTile(
      title: new Text('Teleblitz'),
      trailing: new Icon(Icons.flash_on),
      ),
      new ListTile(
      title: new Text('Events'),
      trailing: new Icon(Icons.event),
      ),
      new ListTile(
      title: new Text('Profil'),
      trailing: new Icon(Icons.person),
      ),
        new ListTile(
          title: new Text('Test'),
          trailing: new Icon(Icons.flash_on),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=> new ChangeTB()))
        ),
      new Divider(),
      new ListTile(
      title: new Text('Logout'),
      trailing: new Icon(Icons.cancel),
      onTap: _signedOut,

      )
      ];
    }

  }
//Hier soll der Teleblitz angezeigt werden


  List<Widget> anmeldebutton(){
    return [
      Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: new RaisedButton(
                  child: new Text('Chume nöd',style: new TextStyle(fontSize: 20)),
                  onPressed: () => submit('Chunt nöd'),
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xff7a62ff),
                textColor: Colors.white,
              ),
            )
          ),
          Expanded(
            child: Container(
              child: new RaisedButton(
              child: new Text('Chume',style: new TextStyle(fontSize: 20)),
              onPressed: () => submit('Chunt'),
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xFFFF9262),
              ),
            ),
          )
        ],
      )
    ];
}
}


