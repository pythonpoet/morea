import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';

Widget teilnehmerView(
  {@required Stream stream,
  @required String groupID,
  @required Function navigation,
  @required Map<String,Widget> Function(String, AsyncSnapshot, Widget) teleblitzAnzeigen,
  @required Widget Function(String, String) anmeldebutton,
  @required Widget moreaLoading
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
                   List<Widget> anzeige = new List();
                  teleblitzAnzeigen(groupID, snapshot, moreaLoading).forEach((String eventID, tlbz){
                    if((eventID != tlbzMapNoElement)&&(eventID != tlbzMapLoading))
                    anzeige.add(
                      new Column(
                        children: <Widget>[
                          tlbz,
                          anmeldebutton(groupID, eventID)
                        ],
                      )
                    );
                    else
                    anzeige.add(tlbz);
                  });
              return SingleChildScrollView(
                        child: Column(
                      children: anzeige
                    ),
              );
            },
          ),
        );
}