import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/utilities/MiData.dart';

Widget elternView(
    {@required Stream stream,
    @required List<String> subscribedGroups,
    @required Function navigation,
    @required Function(String, AsyncSnapshot, Widget) teleblitzAnzeigen,
    @required Widget Function(String, String) anmeldebutton,
    @required Map navigationMap,
    @required Widget moreaLoading}) {
  return DefaultTabController(
      length: subscribedGroups.length,
      child: Scaffold(
        appBar: new AppBar(
          title: new Text('Teleblitz'),
          bottom: TabBar(tabs: getTabList(subscribedGroups)),
        ),
        drawer: new Drawer(
          child: new ListView(children: navigation()),
        ),
        bottomNavigationBar: moreaChildBottomAppBar(navigationMap),
        body: TabBarView(
            children: getTeleblizWidgetList(subscribedGroups, stream,
                teleblitzAnzeigen, anmeldebutton, moreaLoading)),
      ));
}

List<Widget> getTeleblizWidgetList(
    List<String> subscribedGroups,
    Stream stream,
    Function(String, AsyncSnapshot, Widget) teleblitzAnzeigen,
    Function anmeldebutton,
    Widget moreaLoading) {
  List<Widget> listTeleblitzWidget = new List<Widget>();
  for (String groupID in subscribedGroups) {
    listTeleblitzWidget.add(getLayoutBuilderWidget(
        groupID, stream, teleblitzAnzeigen, anmeldebutton, moreaLoading));
  }
  return listTeleblitzWidget;
}

Widget getLayoutBuilderWidget(
    String groupID,
    Stream stream,
    Function(String, AsyncSnapshot, Widget) teleblitzAnzeigen,
    Function(String, String) anmeldebutton,
    Widget moreaLoading) {
  return StreamBuilder(
    stream: stream,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      List<Widget> anzeige = new List();
      teleblitzAnzeigen(groupID, snapshot, moreaLoading)
          .forEach((String eventID, tlbz) {
          anzeige.add(tlbz);
      });
      return MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: Column(
              key:
                  ObjectKey(anzeige),
              children: anzeige),
        ),
      );
    },
  );
}

List<Widget> getTabList(List<String> subscribedGroups) {
  List<Widget> tabList = new List();
  for (String groupID in subscribedGroups) {
    tabList.add(new Tab(
      text: convMiDatatoWebflow(groupID),
    ));
  }
  return tabList;
}
