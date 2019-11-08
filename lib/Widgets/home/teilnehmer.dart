import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:morea/morealayout.dart';

Widget teilnehmerView(
  {@required Stream stream,
  @required String groupID,
  @required Function navigation,
  @required Function(String, AsyncSnapshot) teleblitzAnzeigen,
  @required Widget Function(String) anmeldebutton
  }
){
  return Scaffold(
          appBar: new AppBar(
            title: new Text('Teleblitz'),
            backgroundColor: MoreaColors.violett,
          ),
          drawer: new Drawer(
            child: new ListView(children: navigation()),
          ),
          body: StreamBuilder(
            stream: stream,
            builder:
                (BuildContext context, AsyncSnapshot snapshot) {
              return SingleChildScrollView(
                        child: Column(
                      children: <Widget>[
                        teleblitzAnzeigen(groupID, snapshot),
                        anmeldebutton(groupID)
                      ],
                    ),
              );
            },
          ),
        );
}