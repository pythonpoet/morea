import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/morea_firestore.dart';

import 'change_name.dart';

class Profile extends StatefulWidget {
  final auth;
  final onSignedOut;
  final uid;

  Profile(this.auth, this.onSignedOut, this.uid);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  MoreaFirebase moreafire = MoreaFirebase();
  Auth auth0 = Auth();
  String uid;

  _ProfileState();

  @override
  void initState() {
    super.initState();
    this.uid = widget.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: moreafire.streamUserInfomation(this.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportconstraints) {
                  return MoreaBackgroundContainer(
                    child: MoreaShadowContainer(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: viewportconstraints.maxWidth,
                            minHeight: 300),
                      ),
                    ),
                  );
                },
              );
            } else {
              return MoreaBackgroundContainer(
                child: SingleChildScrollView(
                  child: MoreaShadowContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Profil ändern',
                            style: MoreaTextStyle.title,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              thickness: 1,
                              color: Colors.black26,
                            )),
                        ListTile(
                          title: Text(
                            'Name',
                            style: MoreaTextStyle.lable,
                          ),
                          subtitle: Text(
                            snapshot.data['Vorname'] +
                                ' ' +
                                snapshot.data['Nachname'] +
                                ' v/o ' +
                                snapshot.data['Pfadinamen'],
                            style: MoreaTextStyle.normal,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) => ChangeName(
                                      snapshot.data['Vorname'],
                                      snapshot.data['Nachname'],
                                      snapshot.data['Pfadinamen']))),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              thickness: 1,
                              color: Colors.black26,
                            )),
                        ListTile(
                          title: Text(
                            'E-Mail-Adresse',
                            style: MoreaTextStyle.lable,
                          ),
                          subtitle: Text(
                            snapshot.data['Email'],
                            style: MoreaTextStyle.normal,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              thickness: 1,
                              color: Colors.black26,
                            )),
                        ListTile(
                          title: Text(
                            'Passwort',
                            style: MoreaTextStyle.lable,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              thickness: 1,
                              color: Colors.black26,
                            )),
                        ListTile(
                          title: Text(
                            'Handynummer',
                            style: MoreaTextStyle.lable,
                          ),
                          subtitle: Text(
                            snapshot.data['Handynummer'],
                            style: MoreaTextStyle.normal,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              thickness: 1,
                              color: Colors.black26,
                            )),
                        ListTile(
                          title: Text(
                            'Adresse',
                            style: MoreaTextStyle.lable,
                          ),
                          subtitle: Text(
                            snapshot.data['Adresse'] +
                                ', ' +
                                snapshot.data['PLZ'] +
                                ' ' +
                                snapshot.data['Ort'],
                            style: MoreaTextStyle.normal,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(
                              thickness: 1,
                              color: Colors.black26,
                            )),
                        ListTile(
                          title: Text(
                            'Nachrichtengruppen',
                            style: MoreaTextStyle.lable,
                          ),
                          subtitle: ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data['messagingGroups'].length,
                            itemBuilder: (context, index) {
                              List<String> results = [];
                              for (var u
                                  in snapshot.data['messagingGroups'].keys) {
                                if (snapshot.data['messagingGroups'][u]) {
                                  results.add(u);
                                }
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  results[index],
                                  style: MoreaTextStyle.normal,
                                ),
                              );
                            },
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
      appBar: AppBar(
        title: Text('Profil'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Color.fromRGBO(43, 16, 42, 0.9),
          child: Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  onPressed: (() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => MessagesPage(
                            widget.auth, widget.onSignedOut)));
                  }),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.message, color: Colors.white),
                      Text(
                        'Nachrichten',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white),
                      )
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  onPressed: (() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => AgendaState(
                            widget.auth, widget.onSignedOut)));
                  }),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.event, color: Colors.white),
                      Text(
                        'Agenda',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white),
                      )
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                flex: 1,
              ),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  onPressed: (() {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => HomePage(
                        auth: widget.auth,
                        onSigedOut: widget.onSignedOut,
                      ),
                    ));
                  }),
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.flash_on, color: Colors.white),
                      Text(
                        'Teleblitz',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white),
                      )
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  onPressed: null,
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.person, color: Colors.white),
                      Text(
                        'Profil',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white),
                      )
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
                flex: 1,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
        shape: CircularNotchedRectangle(),
      ),
    );
  }
}
