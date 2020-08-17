import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/agenda.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/utilities/dwi_format.dart';

class EventAddPage extends StatefulWidget {
  EventAddPage(
      {this.eventinfo,
      this.agendaModus,
      this.firestore,
      this.agenda,
      this.moreaFire});

  final MoreaFirebase moreaFire;
  final Map eventinfo;
  final AgendaModus agendaModus;
  final Firestore firestore;
  final Agenda agenda;

  @override
  State<StatefulWidget> createState() => EventAddPageState();
}

enum AgendaModus { lager, event, beides }

class EventAddPageState extends State<EventAddPage> {
  DWIFormat dwiFormat = new DWIFormat();
  CrudMedthods crud0;
  Agenda agenda;
  MoreaFirebase moreafire;
  int value = 2;
  List<String> mitnehmen = [];
  final _changekey = new GlobalKey<FormState>(debugLabel: "_changekey");
  final _addEvent = new GlobalKey<FormState>(debugLabel: "_addEvent");
  final _addLager = new GlobalKey<FormState>(debugLabel: "_addLager");
  List<TextEditingController> mitnehmenController = [TextEditingController()];

  String eventname = ' ',
      datum = 'Datum wählen',
      anfangzeit = 'Zeit wählen',
      anfangort = ' ',
      schlusszeit = 'Zeit wählen',
      schlussort = ' ',
      beschreibung = ' ',
      pfadiname = ' ',
      email = ' ';
  String lagername = ' ',
      datumvon = 'Datum wählen',
      datumbis = 'Datum wählen',
      lagerort = ' ';
  String order;
  List<Map<dynamic, dynamic>> subgroups;

  Map<String, dynamic> event, lager;
  Map<String, bool> groupCheckbox;

  Map<String, bool> stufen = {
    'Biber': false,
    'Wombat (Wölfe)': false,
    'Nahani (Meitli)': false,
    'Drason (Buebe)': false,
    'Pios': false,
  };

  @override
  void dispose(){
    for(TextEditingController controller in mitnehmenController){
      controller.dispose();
    }
    super.dispose();
  }

