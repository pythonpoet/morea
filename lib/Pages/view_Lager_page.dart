import 'package:flutter/material.dart';

class ViewLagerPageState extends StatelessWidget {
  ViewLagerPageState({this.info});
  var info;

  @override
  Widget build(BuildContext context) {
    print(info['Kontakt']['Pfadiname']);
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(info['Lagername'].toString()),
        ),
        body: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                    child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: viewLager(),
                ));
              },
            )
      ),
    );
  }
  Widget viewLager(){
    return Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Datum von:',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          info['Datum'],
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Datum bis:',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          info['Datum bis'],
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Lagerort:',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          info['Lagerort'],
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Anfang:',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.brightness_1, size: 10),
                          ),
                          Expanded(
                            flex: 4,
                            child:
                                Text('Zeit:', style: TextStyle(fontSize: 20)),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              info['Anfangszeit'],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                         
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.brightness_1, size: 10),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text('Ort:', style: TextStyle(fontSize: 20)),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              info['Anfangsort'],
                              style: TextStyle(fontSize: 20),
                            ),
                          )
                        ],
                      )
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Schluss:',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.brightness_1, size: 10),
                          ),
                          Expanded(
                            flex: 4,
                            child:
                                Text('Zeit:', style: TextStyle(fontSize: 20)),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              info['Schlusszeit'],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.brightness_1, size: 10),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text('Ort:', style: TextStyle(fontSize: 20)),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              info['Schlusszeit'],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  constraints: BoxConstraints(
                    minHeight: 200,
                    maxHeight: 400
                  ),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Beschreibung:',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Expanded(
                        flex: 13,
                        child: SingleChildScrollView(
                          child: Text(
                          info['Beschreibung'],
                          style: TextStyle(fontSize: 20),
                        ),
                        )
                      )
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Mitnehmen:',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ]
                      ),
                      Container(
                        height: 23 * info['Mitnehmen'].length.toDouble(),
                        child: ListView.builder(
                          itemCount: this.info['Mitnehmen'].length,
                          itemBuilder: (context, int index) {
                            return Container(
                                child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.brightness_1,
                                      size: 10,
                                    )),
                                Expanded(
                                  flex: 9,
                                  child: Text(info['Mitnehmen'][index],
                                      style: new TextStyle(
                                        fontSize: 20,
                                      )),
                                ),
                              ],
                            ));
                          },
                        ),
                      )
                    ],
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Kontakt:',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.brightness_1, size: 10),
                          ),
                          Expanded(
                            flex: 4,
                            child:
                                Text('Kontaktperson:', style: TextStyle(fontSize: 20)),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              info['Kontakt']['Pfadiname'],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                         
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Icon(Icons.brightness_1, size: 10),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text('Ort:', style: TextStyle(fontSize: 20)),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              info['Kontakt']['Email'],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ],
          ),
        );
  }
}

