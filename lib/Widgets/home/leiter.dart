import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/morea_strings.dart';
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
  print('Subscribed Groups = ' + subscribedGroups.length.toString());
  return DefaultTabController(
    length: subscribedGroups.length + 1,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    'Teleblitz ändern',
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
      print(anzeige.length);
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