  bool validateAndSave(_key) {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void groupCheckboxinit(List<Map> subgroups) {
    groupCheckbox = Map<String, bool>();
    if (widget.eventinfo['eventID'] == null) {
      for (Map groupMap in subgroups) {
        this.groupCheckbox[groupMap[userMapGroupIDs]] = false;
      }
    } else {
      for (Map groupMap in subgroups) {
        if (widget.eventinfo['groupIDs'].contains(groupMap[userMapGroupIDs])) {
          this.groupCheckbox[groupMap[userMapGroupIDs]] = true;
        } else {
          this.groupCheckbox[groupMap[userMapGroupIDs]] = false;
        }
      }
    }
  }

  void eventHinzufuegen() {
    if (validateAndSave(_addEvent)) {
      for (TextEditingController controller in mitnehmenController) {
        mitnehmen.add(controller.text);
      }
      Map<String, String> kontakt = {'Pfadiname': pfadiname, 'Email': email};
      Map<String, bool> finalGroupCheckbox =
          Map<String, bool>.from(this.groupCheckbox);
      finalGroupCheckbox.removeWhere((k, v) => v == false);
      event = {
        'Order': order,
        'Lager': false,
        'Event': true,
        'Eventname': eventname,
        'Datum': datum,
        'Anfangszeit': anfangzeit,
        'Anfangsort': anfangort,
        'Schlusszeit': schlusszeit,
        'Schlussort': schlussort,
        'groupIDs': finalGroupCheckbox.keys.toList(),
        'Beschreibung': beschreibung,
        'Kontakt': kontakt,
        'Mitnehmen': mitnehmen,
        'DeleteDate': order,
      };

      agenda.uploadtoAgenda(widget.eventinfo, event);

      Navigator.popUntil(context, ModalRoute.withName('/'));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Event wurde hinzugefügt'),
          );
        },
      );
    }
  }

  void lagerHinzufuegen() {
    if (validateAndSave(_addLager)) {
      for (TextEditingController controller in mitnehmenController) {
        mitnehmen.add(controller.text);
      }
      Map<String, String> kontakt = {'Pfadiname': pfadiname, 'Email': email};
      Map<String, bool> finalGroupCheckbox =
          Map<String, bool>.from(this.groupCheckbox);
      finalGroupCheckbox.removeWhere((k, v) => v == false);
      lager = {
        'Order': order,
        'Lager': true,
        'Event': false,
        'Eventname': eventname,
        'Datum': datumvon,
        'Datum bis': datumbis,
        'Lagerort': lagerort,
        'Anfangszeit': anfangzeit,
        'Anfangsort': anfangort,
        'Schlusszeit': schlusszeit,
        'Schlussort': schlussort,
        'groupIDs': finalGroupCheckbox.keys.toList(),
        'Beschreibung': beschreibung,
        'Kontakt': kontakt,
        'Mitnehmen': mitnehmen,
        'DeleteDate': order,
      };

      agenda.uploadtoAgenda(widget.eventinfo, lager);
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  Future<Null> _selectDatum(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(new Duration(days: 9999)),
    );
    if (picked != null)
      setState(() {
        datum = DateFormat('EEEE, dd.MM.yyyy', 'de').format(picked);
        order = DateFormat('yyyyMMdd').format(picked);
      });
  }

  Future<Null> _selectDatumvon(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(new Duration(days: 9999)),
    );
    if (picked != null)
      setState(() {
        datumvon = DateFormat('EEEE, dd.MM.yyyy', 'de').format(picked);
        order = DateFormat('yyyyMMdd').format(picked);
      });
  }

  Future<Null> _selectDatumbis(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime picked2 = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(new Duration(days: 9999)));
    if (picked2 != null)
      setState(() {
        datumbis = DateFormat('EEEE, dd.MM.yyyy', 'de').format(picked2);
      });
  }

  Future<void> _selectAnfangszeit(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (picked.minute.toString().length < 2 &&
            picked.hour.toString().length >= 2) {
          this.anfangzeit =
              picked.hour.toString() + ":0" + picked.minute.toString();
        } else if (picked.hour.toString().length < 2 &&
            picked.minute.toString().length >= 2) {
          print(true);
          this.anfangzeit =
              "0" + picked.hour.toString() + ":" + picked.minute.toString();
        } else if (picked.hour.toString().length < 2 &&
            picked.minute.toString().length < 2) {
          this.anfangzeit = "0" +
              picked.hour.toString() +
              ":" +
              "0" +
              picked.minute.toString();
        } else {
          print(false);
          this.anfangzeit =
              picked.hour.toString() + ":" + picked.minute.toString();
        }
      });
    }
    return null;
  }

  Future<void> _selectSchlusszeit(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (picked.minute.toString().length < 2 &&
            picked.hour.toString().length >= 2) {
          this.schlusszeit =
              picked.hour.toString() + ":0" + picked.minute.toString();
        } else if (picked.hour.toString().length < 2 &&
            picked.minute.toString().length >= 2) {
          print(true);
          this.schlusszeit =
              "0" + picked.hour.toString() + ":" + picked.minute.toString();
        } else if (picked.hour.toString().length < 2 &&
            picked.minute.toString().length < 2) {
          this.schlusszeit = "0" +
              picked.hour.toString() +
              ":" +
              "0" +
              picked.minute.toString();
        } else {
          print(false);
          this.schlusszeit =
              picked.hour.toString() + ":" + picked.minute.toString();
        }
      });
    }
    return null;
  }

  void lagerdelete() async {
    bool delete = false;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          child: Text('Lager wirklich löschen?'),
        ),
        actions: <Widget>[
          new RaisedButton(
              child: Text(
                'Löschen',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                delete = true;

                Navigator.pop(context);
              }),
        ],
      ),
    );
    if (delete) {
      await agenda.deleteAgendaEvent(widget.eventinfo);
      Navigator.pop(context);
    }
  }

  void eventdelete() async {
    bool delete = false;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          child: Text('Event wirklich löschen?'),
        ),
        actions: <Widget>[
          new RaisedButton(
              child: Text(
                'Löschen',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                delete = true;

                Navigator.pop(context);
              }),
        ],
      ),
    );
    if (delete) {
      await agenda.deleteAgendaEvent(widget.eventinfo);
      Navigator.pop(context);
    }
  }

  initSubgoup() async {
    Map<String, dynamic> data =
        (await crud0.getDocument(pathGroups, "1165")).data;
    this.subgroups =
        new List<Map<dynamic, dynamic>>.from(data[groupMapSubgroup]);
    this.groupCheckboxinit(this.subgroups);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    datumvon = widget.eventinfo['Datum'];
    datumbis = widget.eventinfo['Datum bis'];
    datum = widget.eventinfo['Datum'];

    anfangzeit = widget.eventinfo['Anfangszeit'];
    schlusszeit = widget.eventinfo['Schlusszeit'];
    if (widget.eventinfo.containsKey("Stufen"))
      stufen = Map<String, bool>.from(widget.eventinfo['Stufen']);
    mitnehmen = List<String>.from(widget.eventinfo['Mitnehmen']);
    order = widget.eventinfo['Order'];
    moreafire = widget.moreaFire;
    crud0 = new CrudMedthods(widget.firestore);
    agenda = widget.agenda;
    initSubgoup();
  }

  @override
  Widget build(BuildContext context) {
    if (subgroups == null)
      return Card(
        child: Container(
          padding: EdgeInsets.all(100),
          child: simpleMoreaLoadingIndicator(),
        ),
      );
    switch (widget.agendaModus) {
      case AgendaModus.beides:
        return DefaultTabController(
          length: 2,
          child: new Scaffold(
            appBar: new AppBar(
              title: Text('zur Agenda hinzufügen'),
              bottom: TabBar(
                tabs: <Widget>[Tab(text: 'Event'), Tab(text: 'Lager')],
              ),
            ),
            body: TabBarView(
              children: <Widget>[eventWidget(), lagerWidget()],
            ),
          ),
        );
        break;
      case AgendaModus.event:
        return Scaffold(
          appBar: new AppBar(
            title: Text(widget.eventinfo['Eventname'] + ' bearbeiten'),
          ),
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: SingleChildScrollView(
                        child: Column(
                      children: <Widget>[eventWidget()],
                    ))),
              );
            },
          ),
        );

        break;
      case AgendaModus.lager:
        return Scaffold(
            appBar: new AppBar(
              title: new Text(widget.eventinfo['Eventname'] + ' bearbeiten'),
            ),
            body: lagerWidget());
        break;
      default:
        return null;
    }
  }

  void changemitnehmen(int index) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => new Form(
              key: _changekey,
              child: new AlertDialog(
                contentPadding: const EdgeInsets.all(16.0),
                content: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new TextFormField(
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        decoration:
                            new InputDecoration(hintText: mitnehmen[index]),
                        onSaved: (value) => mitnehmen[index] = value,
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  moreaRaisedIconButton(
                      'OK',
                      validateMitnehmen,
                      Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )),
                ],
              ),
            ));
  }

  validateMitnehmen() {
    validateAndSave(_changekey);
    Navigator.pop(context);
  }

  List<Widget> buildMitnehmen() {
    List<Widget> mitnehmenList = [];
    for (var u in mitnehmenController) {
      mitnehmenList.add(Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: TextFormField(
          controller: u,
          maxLines: 1,
          keyboardType: TextInputType.text,
          style: MoreaTextStyle.textField,
          cursorColor: MoreaColors.violett,
          decoration: InputDecoration(
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MoreaColors.violett)),
          ),
          validator: (value) {
            if (value.isEmpty) {
              return 'Bitte nicht leer lassen';
            } else {
              return null;
            }
          },
        ),
      ));
    }
    return mitnehmenList;
  }

  void addElement() {
    this.setState(() {
      mitnehmenController.add(TextEditingController());
    });
  }

  void removeElement() {
    if (mitnehmenController.length != 0) {
      this.setState(() {
            mitnehmenController.removeLast();
          });
    }
  }

  Widget lagerWidget() {
    return Container(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Form(
                  key: _addLager,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Lagername'),
                              ),
                              Expanded(
                                flex: 7,
                                child: new TextFormField(
                                  initialValue: widget.eventinfo['Eventname'],
                                  decoration: new InputDecoration(
                                    errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red)),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: MoreaColors.violett)),
                                    filled: false,
                                  ),
                                  onSaved: (value) => eventname = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Datum von'),
                              ),
                              Expanded(
                                flex: 7,
                                child: RaisedButton(
                                  onPressed: () => _selectDatumvon(context),
                                  child: Text(datumvon),
                                ),
                              )
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Datum bis'),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: RaisedButton(
                                    onPressed: () => _selectDatumbis(context),
                                    child: Text(datumbis),
                                  ))
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Lager Ort'),
                              ),
                              Expanded(
                                flex: 7,
                                child: new TextFormField(
                                  initialValue: widget.eventinfo['Lagerort'],
                                  decoration: new InputDecoration(
                                    errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red)),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: MoreaColors.violett)),
                                    filled: false,
                                  ),
                                  keyboardType: TextInputType.text,
                                  onSaved: (value) => lagerort = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Beginn'),
                              ),
                              Expanded(
                                flex: 3,
                                child: RaisedButton(
                                  onPressed: () => _selectAnfangszeit(context),
                                  child: Text(anfangzeit),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: new TextFormField(
                                  initialValue: widget.eventinfo['Anfangsort'],
                                  decoration: new InputDecoration(
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red)),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MoreaColors.violett)),
                                      filled: false,
                                      hintText: 'Ort'),
                                  onSaved: (value) => anfangort = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Schluss'),
                              ),
                              Expanded(
                                flex: 3,
                                child: RaisedButton(
                                  onPressed: () => _selectSchlusszeit(context),
                                  child: Text(schlusszeit),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: new TextFormField(
                                  initialValue: widget.eventinfo['Schlussort'],
                                  decoration: new InputDecoration(
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red)),
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MoreaColors.violett)),
                                      filled: false,
                                      hintText: 'Ort'),
                                  onSaved: (value) => schlussort = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          height: (60 * groupCheckbox.length).toDouble(),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Betrifft'),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: new ListView(
                                      physics: NeverScrollableScrollPhysics(),
                                      children: subgroups
                                          .map((Map<dynamic, dynamic> group) {
                                        return new CheckboxListTile(
                                          title: new Text(
                                              group[groupMapgroupNickName]),
                                          value: groupCheckbox[
                                              group[userMapGroupIDs]],
                                          onChanged: (bool value) {
                                            setState(() {
                                              groupCheckbox[
                                                      group[userMapGroupIDs]] =
                                                  value;
                                            });
                                          },
                                        );
                                      }).toList()))
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Beschreibung'),
                              ),
                              Expanded(
                                flex: 7,
                                child: new TextFormField(
                                  initialValue:
                                      widget.eventinfo['Beschreibung'],
                                  decoration: new InputDecoration(
                                    errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red)),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: MoreaColors.violett)),
                                    filled: false,
                                  ),
                                  maxLines: 10,
                                  onSaved: (value) => beschreibung = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Kontakt'),
                              ),
                              Expanded(
                                flex: 3,
                                child: new TextFormField(
                                  initialValue: widget.eventinfo['Kontakt']
                                      ['Pfadiname'],
                                  decoration: new InputDecoration(
                                    hintText: 'Pfadiname',
                                    errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red)),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: MoreaColors.violett)),
                                    filled: false,
                                  ),
                                  onSaved: (value) => pfadiname = value,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: new TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  initialValue: widget.eventinfo['Kontakt']
                                      ['Email'],
                                  decoration: new InputDecoration(
                                    hintText: 'Email',
                                    errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red)),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: MoreaColors.violett)),
                                    filled: false,
                                  ),
                                  onSaved: (value) => email = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text('Mitnehmen'),
                            ),
                            Expanded(
                              flex: 7,
                              child: Column(
                                children: <Widget>[
                                  Column(
                                    children: buildMitnehmen(),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 0,),
                                    child: FractionallySizedBox(
                                      widthFactor: 1,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 7,
                                            child: moreaFlatIconButton(
                                                'ELEMENT',
                                                this.removeElement,
                                                Icon(
                                                  Icons.remove,
                                                  size: 15,
                                                  color: MoreaColors.violett,
                                                )),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(),
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: moreaFlatIconButton(
                                                'ELEMENT',
                                                this.addElement,
                                                Icon(
                                                  Icons.add,
                                                  size: 14,
                                                  color: MoreaColors.violett,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: moreaFlatRedButton(
                                'Löschen',
                                this.lagerdelete,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                            ),
                            Expanded(
                              child: moreaRaisedButton(
                                'Speichern',
                                this.lagerHinzufuegen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      )
                    ],
                  ))));
    }));
  }

  Widget eventWidget() {
    return new Container(
        height: 700,
        child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Form(
                      key: _addEvent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Event Name'),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: new TextFormField(
                                      initialValue:
                                          widget.eventinfo['Eventname'],
                                      decoration: new InputDecoration(
                                        errorBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: MoreaColors.violett)),
                                        filled: false,
                                      ),
                                      onSaved: (value) => eventname = value,
                                    ),
                                  )
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Datum'),
                                  ),
                                  Expanded(
                                      flex: 7,
                                      child: RaisedButton(
                                        onPressed: () => _selectDatum(context),
                                        child: Text(datum),
                                      ))
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Beginn'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: RaisedButton(
                                      onPressed: () =>
                                          _selectAnfangszeit(context),
                                      child: Text(anfangzeit),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: new TextFormField(
                                      initialValue:
                                          widget.eventinfo['Anfangsort'],
                                      decoration: new InputDecoration(
                                          errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: MoreaColors.violett)),
                                          filled: false,
                                          hintText: 'Ort'),
                                      onSaved: (value) => anfangort = value,
                                    ),
                                  )
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Schluss'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: RaisedButton(
                                      onPressed: () =>
                                          _selectSchlusszeit(context),
                                      child: Text(schlusszeit),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: new TextFormField(
                                      initialValue:
                                          widget.eventinfo['Schlussort'],
                                      decoration: new InputDecoration(
                                          errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: MoreaColors.violett)),
                                          filled: false,
                                          hintText: 'Ort'),
                                      onSaved: (value) => schlussort = value,
                                    ),
                                  )
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.all(10),
                              height: (60 * groupCheckbox.length).toDouble(),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Betrifft'),
                                  ),
                                  Expanded(
                                      flex: 7,
                                      child: new ListView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          children: subgroups.map(
                                              (Map<dynamic, dynamic> group) {
                                            return new CheckboxListTile(
                                              title: new Text(
                                                  group[groupMapgroupNickName]),
                                              value: groupCheckbox[
                                                  group[userMapGroupIDs]],
                                              onChanged: (bool value) {
                                                setState(() {
                                                  groupCheckbox[group[
                                                      userMapGroupIDs]] = value;
                                                });
                                              },
                                            );
                                          }).toList()))
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Beschreibung'),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: new TextFormField(
                                      initialValue:
                                          widget.eventinfo['Beschreibung'],
                                      decoration: new InputDecoration(
                                        errorBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: MoreaColors.violett)),
                                        filled: false,
                                      ),
                                      maxLines: 10,
                                      onSaved: (value) => beschreibung = value,
                                    ),
                                  )
                                ],
                              )),
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Kontakt'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: new TextFormField(
                                      initialValue: widget.eventinfo['Kontakt']
                                          ['Pfadiname'],
                                      decoration: new InputDecoration(
                                        hintText: 'Pfadiname',
                                        errorBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: MoreaColors.violett)),
                                        filled: false,
                                      ),
                                      onSaved: (value) => pfadiname = value,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: new TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      initialValue: widget.eventinfo['Kontakt']
                                          ['Email'],
                                      decoration: new InputDecoration(
                                        hintText: 'Email',
                                        errorBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: MoreaColors.violett)),
                                        filled: false,
                                      ),
                                      onSaved: (value) => email = value,
                                    ),
                                  )
                                ],
                              )),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Text('Mitnehmen'),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    children: <Widget>[
                                      Column(
                                        children: buildMitnehmen(),
                                      ),
                                      Container(
                                        child: FractionallySizedBox(
                                          widthFactor: 1,
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 7,
                                                child: moreaFlatIconButton(
                                                    'ELEMENT',
                                                    this.removeElement,
                                                    Icon(
                                                      Icons.remove,
                                                      size: 15,
                                                      color:
                                                          MoreaColors.violett,
                                                    )),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Container(),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: moreaFlatIconButton(
                                                    'ELEMENT',
                                                    this.addElement,
                                                    Icon(
                                                      Icons.add,
                                                      size: 14,
                                                      color:
                                                          MoreaColors.violett,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: moreaFlatRedButton(
                                    'Löschen',
                                    this.eventdelete,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                ),
                                Expanded(
                                  child: moreaRaisedButton(
                                    'Speichern',
                                    this.eventHinzufuegen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                          )
                        ],
                      ))));
        }));
  }
}
