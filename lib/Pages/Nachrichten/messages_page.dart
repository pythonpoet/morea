import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_page.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/Pages/Nachrichten/send_message.dart';
import 'package:morea/morealayout.dart';
import 'single_message_page.dart';

class MessagesPage extends StatefulWidget {
  final auth;
  final onSignedOut;
  final userInfo;

  MessagesPage(this.userInfo, this.auth, this.onSignedOut);

  @override
  State<StatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  MoreaFirebase firestore = MoreaFirebase();
  Auth auth0 = Auth();
  var messages;
  var date;
  var uid;
  var stufe;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getMessages(this.context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userInfo['Pos'] == 'Leiter') {
      if(widget.userInfo['Pfadinamen'] == null){
        widget.userInfo['Pfadinamen'] = widget.userInfo['Name'];
      }
      return Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(widget.userInfo['Pfadinamen']),
                accountEmail: Text(widget.userInfo['Email']),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
              ),
              Divider(),
              ListTile(
                title: new Text('Logout'),
                trailing: new Icon(Icons.cancel),
                onTap: _signedOut,
              )
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Nachrichten'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => SendMessages()));
          },
          child: Icon(Icons.edit),
          backgroundColor: MoreaColors.violett,
          shape: CircleBorder(side: BorderSide(color: Colors.white)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child: Container(
            color: Color.fromRGBO(43, 16, 42, 0.9),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    onPressed: null,
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
                              widget.userInfo,
                              widget.auth,
                              widget.onSignedOut)));
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
                    child: Text(
                      'Verfassen',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => HomePage(
                          userInfo: widget.userInfo,
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
        body: StreamBuilder(
            stream: this.messages,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return MoreaBackgroundContainer(
                    child: SingleChildScrollView(
                        child:
                            MoreaShadowContainer(child: Text('Loading...'))));
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
      if(widget.userInfo['Pfadinamen'] == null){
        widget.userInfo['Pfadinamen'] = widget.userInfo['Name'];
      }
      return Scaffold(
        appBar: AppBar(
          title: Text('Nachrichten'),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(widget.userInfo['Pfadinamen']),
                accountEmail: Text(widget.userInfo['Email']),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
              ),
              Divider(),
              ListTile(
                title: new Text('Logout'),
                trailing: new Icon(Icons.cancel),
                onTap: _signedOut,
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            color: Color.fromRGBO(43, 16, 42, 0.9),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    onPressed: null,
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
                              widget.userInfo,
                              widget.auth,
                              widget.onSignedOut)));
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
                    child: Text(
                      'Verfassen',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => HomePage(
                          userInfo: widget.userInfo,
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
        body: StreamBuilder(
            stream: this.messages,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text('Loading...');
              } else {
                return LayoutBuilder(
                  builder: (context, viewportConstraints) {
                    return MoreaBackgroundContainer(
                      child: SingleChildScrollView(
                        child: MoreaShadowContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  var document = snapshot.data.documents[index];
                                  return _buildListItem(context, document);
                                }),
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
      if(Navigator.of(context).canPop()){
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      }
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  _getMessages(BuildContext context) async {
    this.uid = await auth0.currentUser();
    this.stufe = widget.userInfo['Stufe'];
    setState(() {
      this.messages = firestore.getMessages(this.stufe);
    });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    var message = document;
    if (!(document['read'].containsKey(this.uid))) {
      return Container(
          padding: EdgeInsets.only(right: 20, left: 20),
          child: ListTile(
            key: UniqueKey(),
            title: Text(document['title'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(document['sender'],
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            contentPadding: EdgeInsets.only(),
            leading: CircleAvatar(
              child: Text(document['sender'][0]),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await firestore.setMessageRead(
                  this.uid, document.documentID, this.stufe);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return SingleMessagePage(message);
              }));
            },
          ));
    } else if (!(document['read'][this.uid])) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          key: UniqueKey(),
          title: Text(document['title'],
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(document['sender'],
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          contentPadding: EdgeInsets.only(),
          leading: CircleAvatar(
            child: Text(document['sender'][0]),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () async {
            await firestore.setMessageRead(
                this.uid, document.documentID, this.stufe);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return SingleMessagePage(message);
            }));
          },
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          key: UniqueKey(),
          title: Text(
            document['title'],
          ),
          subtitle: Text(
            document['sender'],
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
