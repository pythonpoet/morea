import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'package:morea/Pages/Personenverzeichniss/profile_page.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/Pages/Teleblitz/werchunt.dart';
import 'package:morea/services/auth.dart';


class Navigationdrawer{


  Auth auth = new Auth();


  List<Widget> navigation_leiter(context, userInfo){
      return [
        new UserAccountsDrawerHeader(
          accountName: new Text(userInfo['Pfadinamen']),
          accountEmail: new Text(userInfo['Email']),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
        ),
        new ListTile(
            title: new Text('Wer chunt?'),
            trailing: new Icon(Icons.people),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new WerChunt(userInfo: userInfo,)))),
        new ListTile(
            title: new Text('Agenda'),
            trailing: new Icon(Icons.event),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new AgendaState(userInfo: userInfo,)))),
        new ListTile(
            title: new Text('Personen'),
            trailing: new Icon(Icons.people),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new PersonenVerzeichnisState()))),
        new Divider(),
        new ListTile(
          title: new Text('Logout'),
          trailing: new Icon(Icons.cancel),
          onTap: signedOut,
        )
      ];
  }
  List<Widget> navigation_teilnehmer(context, userInfo){
      return [
        new UserAccountsDrawerHeader(
          accountName: new Text(userInfo['Pfadiname']),
          accountEmail: new Text(userInfo['Email']),
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
        ),
        new ListTile(
            title: new Text('Agenda'),
            trailing: new Icon(Icons.event),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new AgendaState(userInfo: userInfo)))),
        new ListTile(
            title: new Text('Profil'),
            trailing: new Icon(Icons.person),
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new ProfilePageState(profile: userInfo)))),
        new Divider(),
        new ListTile(
          title: new Text('Logout'),
          trailing: new Icon(Icons.cancel),
          onTap: signedOut,
        )
    ];
  }

  void signedOut(){
   //hps.signedOut();
  }
}
