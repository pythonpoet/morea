import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';

Widget teilnehmerView(
    {@required
        Stream stream,
    @required
        String groupID,
    @required
        Function navigation,
    @required
        Map<String, Widget> Function(String, AsyncSnapshot, Widget)
            teleblitzAnzeigen,
    @required
        Widget Function(String, String) anmeldebutton,
    @required
        Widget moreaLoading,
    @required
        Map navigationMap}) {
  return Scaffold(
    appBar: new AppBar(
      title: new Text('Teleblitz'),
    ),
    drawer: new Drawer(
      child: new ListView(children: navigation()),
    ),
    bottomNavigationBar: BottomAppBar(
      child: Container(
        color: Color.fromRGBO(43, 16, 42, 0.9),
        child: Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                padding: EdgeInsets.symmetric(vertical: 15),
                onPressed: navigationMap[toMessagePage],
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
                onPressed: navigationMap[toAgendaPage],
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
              child: FlatButton(
                padding: EdgeInsets.symmetric(vertical: 15),
                onPressed: null,
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
                onPressed: navigationMap[toProfilePage],
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
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        List<Widget> anzeige = new List();
        teleblitzAnzeigen(groupID, snapshot, moreaLoading)
            .forEach((String eventID, tlbz) {
          if ((eventID != tlbzMapNoElement) && (eventID != tlbzMapLoading))
            anzeige.add(new Column(
              children: <Widget>[tlbz, anmeldebutton(groupID, eventID)],
            ));
          else
            anzeige.add(tlbz);
        });
        return MoreaBackgroundContainer(
          child: SingleChildScrollView(
            child: Column(children: anzeige),
          ),
        );
      },
    ),
  );
}
