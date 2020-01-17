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
    bottomNavigationBar: moreaChildBottomAppBar(navigationMap),
    body: StreamBuilder(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        List<Widget> anzeige = new List();
        teleblitzAnzeigen(groupID, snapshot, moreaLoading, )
            .forEach((String eventID, tlbz) {
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
