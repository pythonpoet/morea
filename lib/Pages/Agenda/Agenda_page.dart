import 'package:flutter/material.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/agenda.dart' as prefix0;
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/dwi_format.dart';
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

  Stream<List> _getAgenda(groupID)async* {
    yield* agenda.getTotalAgendaOverview([groupID, ...widget.moreaFire.getSubscribedGroups]);
  }

  altevernichten(_agedaTitledatum, groupID, Map<String, dynamic> event) async {
    DateTime _agdatum = DateTime.parse(event["DeleteDate"]);
    DateTime now = DateTime.now();

    if (_agdatum.difference(now).inDays < 0) {
      Map fullevent = (await agenda.getAgendaTitle(event[groupMapEventID])).data;
      if(fullevent != null)
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
  bool isEltern(){
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
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => EventAddPage(
                eventinfo: quickfix,
                agendaModus: AgendaModus.beides,
                firestore: widget.firestore,
                moreaFire: moreafire,
                agenda: agenda,
              )));
    }
  }

  @override
  void initState() {
    moreaLoading = MoreaLoading(this);
    moreafire = widget.moreaFire;

    agenda = new prefix0.Agenda(widget.firestore,widget.moreaFire);

    //_getAgenda("3776");
    quickfix['Stufen'] = stufen;
    quickfix['Kontakt'] = kontakt;
    quickfix['Mitnehmen'] = mitnehmen;
    pos = moreafire.getUserMap['Pos'];

    super.initState();
  }

  @override
  void dispose() {
    moreaLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (istLeiter()) {
      return new Container(
          child: new Scaffold(
        appBar: new AppBar(
          title: new Text('Agenda'),
        ),
        body: aAgenda(moreafire.getUserMap[userMapgroupID]),
        floatingActionButton: new FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Color(0xff7a62ff),
          onPressed: () => routetoAddevent(),
          shape: CircleBorder(side: BorderSide(color: Colors.white)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: new Text(moreafire.getDisplayName),
                accountEmail: new Text(moreafire.getEmail),
                decoration: new BoxDecoration(
                  color: MoreaColors.orange,
                ),
              ),
              ListTile(
                title: Text('Logout'),
                trailing: Icon(Icons.cancel),
                onTap: _signedOut,
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            color: Color.fromRGBO(43, 16, 42, 0.9),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    onPressed: widget.navigationMap[toMessagePage],
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
                    onPressed: null,
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
                      'Hinzufügen',
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
                    onPressed: widget.navigationMap[toHomePage],
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
                    onPressed: widget.navigationMap[toProfilePage],
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
      ));
    } else {
      return new Container(
          child: new Scaffold(
        appBar: new AppBar(
          title: new Text('Agenda'),
        ),
        bottomNavigationBar: moreaChildBottomAppBar(widget.navigationMap),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: new Text(moreafire.getDisplayName),
                accountEmail: new Text(moreafire.getEmail),
                decoration: new BoxDecoration(
                  color: MoreaColors.orange,
                ),
              ),
              ListTile(
                title: Text('Logout'),
                trailing: Icon(Icons.cancel),
                onTap: _signedOut,
              )
            ],
          ),
        ),
        body: aAgenda(moreafire.getUserMap[userMapgroupID]),
      ));
    }
  }

  viewLager(BuildContext context, Map<String, dynamic> agendaTitle) async {
    Map<String, dynamic> info =
        (await agenda.getAgendaTitle(agendaTitle[groupMapEventID])).data;
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => new ViewLagerPageState(
          moreaFire: moreafire, 
          agenda: agenda,
          info: info, pos: 
          moreafire.getUserMap['Pos'])));
  }

  viewEvent(BuildContext context, Map<String, dynamic> agendaTitle) async {
    Map<String, dynamic> info =
        (await agenda.getAgendaTitle(agendaTitle[groupMapEventID])).data;
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => new ViewEventPageState(
          moreaFire: moreafire, 
          agenda: agenda,
          info: info, pos: 
          moreafire.getUserMap['Pos'],
            )));
  }

  Widget aAgenda(String groupID){
    return StreamBuilder(
        stream: _getAgenda(groupID).asBroadcastStream(),
        builder: (context, AsyncSnapshot<List> slagenda) {
          if (slagenda.connectionState == ConnectionState.waiting) {
            return moreaLoading.loading();
          } else if (!slagenda.hasData)
            return MoreaBackgroundContainer(
              child: MoreaShadowContainer(
                child: Center(
                    child: Text(
                  'Keine Events/Lager eingetragen',
                  style: TextStyle(fontSize: 20),
                )),
              ),
            );
          else if (slagenda.data.length == 0) {
            return MoreaBackgroundContainer(
              child: MoreaShadowContainer(
                child: Center(
                    child: Text(
                  'Keine Events/Lager eingetragen',
                  style: TextStyle(fontSize: 20),
                )),
              ),
            );
          } else {
            return MoreaBackgroundContainer(
              child: SingleChildScrollView(
                child: MoreaShadowContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Agenda',
                          style: MoreaTextStyle.title,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: MoreaDivider(),
                      ),
                      ListView.separated(
                          itemCount: slagenda.data.length,
                          shrinkWrap: true,
                          separatorBuilder: (context, int index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: MoreaDivider(),
                            );
                          },
                          itemBuilder: (context, int index) {
                            final Map<String, dynamic> _info =
                                Map<String, dynamic>.from(slagenda.data[index]);
                            altevernichten(_info['Datum'], groupID, _info);

                            if (_info['Event']) {
                              return ListTile(
                                  subtitle: ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          _info['Datum'].toString(),
                                          style: MoreaTextStyle.normal,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          'Event',
                                          style: MoreaTextStyle.normal,
                                        ),
                                      )
                                    ],
                                  ),
                                  title: Text(
                                    _info['Eventname'].toString(),
                                    style: MoreaTextStyle.lable,
                                  ),
                                  onTap: () => viewEvent(context, _info));
                            } else if (_info['Lager']) {
                              return ListTile(
                                  title: Text(
                                    _info['Eventname'],
                                    style: MoreaTextStyle.lable,
                                  ),
                                  subtitle: ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          _info['Eventname'],
                                          style: MoreaTextStyle.normal,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          'Lager',
                                          style: MoreaTextStyle.normal,
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () => viewLager(context, _info));
                            } else {
                              return SizedBox();
                            }
                          }),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  void _signedOut() async {
    await widget.auth.signOut();
    widget.navigationMap[signedOut]();
  }
}
