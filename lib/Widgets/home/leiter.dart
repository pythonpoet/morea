import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:morea/morealayout.dart';

Widget leiterView(String groupID, List<String> subscribedGroups, Function navigation ,Function(String) teleblizAnzeigen, Function route){
  return DefaultTabController(
            length: subscribedGroups.length+1,
            child: Scaffold(
                appBar: new AppBar(
                  title: new Text('Teleblitz'),
                  bottom: TabBar(tabs: getTabList(groupID, subscribedGroups)),
                ),
                drawer: new Drawer(
                  child: new ListView(children: navigation()),
                ),
                body: TabBarView(children: [
                  LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight,
                            ),
                            child: SingleChildScrollView(
                                child: Column(
                              key: ObjectKey(teleblizAnzeigen('Biber')),
                              children: <Widget>[
                                teleblizAnzeigen('Biber'),
                              ],
                            ))),
                      );
                    },
                  ),
                  
                
                  
                ]),
                floatingActionButton: new FloatingActionButton(
                    elevation: 1.0,
                    child: new Icon(Icons.edit),
                    backgroundColor: MoreaColors.violett,
                    onPressed: () => route
                            )));
}
List<Widget> getTabList(String groupID, List<String> subscribedGroups){
  List<Widget> tabList = [];
  tabList.add(new Tab(text: groupID,));
   for(String groupID in subscribedGroups){
     tabList.add(new Tab(text: groupID,));
   }
   return tabList;
}