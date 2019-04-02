import 'package:flutter/material.dart';
import 'edit_userprofile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewUserProfilePageState extends StatelessWidget {
  ViewUserProfilePageState({this.profile});
  var profile;

  _launchphone(phonenumber)async{
    String url = 'tel:<$phonenumber>';
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'Could not launch $url';
    }
  }
  _launchemail(email)async{
    String url = 'mailto:<$email>';
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            appBar: AppBar(
              title: Text(profile['Vorname'].toString()),
               backgroundColor: Color(0xff7a62ff),
            ),
            body: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                    child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: viewprofile(),
                ));
              },
            ),
            floatingActionButton: new FloatingActionButton(
              elevation: 1.0,
              child: new Icon(Icons.edit),
              backgroundColor: Color(0xff7a62ff),
              onPressed: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new EditUserProfilePage(profile: profile,)))
            )));
  }

  Widget viewprofile() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Vorname:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Vorname'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Nachname:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Nachname'],
                        style: TextStyle(fontSize: 20),
                      ))),
                      
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Pfadinamen:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Pfadinamen'],
                        style: TextStyle(fontSize: 20),
                      ))),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Rolle:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Pos'],
                        style: TextStyle(fontSize: 20),
                      ))),
                    ],
                  ),
                ),
              ],
            ),
            )
          ),
          SizedBox(height: 15,),
          Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Telefon:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                            child:  Container(
                              child: Text(
                        profile['Handynummer'],
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 0, 255),
                          decoration: TextDecoration.underline),
                      )),
                      onTap: () =>_launchphone(profile['Handynummer']),
                          ),)
                    ],
                  ),
                ),
                 Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Email:',
                          style: TextStyle(fontSize: 20,
                          ),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                            child: Container(
                              child: Text(
                        profile['Email'],
                        style: TextStyle(fontSize: 20,
                        color: Color.fromARGB(255, 0, 0, 255),
                          decoration: TextDecoration.underline),
                      )),
                      onTap: () => _launchemail(profile['Email']),
                          ))
                    ],
                  ),
                ),
              ],
            ),
            )
          ),
           SizedBox(height: 15,),
          Container(
             alignment: Alignment.center, //
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black, width: 2),
                      borderRadius: new BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Adresse:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Adresse'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'Ort:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['Ort'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        child: Text(
                          'PLZ:',
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                      Expanded(
                          child: Container(
                              child: Text(
                        profile['PLZ'],
                        style: TextStyle(fontSize: 20),
                      )))
                    ],
                  ),
                ),
              ],
            ),
            )
          )
        ],
      ),
    );
  }
  
}
