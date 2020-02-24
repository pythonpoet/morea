import 'package:flutter/material.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/agenda.dart' as prefix0;
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/MiData.dart';
import 'package:morea/services/utilities/dwi_format.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../morealayout.dart';
import 'Agenda_Eventadd_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_Lager_page.dart';
import 'view_Event_page.dart';
import 'package:morea/services/morea_firestore.dart';

class AgendaState extends StatefulWidget {
  AgendaState(
      {@required this.firestore,
      @required this.moreaFire,
      @required this.auth,
      @required this.navigationMap});

  final MoreaFirebase moreaFire;
  final Firestore firestore;
  final Auth auth;
  final Map<String, Function> navigationMap;

  @override
  State<StatefulWidget> createState() => _AgendaStatePage();
}

class _AgendaStatePage extends State<AgendaState>
    with TickerProviderStateMixin {
  MoreaFirebase moreafire;
  DWIFormat dwiformat = new DWIFormat();
  CrudMedthods crud0;
  prefix0.Agenda agenda;
  String pos = 'Teilnehmer';
  Stream<List> sLagenda;
  GlobalKey _agendaLeiterKey = GlobalKey();
  GlobalKey _agendaLeiterKey2 = GlobalKey();
  GlobalKey _floatingActionButtonKey = GlobalKey();
  GlobalKey _bottomAppBarLeiterKey = GlobalKey();
  GlobalKey _bottomAppBarTNKey = GlobalKey();
  Map stufen = {
    'Biber': false,
    'Pios': false,
    'Nahani (Meitli)': false,
    'Drason (Buebe)': false,
    'Wombat (Wölfe)': false,
  };
  Map kontakt = {'Email': '', 'Pfadiname': ''};
  List mitnehmen = ['Pfadihämpt'];

  Map<String, dynamic> quickfix = {
    'Eventname': '',
    'Datum': 'Datum wählen',
    'Datum bis': 'Datum wählen',
    'Anfangszeit': 'von',
    'Anfangsort': '',
    'Schlussort': '',
    'Schlusszeit': 'bis',
    'Stufen': '',
    'Beschreiben': '',
    'Kontakt': '',
    'Mitnehmen': '',
    'Lagername': ''
  };
  MoreaLoading moreaLoading;

  void _getAgenda(groupID) {
    List<String> groupIDs = [];
    if (groupID != null) groupIDs.add(groupID);
    groupIDs.addAll(widget.moreaFire.getSubscribedGroups);
    agenda.getTotalAgendaOverview(groupIDs);
  }

  altevernichten(_agedaTitledatum, groupID, Map<String, dynamic> event) async {
    if (event.containsKey("DeleteDate")) {
      DateTime _agdatum = DateTime.parse(event["DeleteDate"]);
      DateTime now = DateTime.now();
      if (_agdatum.difference(now).inDays < 0) {
        Map fullevent =
            (await agenda.getAgendaTitle(event[groupMapEventID])).data;
        if (fullevent != null)
          agenda.deleteAgendaEvent(fullevent);
        else
          agenda.deleteAgendaOverviewTitle(groupID, event[groupMapEventID]);
      }
    } else {
      Map fullevent =
          (await agenda.getAgendaTitle(event[groupMapEventID])).data;
      if (fullevent != null)
        agenda.deleteAgendaEvent(fullevent);
      else
        agenda.deleteAgendaOverviewTitle(groupID, event[groupMapEventID]);
    }
  }

  bool istLeiter() {
    if (pos == 'Leiter') {
      return true;
    } else {
      return false;
    }
  }

  bool isEltern() {
    switch (moreafire.getPos) {
      case 'Mutter':
        return true;
      case 'Vater':
        return true;
      case 'Erziehungsberechtigter':
        return true;
      case 'Erziehungsberechtigte':
        return true;
      default:
        return false;
    }
  }

  routetoAddevent() {
    if (istLeiter()) {
      Navigator.of(context)
          .push(new MaterialPageRoute(
              builder: (BuildContext context) => EventAddPage(
                    eventinfo: quickfix,
                    agendaModus: AgendaModus.beides,
                    firestore: widget.firestore,
                    moreaFire: moreafire,
                    agenda: agenda,
                  )))
          .then((result) {
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    moreaLoading = MoreaLoading(this);
    moreafire = widget.moreaFire;
    crud0 = CrudMedthods(widget.firestore);
    agenda = new prefix0.Agenda(widget.firestore, widget.moreaFire);

    //_getAgenda("3776");
    quickfix['Stufen'] = stufen;
    quickfix['Kontakt'] = kontakt;
    quickfix['Mitnehmen'] = mitnehmen;
    pos = moreafire.getUserMap['Pos'];
    _getAgenda(moreafire.getUserMap[userMapgroupID]);
  }

  @override
  void dispose() {
    moreaLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (istLeiter()) {
      return Scaffold(
        backgroundColor: MoreaColors.bottomAppBar,
        appBar: AppBar(
          title: Text('Agenda'),
          actions: tutorialButton(),
        ),
        body: Showcase.withWidget(
            key: _agendaLeiterKey,
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
                    'Hier siehst du alle Events/Lager deines Fähnlis',
                  ),
                ],
              ),
            ),
            disableAnimation: true,
            child: Showcase.withWidget(
                disableAnimation: true,
                key: _agendaLeiterKey2,
                height: 300,
                width: 150,
                container: Container(
                  padding: EdgeInsets.all(5),
                  constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white),
                  child: Column(
                    children: [
                      Text(
                        'Drücke auf einzelne Events/Lager um mehr Details zu sehen',
                      ),
                    ],
                  ),
                ),
                child: aAgenda(moreafire.getUserMap[userMapgroupID]))),
        floatingActionButton: Showcase(
          key: _floatingActionButtonKey,
          disableAnimation: true,
          description: 'Hier kannst du Events/Lager hinzufügen',
          child: new FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Color(0xff7a62ff),
            onPressed: () => routetoAddevent(),
            shape: CircleBorder(side: BorderSide(color: Colors.white)),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        drawer: moreaDrawer(pos, moreafire.getDisplayName, moreafire.getEmail,
            context, moreafire, crud0, _signedOut),
        bottomNavigationBar: Showcase.withWidget(
            key: _bottomAppBarLeiterKey,
            height: 300,
            width: 150,
            disableAnimation: true,
            container: Container(
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.white),
              child: Column(
                children: [
                  Text(
                    'Geh zum nächsten Screen und drücke den Hilfeknopf oben rechts',
                  ),
                ],
              ),
            ),
            child: moreaLeiterBottomAppBar(widget.navigationMap, 'Hinzufügen')),
      );
    } else {
      return Scaffold(
        backgroundColor: MoreaColors.bottomAppBar,
        appBar: AppBar(
          title: Text('Agenda'),
          actions: tutorialButton(),
        ),
        bottomNavigationBar: Showcase.withWidget(
            key: _bottomAppBarTNKey,
            height: 300,
            width: 150,
            disableAnimation: true,
            container: Container(
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.white),
              child: Column(
                children: [
                  Text(
                    'Geh zum nächsten Screen und drücke den Hilfeknopf oben rechts',
                  ),
                ],
              ),
            ),
            child: moreaChildBottomAppBar(widget.navigationMap)),
        drawer: moreaDrawer(moreafire.getPos, moreafire.getDisplayName,
            moreafire.getEmail, context, moreafire, crud0, _signedOut),
        body: aAgenda(moreafire.getUserMap[userMapgroupID]),
      );
    }
  }

  viewLager(BuildContext context, Map<String, dynamic> agendaTitle) async {
    Map<String, dynamic> info =
        (await agenda.getAgendaTitle(agendaTitle[groupMapEventID])).data;
    Navigator.of(context)
        .push(new MaterialPageRoute(
            builder: (BuildContext context) => new ViewLagerPageState(
                moreaFire: moreafire,
                agenda: agenda,
                info: info,
                pos: moreafire.getUserMap['Pos'])))
        .then((result) {
      setState(() {});
    });
  }

  viewEvent(BuildContext context, Map<String, dynamic> agendaTitle) async {
    Map<String, dynamic> info =
        (await agenda.getAgendaTitle(agendaTitle[groupMapEventID])).data;
    Navigator.of(context)
        .push(new MaterialPageRoute(
            builder: (BuildContext context) => new ViewEventPageState(
                  moreaFire: moreafire,
                  agenda: agenda,
                  info: info,
                  pos: moreafire.getUserMap['Pos'],
                )))
        .then((result) {
      setState(() {});
    });
  }

  Widget aAgenda(String groupID) {
    return StreamBuilder(
        stream: agenda.eventstream.asBroadcastStream(),
        builder: (context, AsyncSnapshot<List> slagenda) {
          if (slagenda.connectionState == ConnectionState.waiting) {
            return MoreaBackgroundContainer(
                child: moreaLoading.loading());
          } else if (!slagenda.hasData)
            return MoreaBackgroundContainer(
              child: MoreaShadowContainer(
                child: Center(
                    child: Text(
                  'Keine Events/Lager eingetragen',
                  style: MoreaTextStyle.normal,
                )),
              ),
            );
          else if (slagenda.data.length == 0) {
            return MoreaBackgroundContainer(
              child: MoreaShadowContainer(
                child: Center(
                    child: Text(
                  'Keine Events/Lager eingetragen',
                  style: MoreaTextStyle.normal,
                )),
              ),
            );
          } else {
            return MoreaBackgroundContainer(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: slagenda.data.length,
                          shrinkWrap: true,
                          itemBuilder: (context, int index) {
                            final Map<String, dynamic> _info =
                                Map<String, dynamic>.from(slagenda.data[index]);
                            altevernichten(_info['Datum'], groupID, _info);

                            if (_info['Event']) {
                              return Card(
                                child: ListTile(
                                    key: ObjectKey(_info),
                                    subtitle: ListView(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            _info['Datum'].toString(),
                                            style: MoreaTextStyle.subtitle,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            'Event',
                                            style: MoreaTextStyle.subtitle,
                                          ),
                                        )
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
                                    title: Text(
                                      _info['Eventname'].toString(),
                                      style: MoreaTextStyle.lableViolett,
                                    ),
                                    trailing: _info['groupID'] == null
                                        ? Text('')
                                        : Text(
                                            convMiDatatoWebflow(_info['groupID']),
                                            style: MoreaTextStyle.sender,
                                          ),
                                    onTap: () => viewEvent(context, _info)),
                              );
                            } else if (_info['Lager']) {
                              return Card(
                                child: ListTile(
                                    key: ObjectKey(_info),
                                    title: Text(
                                      _info['Eventname'],
                                      style: MoreaTextStyle.lableViolett,
                                    ),
                                    subtitle: ListView(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            _info['Datum'],
                                            style: MoreaTextStyle.subtitle,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            'Lager',
                                            style: MoreaTextStyle.subtitle,
                                          ),
                                        )
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
                                    trailing: _info['groupID'] == null
                                        ? Text('Error')
                                        : Text(
                                            convMiDatatoWebflow(_info['groupID']),
                                            style: MoreaTextStyle.sender,
                                          ),
                                    onTap: () => viewLager(context, _info)),
                              );
                            } else {
                              return SizedBox();
                            }
                          }),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  void _signedOut() {
    widget.navigationMap[signedOut]();
  }

  List<Widget> tutorialButton() {
    if (istLeiter()) {
      return [
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () => tutorialLeiter(),
        )
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () => tutorialTN(),
        )
      ];
    }
  }

  void tutorialLeiter() {
    ShowCaseWidget.of(context).startShowCase([
      _agendaLeiterKey,
      _agendaLeiterKey2,
      _floatingActionButtonKey,
      _bottomAppBarLeiterKey
    ]);
  }

  void tutorialTN() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(
                  'Drücke auf einzelne Events/Lager um mehr Details zu sehen. Drücke auf einzelne Events/Lager um mehr Details zu sehen.'),
            )).then((onvalue) =>
        ShowCaseWidget.of(context).startShowCase([_bottomAppBarTNKey]));
  }
}
