import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_Eventadd_page.dart';


class ViewEventPageState extends StatelessWidget {
  ViewEventPageState({this.info, this.pos});
  var info;
  String pos;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xff7a62ff),
              title: Text(info['Eventname'].toString()),
            ),
            body: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                    child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: viewEvent(),
                ));
              },
            ),floatingActionButton: Opacity(
              opacity: istLeiter() ? 1.0 : 0.0 ,
              child: new FloatingActionButton(
                elevation: 0.0,
                child: new Icon(Icons.edit),
                backgroundColor:  Color(0xff7a62ff),
                onPressed: () => routeToLagerbearb(context),
                ),
             ),));
  }

  Widget viewEvent() {
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
                      'Datum',
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
                        child: Text('Zeit:', style: TextStyle(fontSize: 20)),
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
                        child: Text('Zeit:', style: TextStyle(fontSize: 20)),
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
                          info['Schlussort'],
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  )
                ],
              )),
          Container(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Beschreibung:',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      info['Beschreibung'],
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              )),
          Container(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Mitnehmen:',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ]),
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
                        child: Text('Kontaktperson:',
                            style: TextStyle(fontSize: 20)),
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
  bool istLeiter(){
    if(pos=='Leiter'){
      return true;
    }else{
      return false;
    }
  }
 void routeToLagerbearb(context){
    Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => EventAddPage(eventinfo: info, agendaModus: AgendaModus.event,))).then((onValue){

                    });
  }
}
