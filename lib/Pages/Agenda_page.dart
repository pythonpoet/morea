import 'package:flutter/material.dart';
import 'home_page.dart';
import 'Agenda_Eventadd_page.dart';


class AgendaState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AgendaStatePage();
}

class _AgendaStatePage extends State<AgendaState>{

  void _getevents(_stufe){

  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text('Agenda'),
            backgroundColor: Color(0xff7a62ff),
          ),
          body: ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemExtent: 80.0,
            itemBuilder: (BuildContext context, int index){
              return new ListTile(
                title: Container(
                  height: 50.0,
                  padding: EdgeInsets.only(left: 10,right: 10),
                    alignment: Alignment.center, //
                  decoration: new BoxDecoration(
                      border:  new Border.all(
                        color: Colors.black,
                        width: 2
                      ),
                      borderRadius: new BorderRadius.all(
                          Radius.circular(4.0),
                      ),
                  ),
                  child: new Row(
                  children: <Widget>[
                    Expanded(
                        flex: 3,
                        child: new Text('09.03.2019')
                    ),
                    Expanded(
                      flex: 5,
                      child: new Text('Patrazinium'),
                    ),
                    Expanded(
                      flex: 2,
                      child:  Container(
                      height: 35,
                      padding: EdgeInsets.all(10),
                        alignment: Alignment.center, //
                      decoration: new BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: new BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                          child: new Text('Lager'),
                      ),
                    )
                  ],
                )
                )
              );
            },
          ),
          floatingActionButton: new FloatingActionButton(
            elevation: 0.0,
            child: new Icon(Icons.add),
            backgroundColor: Colors.deepPurple,
            onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=> EventAddPage()))
          ),
        )
    );
  }
}