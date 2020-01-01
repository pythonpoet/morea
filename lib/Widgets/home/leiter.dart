import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/utilities/MiData.dart';

Widget leiterView(
    {@required
        Stream stream,
    @required
        String groupID,
    @required
        List<String> subscribedGroups,
    @required
        Function navigation,
    @required
        Map<String, Widget> Function(String, AsyncSnapshot, Widget)
            teleblitzAnzeigen,
    @required
        Function route,
    @required
        Map navigationMap,
    @required
        Widget moreaLoading}) {
  return DefaultTabController(
    length: subscribedGroups.length + (groupID.isNotEmpty? 1 : 0),
    child: Scaffold(
      appBar: new AppBar(
        title: new Text('Teleblitz'),
        bottom: TabBar(tabs: getTabList(groupID, subscribedGroups)),
      ),
      drawer: new Drawer(
        child: new ListView(children: navigation()),
      ),
      body: TabBarView(
        children: getTeleblizWidgetList(
            groupID, stream, subscribedGroups, teleblitzAnzeigen, moreaLoading),
      ),
      floatingActionButton: moreaEditActionbutton(route),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: moreaLeiterBottomAppBar(navigationMap, "Ändern"),
    ),
  );
}

List<Widget> getTabList(String groupID, List<String> subscribedGroups) {
  List<Widget> tabList = [];
  tabList.add(new Tab(
    text: convMiDatatoWebflow(groupID),
  ));
  for (String groupID in subscribedGroups) {
    tabList.add(new Tab(
      text: convMiDatatoWebflow(groupID),
    ));
  }
  return tabList;
}

List<Widget> getTeleblizWidgetList(
    String groupID,
    Stream stream,
    List<String> subscribedGroups,
    Function(String, AsyncSnapshot, Widget) teleblitzAnzeigen,
    Widget moreaLoading) {
  List<Widget> listTeleblitzWidget = new List<Widget>();
  listTeleblitzWidget.add(
      getLayoutBuilderWidget(groupID, stream, teleblitzAnzeigen, moreaLoading));
  for (String groupID in subscribedGroups) {
    listTeleblitzWidget.add(getLayoutBuilderWidget(
        groupID, stream, teleblitzAnzeigen, moreaLoading));
  }
  return listTeleblitzWidget;
}

Widget getLayoutBuilderWidget(
    String groupID,
    Stream stream,
    Map<String, Widget> Function(String, AsyncSnapshot, Widget)
        teleblitzAnzeigen,
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
          key: ObjectKey(anzeige),
          children: anzeige,
        )),
      );
    },
  );
}
