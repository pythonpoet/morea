import 'package:flutter/material.dart';



class EventAddPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _EventAddPageState();
}


class _EventAddPageState extends State<EventAddPage>{
 int value = 2;

  Map<String, bool> stufen ={
    'Biber' : false,
    'Wombat (Wölfe)' : false,
    'Nahani (Meitli)' : false,
    'Drason (Buebe)' : false,
    'Pios' : false,
};
 _addItem() {
   setState(() {
     value = value + 1;
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
            tabs: <Widget>[
              Tab(
                text: 'Event'
              ),
              Tab(
                text:'Lager'
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            event(),
            lager()
          ],
        ),
      ),
    );
  }

  Widget event(){
    return Container(
     child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child:

                  Column(
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
                                  //onSaved: (value) => _pfadinamen = value,
                                ),
                              )
                            ],
                          )
                      ),
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
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: false,
                                  ),
                                  //onSaved: (value) => _pfadinamen = value,
                                ),
                              )
                            ],
                          )
                      ),
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
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: false,
                                      hintText: 'Zeit'
                                  ),
                                  //onSaved: (value) => _pfadinamen = value,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: false,
                                      hintText: 'Ort'
                                  ),
                                  //onSaved: (value) => _pfadinamen = value,
                                ),
                              )
                            ],
                          )
                      ),
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
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: false,
                                      hintText: 'Zeit'
                                  ),
                                  //onSaved: (value) => _pfadinamen = value,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: new TextFormField(
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: false,
                                      hintText: 'Ort'
                                  ),
                                  //onSaved: (value) => _pfadinamen = value,
                                ),
                              )
                            ],
                          )
                      ),
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
                                      );
                                    }).toList(),
                                  )
                              )
                            ],
                          )
                      ),
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
                                  //onSaved: (value) => _pfadinamen = value,
                                ),
                              )
                            ],
                          )
                      ),
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
                                  //onSaved: (value) => _pfadinamen = value,
                                ),
                              )
                            ],
                          )
                      ),
                      Container(
                        height: 300,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Text('Mitnehmen'),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: ListView.builder(
                                        itemCount: this.value,
                                        itemBuilder: (context, index) => this._buildRow(index)),
                                  )
                                ],
                              ),
                              Row(
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
                                      //onSaved: (value) => _pfadinamen = value,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: new RaisedButton(
                                      child: new Text('Speichern',style: new TextStyle(fontSize: 20)),
                                      onPressed: () => _addItem(),
                                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                                      color: Color(0xff7a62ff),
                                      textColor: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ],

                          ),

                      )
                    ],
                  )
              )
          );
        }
      )
      );
  }

  Widget lager(){
    return new Scaffold(
      appBar: AppBar(
        title: Text("MyApp"),
      ),
      body: ListView.builder(
          itemCount: this.value,
          itemBuilder: (context, index) => this._buildRow(index)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
 _buildRow(int index) {
   return Text("Item " + index.toString());
 }
}