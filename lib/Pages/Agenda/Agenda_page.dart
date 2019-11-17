import 'package:flutter/material.dart';
import 'package:morea/Pages/Nachrichten/messages_page.dart';
import 'package:morea/Pages/Teleblitz/home_page.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/dwi_format.dart';
import 'Agenda_Eventadd_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_Lager_page.dart';
import 'view_Event_page.dart';
import 'package:morea/services/morea_firestore.dart';

class AgendaState extends StatefulWidget {
  AgendaState(this.auth, this.onSignedOut);
  final auth;
  final onSignedOut;

  @override
  State<StatefulWidget> createState() => _AgendaStatePage();
}

class _AgendaStatePage extends State<AgendaState> {
  MoreaFirebase moreafire = new MoreaFirebase();
  DWIFormat dwiformat = new DWIFormat();
  CrudMedthods crud0 = new CrudMedthods();
  Auth auth0 = Auth();
  Map userInfo;

  String pos = 'Teilnehmer';
  Stream<QuerySnapshot> qsagenda;
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

  _getAgenda() async {
    await this.getUserInfo();
    qsagenda = moreafire.getAgenda(this.userInfo['Stufe']);
    this.pos = this.userInfo['Pos'];
  }

  altevernichten(_agedatiteldatum, stufe) {
    stufe = dwiformat.simplestring(stufe);
    String somdate = _agedatiteldatum.split('.')[2] +
        '-' +
        _agedatiteldatum.split('.')[1] +
        '-' +
        _agedatiteldatum.split('.')[0];
    DateTime _agdatum = DateTime.parse(somdate + ' 00:00:00.000');
    DateTime now = DateTime.now();
    if (_agdatum.difference(now).inDays < 0) {
      crud0.deletedocument('/Stufen/$stufe/Agenda', _agedatiteldatum);
    }
  }

  bool istLeiter() {
    if (pos == 'Leiter') {
      return true;
    } else {
      return false;
    }
  }

  routetoAddevent() {
    if (istLeiter()) {
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => EventAddPage(
                eventinfo: quickfix,
                agendaModus: AgendaModus.beides,
              )));
    }
  }

  @override
  void initState() {
    _getAgenda();
    quickfix['Stufen'] = stufen;
    quickfix['Kontakt'] = kontakt;
    quickfix['Mitnehmen'] = mitnehmen;
    super.initState();
  }

  void getUserInfo() async {
    var result = await moreafire.getUserInformation(await auth0.currentUser());
    this.userInfo = result.data;
  }

  @override
  Widget build(BuildContext context) {
    if (istLeiter()) {
      if(widget.userInfo['Pfadinamen'] == null){
        widget.userInfo['Pfadinamen'] = widget.userInfo['Name'];
      }
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Agenda'),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(widget.userInfo['Pfadinamen']),
                accountEmail: Text(widget.userInfo['Email']),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
              ),
              Divider(),
              ListTile(
                title: new Text('Logout'),
                trailing: new Icon(Icons.cancel),
                onTap: _signedOut,
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: agenda(userInfo['Stufe']),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            color: Color.fromRGBO(43, 16, 42, 0.9),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => MessagesPage(
                              widget.auth,
                              widget.onSignedOut)));
                    }),
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
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>HomePage(
                          auth: widget.auth,
                          onSigedOut: widget.onSignedOut,
                        ),
                      ));
                    }),
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
                    onPressed: null,
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
        floatingActionButton: FloatingActionButton(
            elevation: 0.0,
            shape: CircleBorder(side: BorderSide(color: Colors.white)),
            child: Icon(Icons.add),
            backgroundColor: Color(0xff7a62ff),
            onPressed: () => routetoAddevent()),
      );
    } else {
      if(widget.userInfo['Pfadinamen'] == null){
        widget.userInfo['Pfadinamen'] = widget.userInfo['Name'];
      }
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Agenda'),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(widget.userInfo['Pfadinamen']),
                accountEmail: Text(widget.userInfo['Email']),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE9ZVZvX1fYVOXQdPMzwVE9TrmpLrZlVIiqvjvLGMRPKD-5W8rHA'))),
              ),
              Divider(),
              ListTile(
                title: new Text('Logout'),
                trailing: new Icon(Icons.cancel),
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
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => MessagesPage(
                              widget.auth, widget.onSignedOut)));
                    }),
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
                    onPressed: null,
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
        body: agenda(userInfo['Stufe']),
      );
    }
  }

  Widget agenda(stufe) {
    return StreamBuilder(
        stream: qsagenda,
        builder: (context, AsyncSnapshot<QuerySnapshot> qsagenda) {
          if (!qsagenda.hasData)
            return Center(
                child: Text(
              'Laden... einen Moment bitte',
              style: TextStyle(fontSize: 20),
            ));
          if (qsagenda.data.documents.length == 0)
            return MoreaBackgroundContainer(
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Keine Events/Lager eingetragen',
                  style: TextStyle(fontSize: 20),
                ),
              )),
            );
          return LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
            return MoreaBackgroundContainer(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: (viewportConstraints.maxHeight)),
                child: MoreaShadowContainer(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: qsagenda.data.documents.length,
                      itemBuilder: (context, int index) {
                        final DocumentSnapshot _info =
                            qsagenda.data.documents[index];
                        altevernichten(_info['Datum'], stufe);

                        if (_info['Event']) {
                          return ListTile(
                            title: Text(_info['Datum'].toString() + ": " + _info.data['Eventname'].toString()),
                            onTap: () => Navigator.of(context).push(
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new ViewEventPageState(
                                          info: _info,
                                          pos: userInfo['Pos'],
                                        ))),
                            trailing: Icon(Icons.arrow_forward_ios),
                            subtitle: Text('Event'),
                          );
                        } else {
                          return ListTile(
                            title: Text(_info['Datum'].toString() + ": " + _info.data['Lagername'].toString()),
                            onTap: () => Navigator.of(context).push(
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new ViewLagerPageState(
                                            info: _info,
                                            pos: userInfo['Pos']))),
                            trailing: Icon(Icons.arrow_forward_ios),
                            subtitle: Text('Lager'),
                          );
                        }
                      }),
                ),
              ),
            );
          });
        });
  }

  void _signedOut() async {
    try {
      if(Navigator.of(context).canPop()){
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      }
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}
