import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/crud.dart';
import 'werchunt.dart';

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

  String _pfadiname,_userUID,_stufe;
  DocumentSnapshot qsuserInfo;
  Map<String,String> anmeldeDaten;



  void submit(String anabmelden) {
    print(qsuserInfo.data['Pfadinamen']);
    anmeldeDaten = {
      this.qsuserInfo.data['Pfadinamen']: anabmelden
    };
    auth0.uebunganmelden(anmeldeDaten, _stufe);
  }
 void getuserinfo(){
  auth0.getUserInformation().then((results){
  setState(() {
  qsuserInfo = results;
  });
  try {
    _pfadiname = qsuserInfo.data['Pfadinamen'];
    _stufe = qsuserInfo.data['Stufe'];
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
      ),
      drawer: new Drawer(
        child: new ListView(
          children: Navigation()
        ),
      ),
      body: new Container(
        child: new Form(
            key: formKey,
          child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: teleblitz() + anmeldebutton()
           )
        ),
      ),
    );
  }

  List<Widget> Navigation(){
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
  List<Widget> teleblitz(){
    return[
      new Text('Teleblitz ${qsuserInfo.data['Stufe']}')
    ];
  }

  List<Widget> anmeldebutton(){
    return [
      new RaisedButton(
          child: new Text('Chume',style: new TextStyle(fontSize: 20)),
          onPressed: () => submit('Chunt')
      ),
      new RaisedButton(
          child: new Text('Chume nöd',style: new TextStyle(fontSize: 20)),
          onPressed: () => submit('Chunt nöd')
      ),
    ];
}

}

