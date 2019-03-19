import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'package:intl/intl.dart';

class EventAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EventAddPageState();
}

class _EventAddPageState extends State<EventAddPage> {
  Auth aut0 = new Auth();
  int value = 2;
  List<String> mitnehemen = ['Pfadihämpt'];
  final _addkey = new GlobalKey<FormState>();
  final _changekey = new GlobalKey<FormState>();
  final _addEvent = new GlobalKey<FormState>();
  final _addLager = new GlobalKey<FormState>();

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
  int order;

  Map<String, dynamic> Event;
  Map<String, dynamic> Lager;

  Map<String, bool> stufen = {
    'Biber': false,
    'Wombat (Wölfe)': false,
    'Nahani (Meitli)': false,
    'Drason (Buebe)': false,
    'Pios': false,
  };

  _addItem() {
    if (validateAndSave(_addkey)) {
      setState(() {
        value = value + 1;
      });
    }
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

  void eventHinzufuegen(_key) {
    if (validateAndSave(_key)) {
      Map<String, String> kontakt = {'Pfadiname': pfadiname, 'Email': email};

      Event = {
        'Order': order,
        'Lager': false,
        'Event': true,
        'Eventname': eventname,
        'Datum': datum,
        'Anfangszeit': anfangzeit,
        'Anfangsort': anfangort,
        'Schlusszeit': schlusszeit,
        'Schlussort': schlussort,
        'Stufen': stufen,
        'Beschreibung': beschreibung,
        'Kontakt': kontakt,
        'Mitnehmen': mitnehemen
      };
      if (stufen['Biber']) {
        aut0.uploadtoAgenda('Biber', datum, Event);
      }
      if (stufen['Nahani (Meitli)']) {
        aut0.uploadtoAgenda('Nahani (Meitli)', datum, Event);
      }
      if (stufen['Nahani (Meitli)']) {
        aut0.uploadtoAgenda('Nahani (Meitli)', datum, Event);
      }
      if (stufen['Drason (Buebe)']) {
        aut0.uploadtoAgenda('Drason (Buebe)', datum, Event);
      }
      if (stufen['Pios']) {
        aut0.uploadtoAgenda('Pios', datum, Event);
      }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Event wurde hinzugefügt"),
            );
          });
    }
  }

  void lagerHinzufuegen(_key) {
    if (validateAndSave(_key)) {
      Map<String, String> kontakt = {'Pfadiname': pfadiname, 'Email': email};

      Lager = {
        'Order': order,
        'Lager': true,
        'Event': false,
        'Lagername': lagername,
        'Datum': datumvon,
        'Datum bis': datumbis,
        'Lagerort': lagerort,
        'Anfangszeit': anfangzeit,
        'Anfangsort': anfangort,
        'Schlusszeit': schlusszeit,
        'Schlussort': schlussort,
        'Stufen': stufen,
        'Beschreibung': beschreibung,
        'Kontakt': kontakt,
        'Mitnehmen': mitnehemen
      };
      if (stufen['Biber']) {
        aut0.uploadtoAgenda('Biber', datumvon, Lager);
      }
      if (stufen['Nahani (Meitli)']) {
        aut0.uploadtoAgenda('Nahani (Meitli)', datumvon, Lager);
      }
      if (stufen['Nahani (Meitli)']) {
        aut0.uploadtoAgenda('Nahani (Meitli)', datumvon, Lager);
      }
      if (stufen['Drason (Buebe)']) {
        aut0.uploadtoAgenda('Drason (Buebe)', datumvon, Lager);
      }
      if (stufen['Pios']) {
        aut0.uploadtoAgenda('Pios', datumvon, Lager);
      }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Event wurde hinzugefügt"),
            );
          });
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
    if (picked != null && picked != datum)
      setState(() {
        datum = DateFormat('dd-MM-yyyy').format(picked);
        order = int.parse(DateFormat('yyyyMMdd').format(picked));
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
    if (picked != null && picked != datumvon)
      setState(() {
        datumvon = DateFormat('dd-MM-yyyy').format(picked);
        order = int.parse(DateFormat('yyyyMMdd').format(picked));
      });
  }

  Future<Null> _selectDatumbis(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime picked2 = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(new Duration(days: 9999)));
    if (picked2 != null && picked2 != datumbis)
      setState(() {
        datumbis = DateFormat('dd-MM-yyyy').format(picked2);
      });
  }

  Future<Null> _selectAnfangszeit(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(initialTime: TimeOfDay.now(), context: context);
    if (picked != null && picked != anfangzeit)
      setState(() {
        anfangzeit = picked.hour.toString() + ':' + picked.minute.toString();
      });
  }

  Future<Null> _selectSchlusszeit(BuildContext context) async {
    final TimeOfDay picked =
        await showTimePicker(initialTime: TimeOfDay.now(), context: context);
    if (picked != null && picked != schlusszeit)
      setState(() {
        schlusszeit = picked.hour.toString() + ':' + picked.minute.toString();
      });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: Text('zur Agenda hinzufügen'),
          backgroundColor: Color(0xff7a62ff),
          bottom: TabBar(
            tabs: <Widget>[Tab(text: 'Event'), Tab(text: 'Lager')],
          ),
        ),
        body: TabBarView(
          children: <Widget>[event(), lager()],
        ),
      ),
    );
  }

  void changemitnehmen(int index) {
    String zwischensp;
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
                            new InputDecoration(hintText: mitnehemen[index]),
                        onSaved: (value) => mitnehemen[index] = value,
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  new RaisedButton(
                      child: const Text('OK'),
                      onPressed: () {
                        validateAndSave(_changekey);
                        Navigator.pop(context);
                      }),
                ],
              ),
            ));
  }

  Widget lager() {
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
                                child: Text('Lager Name'),
                              ),
                              Expanded(
                                flex: 7,
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: false,
                                  ),
                                  onSaved: (value) => lagername = value,
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
                                  decoration: new InputDecoration(
                                    border: OutlineInputBorder(),
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
                                child: Text('Anfang'),
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
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
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
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: false,
                                      hintText: 'Ort'),
                                  onSaved: (value) => schlussort = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          height: 300,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Betrifft'),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: new ListView(
                                    children: stufen.keys.map((String key) {
                                      return new CheckboxListTile(
                                          title: new Text(key),
                                          value: stufen[key],
                                          onChanged: (bool value) {
                                            setState(() {
                                              stufen[key] = value;
                                            });
                                          });
                                    }).toList(),
                                  ))
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
                                  decoration: new InputDecoration(
                                    border: OutlineInputBorder(),
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
                                  decoration: new InputDecoration(
                                    hintText: 'Pfadiname',
                                    border: OutlineInputBorder(),
                                    filled: false,
                                  ),
                                  onSaved: (value) => pfadiname = value,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                    hintText: 'Email',
                                    border: OutlineInputBorder(),
                                    filled: false,
                                  ),
                                  onSaved: (value) => email = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                        height: 400,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 20 * mitnehemen.length.toDouble(),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Mitnehmen'),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: ListView.builder(
                                        itemCount: this.mitnehemen.length,
                                        itemBuilder: (context, index) =>
                                            this._buildRow(index)),
                                  )
                                ],
                              ),
                            ),
                            Form(
                                key: _addkey,
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: SizedBox(),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: new TextFormField(
                                            decoration: new InputDecoration(
                                              border: OutlineInputBorder(),
                                              filled: false,
                                            ),
                                            onSaved: (value) =>
                                                mitnehemen.add(value)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: new RaisedButton(
                                          child: new Text('Add',
                                              style:
                                                  new TextStyle(fontSize: 15)),
                                          onPressed: () => _addItem(),
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      30.0)),
                                          color: Color(0xff7a62ff),
                                          textColor: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                            SizedBox(height: 30),
                            Center(
                              child: new RaisedButton(
                                child: new Text('Speichern',
                                    style: TextStyle(fontSize: 25)),
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                                color: Color(0xff7a62ff),
                                textColor: Colors.white,
                                onPressed: () => lagerHinzufuegen(_addLager),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ))));
    }));
  }

  Widget event() {
    return new Container(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
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
                                  decoration: new InputDecoration(
                                    border: OutlineInputBorder(),
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
                                child: Text('Anfang'),
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
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
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
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: false,
                                      hintText: 'Ort'),
                                  onSaved: (value) => schlussort = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          height: 300,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: Text('Betrifft'),
                              ),
                              Expanded(
                                  flex: 7,
                                  child: new ListView(
                                    children: stufen.keys.map((String key) {
                                      return new CheckboxListTile(
                                          title: new Text(key),
                                          value: stufen[key],
                                          onChanged: (bool value) {
                                            setState(() {
                                              stufen[key] = value;
                                            });
                                          });
                                    }).toList(),
                                  ))
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
                                  decoration: new InputDecoration(
                                    border: OutlineInputBorder(),
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
                                  decoration: new InputDecoration(
                                    hintText: 'Pfadiname',
                                    border: OutlineInputBorder(),
                                    filled: false,
                                  ),
                                  onSaved: (value) => pfadiname = value,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                    hintText: 'Email',
                                    border: OutlineInputBorder(),
                                    filled: false,
                                  ),
                                  onSaved: (value) => email = value,
                                ),
                              )
                            ],
                          )),
                      Container(
                        height: 400,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 20 * mitnehemen.length.toDouble(),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Mitnehmen'),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: ListView.builder(
                                        itemCount: this.mitnehemen.length,
                                        itemBuilder: (context, index) =>
                                            this._buildRow(index)),
                                  )
                                ],
                              ),
                            ),
                            Form(
                                key: _addkey,
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: SizedBox(),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: new TextFormField(
                                            decoration: new InputDecoration(
                                              border: OutlineInputBorder(),
                                              filled: false,
                                            ),
                                            onSaved: (value) =>
                                                mitnehemen.add(value)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: new RaisedButton(
                                          child: new Text('Add',
                                              style:
                                                  new TextStyle(fontSize: 15)),
                                          onPressed: () => _addItem(),
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      30.0)),
                                          color: Color(0xff7a62ff),
                                          textColor: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                            SizedBox(height: 30),
                            Center(
                              child: new RaisedButton(
                                child: new Text('Speichern',
                                    style: TextStyle(fontSize: 25)),
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                                color: Color(0xff7a62ff),
                                textColor: Colors.white,
                                onPressed: () => eventHinzufuegen(_addEvent),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ))));
    }));
  }

  _buildRow(int index) {
    return new GestureDetector(
      onTap: () => changemitnehmen(index),
      child: Container(
          child: Row(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Icon(
                Icons.brightness_1,
                size: 10,
              )),
          Expanded(
            flex: 2,
            child: Text(mitnehemen[index],
                style: new TextStyle(
                  fontSize: 15,
                )),
          )
        ],
      )),
    );
  }
}
