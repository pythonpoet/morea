import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/Pages/Nachrichten/send_message.dart';
import 'package:morea/morealayout.dart';
import 'single_message_page.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage(
      {@required this.auth,
      @required this.moreaFire,
      @required this.navigationMap,
      @required this.firestore});

  final Firestore firestore;
  final MoreaFirebase moreaFire;
  final Auth auth;
  final Map navigationMap;

  @override
  State<StatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  CrudMedthods crud0;
  var messages;
  var date;
  var uid;
  var stufe;
  String anzeigename;
  MoreaFirebase moreaFire;

  @override
  void initState() {
    super.initState();
    this.moreaFire = widget.moreaFire;
    _getMessages(this.context);
    crud0 = CrudMedthods(widget.firestore);
  }

  @override
  Widget build(BuildContext context) {
    if (moreaFire.getPos == 'Leiter') {
      if (moreaFire.getPfandiName == null) {
        this.anzeigename = moreaFire.getVorName;
      } else {
        this.anzeigename = moreaFire.getPfandiName;
      }
      return Scaffold(
        drawer: moreaDrawer(moreaFire.getPos, moreaFire.getDisplayName,
            moreaFire.getEmail, context, widget.moreaFire, crud0, _signedOut),
        appBar: AppBar(
          title: Text('Nachrichten'),
        ),
        floatingActionButton: moreaEditActionbutton(this.routeToSendMessage),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: moreaLeiterBottomAppBar(widget.navigationMap, 'Verfassen'),
        body: StreamBuilder(
            stream: this.messages,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return MoreaBackgroundContainer(
                    child: SingleChildScrollView(
                        child:
                            MoreaShadowContainer(child: Text('Loading...', style: MoreaTextStyle.normal,))));
              } else if (!snapshot.hasData) {
                return MoreaBackgroundContainer(
                  child: SingleChildScrollView(
                    child: MoreaShadowContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                'Nachrichten',
                                style: MoreaTextStyle.title,
                              ),
                            ),
                            ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                ListTile(
                                  title: Text('Keine Nachrichten vorhanden', style: MoreaTextStyle.normal,),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else if (snapshot.data.documents.length == 0) {
                return MoreaBackgroundContainer(
                  child: SingleChildScrollView(
                    child: MoreaShadowContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                'Nachrichten',
                                style: MoreaTextStyle.title,
                              ),
                            ),
                            ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                ListTile(
                                  title: Text('Keine Nachrichten vorhanden', style: MoreaTextStyle.normal,),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return MoreaBackgroundContainer(
                  child: SingleChildScrollView(
                    child: MoreaShadowContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                'Nachrichten',
                                style: MoreaTextStyle.title,
                              ),
                            ),
                            ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  var document = snapshot.data.documents[index];
                                  return _buildListItem(context, document);
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            }),
      );
    } else {
      if (moreaFire.getPfandiName == null) {
        this.anzeigename = moreaFire.getVorName;
      } else {
        this.anzeigename = moreaFire.getPfandiName;
      }
      return Scaffold(
        appBar: AppBar(
          title: Text('Nachrichten'),
        ),
        drawer: moreaDrawer(moreaFire.getPos, moreaFire.getDisplayName,
            moreaFire.getEmail, context, widget.moreaFire, crud0, _signedOut),
        bottomNavigationBar: moreaChildBottomAppBar(widget.navigationMap),
        body: StreamBuilder(
            stream: this.messages,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading...');
              } else if (!snapshot.hasData) {
                return MoreaBackgroundContainer(
                  child: SingleChildScrollView(
                    child: MoreaShadowContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                'Nachrichten',
                                style: MoreaTextStyle.title,
                              ),
                            ),
                            ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                ListTile(
                                  title: Text('Keine Nachrichten vorhanden'),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else if (snapshot.data.documents.length == 0) {
                return MoreaBackgroundContainer(
                  child: SingleChildScrollView(
                    child: MoreaShadowContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                'Nachrichten',
                                style: MoreaTextStyle.title,
                              ),
                            ),
                            ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                ListTile(
                                  title: Text('Keine Nachrichten vorhanden'),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return LayoutBuilder(
                  builder: (context, viewportConstraints) {
                    return MoreaBackgroundContainer(
                      child: SingleChildScrollView(
                        child: MoreaShadowContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Nachrichten',
                                    style: MoreaTextStyle.title,
                                  ),
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (context, index) {
                                      var document =
                                          snapshot.data.documents[index];
                                      return _buildListItem(context, document);
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }),
      );
    }
  }

  void _signedOut() async {
    try {
      await widget.auth.signOut();
      widget.navigationMap[signedOut]();
    } catch (e) {
      print(e);
    }
  }

  _getMessages(BuildContext context) async {
    this.uid = widget.auth.getUserID;
    this.stufe = moreaFire.getGroupID;
    setState(() {
      this.messages = moreaFire.getMessages(this.stufe);
    });
  }

  routeToSendMessage() {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => SendMessages(
              moreaFire: moreaFire, auth: widget.auth,
            )));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    var message = document;
    if (!(document['read'].contains(this.uid))) {
      return Container(
          padding: EdgeInsets.only(right: 20, left: 20),
          child: ListTile(
            key: UniqueKey(),
            title: Text(document['title'],
                style: MoreaTextStyle.lable),
            subtitle: Text(document['sender'],
                style: MoreaTextStyle.sender),
            contentPadding: EdgeInsets.only(),
            leading: CircleAvatar(
              child: Text(document['sender'][0]),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await moreaFire.setMessageRead(
                  this.uid, document.documentID, this.stufe);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return SingleMessagePage(message);
              }));
            },
          ));
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          key: UniqueKey(),
          title: Text(
            document['title'], style: MoreaTextStyle.normal,
          ),
          subtitle: Text(
            document['sender'], style: MoreaTextStyle.sender,
          ),
          contentPadding: EdgeInsets.only(),
          leading: CircleAvatar(
            child: Text(document['sender'][0]),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return SingleMessagePage(message);
            }));
          },
        ),
      );
    }
  }
}
