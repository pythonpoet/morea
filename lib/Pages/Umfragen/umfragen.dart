import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Umfragen/umfrage.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Umfragen extends StatefulWidget {
  @override
  _UmfragenState createState() => _UmfragenState();
}

enum FlareState { open, close, wait }

class _UmfragenState extends State<Umfragen> {
  FlareState flareState = FlareState.wait;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
          appBar: AppBar(
              title: Text('Umfragen'),
              bottom: TabBar(
                labelPadding: EdgeInsets.only(bottom: 10),
                tabs: <Widget>[Text('Alle Umfragen'), Text('Meine Umfragen')],
              )),
          floatingActionButton: SpeedDial(
            backgroundColor: MoreaColors.violett,
            shape: CircleBorder(side: BorderSide(color: Colors.white)),
            onOpen: () => setState(() {
              flareState = FlareState.open;
            }),
            onClose: () => setState(() {
              flareState = FlareState.close;
            }),
            child: AspectRatio(
              aspectRatio: 1,
              child: FlareActor(
                'assets/animated_icon/plus_cancel.flr',
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: flareState == FlareState.open
                    ? 'go'
                    : flareState == FlareState.close ? 'back' : 'idle',
              ),
            ),
            children: [
              SpeedDialChild(
                  child: Icon(
                    Icons.format_list_bulleted,
                    color: Colors.white,
                  ),
                  backgroundColor: MoreaColors.violett,
                  shape: CircleBorder(side: BorderSide(color: Colors.white)),
                  label: 'Single choice'),
              SpeedDialChild(
                  child: Icon(
                    Icons.event_note,
                    color: Colors.white,
                  ),
                  backgroundColor: MoreaColors.violett,
                  shape: CircleBorder(side: BorderSide(color: Colors.white)),
                  label: 'Multiple choice'),
              SpeedDialChild(
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                  backgroundColor: MoreaColors.violett,
                  shape: CircleBorder(side: BorderSide(color: Colors.white)),
                  label: 'Multiple choice mit Limit'
              )
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              MoreaBackgroundContainer(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        _buildCard(),
                        Padding(padding: EdgeInsets.only(top: 10)),
                        _buildCard(),
                        Padding(padding: EdgeInsets.only(top: 10)),
                      ],
                    ),
                  ),
                ),
              ),
              MoreaBackgroundContainer(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  GestureDetector _buildCard() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => Umfrage())),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: CircleAvatar(
                      backgroundColor: MoreaColors.violett,
                      child: Text(
                        'R',
                        style: MoreaTextStyle.raisedButton,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: <Widget>[
                            Text(
                              'Titel',
                              style: MoreaTextStyle.lable,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                            ),
                            Text('Von Test', style: MoreaTextStyle.sender),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                        ),
                        Text(
                          'Erstellt am: 22.02.20',
                          style: MoreaTextStyle.subtitle,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 12,
                      child: MoreaDivider(),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        moreaSmallFlatIconButton(
                            '10/15',
                            () => print('test'),
                            Icon(
                              Icons.group,
                              size: 15,
                              color: MoreaColors.violett,
                            )),
                        moreaSmallFlatIconButton(
                            'Kommentare',
                            null,
                            Icon(
                              Icons.comment,
                              size: 15,
                              color: MoreaColors.violett,
                            ))
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
