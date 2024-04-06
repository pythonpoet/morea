import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/messages_manager.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/Pages/Nachrichten/send_message.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:showcaseview/showcaseview.dart';
import 'single_message_page.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage(
      {required this.auth,
      required this.moreaFire,
      required this.navigationMap,
      required this.firestore});

  final FirebaseFirestore firestore;
  final MoreaFirebase moreaFire;
  final Auth auth;
  final Map navigationMap;

  @override
  State<StatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with TickerProviderStateMixin {
  late CrudMedthods crud0;
  var date;
  var uid;
  var stufe;
  GlobalKey _messagesKeyLeiter = GlobalKey();
  GlobalKey _floatingActionButtonKey = GlobalKey();
  GlobalKey _bottomAppBarLeiterKey = GlobalKey();
  GlobalKey _bottomAppBarTNKey = GlobalKey();
  late String anzeigename;
  late MoreaFirebase moreaFire;
  late MoreaLoading moreaLoading;
  late MessagesManager messagesManager;

  @override
  void initState() {
    super.initState();
    moreaLoading = MoreaLoading(this);
    this.moreaFire = widget.moreaFire;
    crud0 = CrudMedthods(widget.firestore);
    messagesManager = MessagesManager(crud0);
    messagesManager.getMessages(moreaFire.getGroupIDs!);
    uid = widget.auth.getUserID;
  }

  @override
  void dispose() {
    print("disposing message widget");
    moreaLoading.dispose();
    messagesManager.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MessagesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("updating Widget");
  }

  @override
  Widget build(BuildContext context) {
    if (moreaFire.getPos == 'Leiter') {
      if (moreaFire.getPfandiName == null) {
        this.anzeigename = moreaFire.getVorName!;
      } else {
        this.anzeigename = moreaFire.getPfandiName!;
      }
      return Scaffold(
        backgroundColor: MoreaColors.bottomAppBar,
        drawer: moreaDrawer(moreaFire.getPos!, moreaFire.getDisplayName!,
            moreaFire.getEmail!, context, widget.moreaFire, crud0, _signedOut),
        appBar: AppBar(
          title: Text('Nachrichten'),
          actions: tutorialButton(),
        ),
        floatingActionButton: Showcase.withWidget(
            key: _floatingActionButtonKey,
            disableMovingAnimation: true,
            width: 150,
            height: 300,
            targetShapeBorder: CircleBorder(),
            container: Container(
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.white),
              child: Column(
                children: [
                  Text(
                    'Hier kannst du Nachrichten verschicken. Nur Leiter haben diese Option in der App.',
                  ),
                ],
              ),
            ),
            child: moreaEditActionbutton(route: this.routeToSendMessage)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Showcase.withWidget(
            key: _bottomAppBarLeiterKey,
            disableMovingAnimation: true,
            height: 300,
            width: 150,
            container: Container(
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.white),
              child: Column(
                children: [
                  Text(
                    'Geh zum nächsten Screen und drücke dort oben rechts den Hilfeknopf',
                  ),
                ],
              ),
            ),
            child: moreaLeiterBottomAppBar(widget.navigationMap, 'Verfassen', MoreaBottomAppBarActivePage.messages)),
        body: Showcase(
          disableMovingAnimation: true,
          key: _messagesKeyLeiter,
          description: 'Hier siehst du alle deine Nachrichten',
          child: StreamBuilder(
              stream: messagesManager.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return MoreaBackgroundContainer(
                      child: Container(
                    child: moreaLoading.loading(),
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    constraints: BoxConstraints.expand(),
                  ));
                } else if (!snapshot.hasData) {
                  return MoreaBackgroundContainer(
                    child: SingleChildScrollView(
                      child: MoreaShadowContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Nachrichten',
                                style: MoreaTextStyle.title,
                              ),
                            ),
                            ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    'Keine Nachrichten vorhanden',
                                    style: MoreaTextStyle.normal,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.data!.length == 0) {
                  return MoreaBackgroundContainer(
                    child: SingleChildScrollView(
                      child: MoreaShadowContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Nachrichten',
                                  style: MoreaTextStyle.title,
                                ),
                              ),
                              ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: <Widget>[
                                  ListTile(
                                    title: Text(
                                      'Keine Nachrichten vorhanden',
                                      style: MoreaTextStyle.normal,
                                    ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Nachrichten',
                                style: MoreaTextStyle.title,
                              ),
                            ),
                            ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                shrinkWrap: true,
                                separatorBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: MoreaDivider(),
                                  );
                                },
                                itemBuilder: (context, index) {
                                  var document = snapshot.data![index];
                                  return _buildListItem(context, document);
                                }),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }),
        ),
      );
    } else {
      if (moreaFire.getPfandiName == null) {
        this.anzeigename = moreaFire.getVorName!;
      } else {
        this.anzeigename = moreaFire.getPfandiName!;
      }
      return Scaffold(
        backgroundColor: MoreaColors.bottomAppBar,
        appBar: AppBar(
          title: Text('Nachrichten'),
          actions: tutorialButton(),
        ),
        drawer: moreaDrawer(moreaFire.getPos!, moreaFire.getDisplayName!,
            moreaFire.getEmail!, context, widget.moreaFire, crud0, _signedOut),
        bottomNavigationBar: Showcase.withWidget(
            key: _bottomAppBarTNKey,
            disableMovingAnimation: true,
            height: 300,
            width: 150,
            container: Container(
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.white),
              child: Column(
                children: [
                  Text(
                    'Geh zum nächsten Screen und drücke dort oben rechts den Hilfeknopf',
                  ),
                ],
              ),
            ),
            child: moreaChildBottomAppBar(widget.navigationMap)),
        body: StreamBuilder(
            stream: messagesManager.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return MoreaBackgroundContainer(
                    child: Container(
                  child: moreaLoading.loading(),
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  constraints: BoxConstraints.expand(),
                ));
              } else if (!snapshot.hasData) {
                return MoreaBackgroundContainer(
                  child: SingleChildScrollView(
                    child: MoreaShadowContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Nachrichten',
                              style: MoreaTextStyle.title,
                            ),
                          ),
                          ListView(
                            physics: NeverScrollableScrollPhysics(),
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
                );
              } else if (snapshot.data!.length == 0) {
                return MoreaBackgroundContainer(
                  child: SingleChildScrollView(
                    child: MoreaShadowContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Nachrichten',
                              style: MoreaTextStyle.title,
                            ),
                          ),
                          ListView(
                            physics: NeverScrollableScrollPhysics(),
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
                );
              } else {
                return LayoutBuilder(
                  builder: (context, viewportConstraints) {
                    return MoreaBackgroundContainer(
                      child: SingleChildScrollView(
                        child: MoreaShadowContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Nachrichten',
                                  style: MoreaTextStyle.title,
                                ),
                              ),
                              ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  separatorBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: MoreaDivider(),
                                    );
                                  },
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    var document = snapshot.data![index];
                                    return _buildListItem(context, document);
                                  }),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                              )
                            ],
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

  void _signedOut() {
    widget.navigationMap[signedOut]();
  }

  routeToSendMessage() {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => SendMessages(
              moreaFire: moreaFire,
              auth: widget.auth,
              crudMedthods: this.crud0,
            )));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    var message = document;
    List<String> receivers = [];
    for (String receiver in document['receivers']) {
      receivers.add(convMiDatatoWebflow(receiver));
    }
    String receiversString = receivers.join(',');
    if (!(document['read'].contains(this.uid))) {
      return Container(
          padding: EdgeInsets.only(right: 20, left: 20),
          child: ListTile(
            key: UniqueKey(),
            title: Text(document['title'], style: MoreaTextStyle.lableViolett),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('von: ${document['sender']}',
                    style: MoreaTextStyle.sender),
                Text(
                  'für: $receiversString',
                  style: MoreaTextStyle.sender,
                ),
              ],
            ),
            contentPadding: EdgeInsets.only(),
            leading: CircleAvatar(
              child: Text(document['sender'][0]),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return SingleMessagePage(message, moreaFire, this.uid);
              }));
            },
          ));
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          key: UniqueKey(),
          title: Text(
            document['title'],
            style: MoreaTextStyle.normal,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('von: ${document['sender']}', style: MoreaTextStyle.sender),
              Text(
                'für: $receiversString',
                style: MoreaTextStyle.sender,
              ),
            ],
          ),
          contentPadding: EdgeInsets.only(),
          leading: CircleAvatar(
            child: Text(document['sender'][0]),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return SingleMessagePage(message, moreaFire, this.uid);
            }));
          },
        ),
      );
    }
  }

  List<Widget> tutorialButton() {
    if (moreaFire.getPos == 'Leiter') {
      return [
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () => tutorialLeiter(),
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () => tutorialTN(),
        ),
      ];
    }
  }

  void tutorialLeiter() {
    ShowCaseWidget.of(context).startShowCase(
        [_messagesKeyLeiter, _floatingActionButtonKey, _bottomAppBarLeiterKey]);
  }

  void tutorialTN() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(
                  'Hier siehst du alle Nachrichten, welche von deinen Leitern an dein Fähnli gesendet wurden'),
            )).then((onvalue) =>
        ShowCaseWidget.of(context).startShowCase([_bottomAppBarTNKey]));
  }
}
