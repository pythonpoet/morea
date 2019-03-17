import 'package:flutter/material.dart';
import 'home_page.dart';
import 'Agenda_Eventadd_page.dart';
import '../services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_Lager_page.dart';
import 'view_Event_page.dart';
import 'package:intl/intl.dart';

class AgendaState extends StatefulWidget {
  AgendaState({this.userInfo});
  var userInfo;
  @override
  State<StatefulWidget> createState() => _AgendaStatePage();
}

class _AgendaStatePage extends State<AgendaState> {
  Auth auth0 = new Auth();

  Stream<QuerySnapshot> qsagenda;

 _getAgenda(_stufe) async {
  
   qsagenda = Firestore.instance
        .collection('Stufen')
        .document(_stufe)
        .collection('Agenda')
        .orderBy("Order")
        .snapshots();
  }
  altevernichten(_agedatiteldatum,stufe){
    String somdate = _agedatiteldatum.split('-')[2]+'-'+_agedatiteldatum.split('-')[1]+'-'+_agedatiteldatum.split('-')[0];
    DateTime _agdatum = DateTime.parse(somdate+' 00:00:00.000');
    DateTime now = DateTime.now();
    if(_agdatum.difference(now).inDays< 0){
      auth0.deletedocument('/Stufen/$stufe/Agenda', _agedatiteldatum);
    }
  }
  bool istLeiter(){
    if(widget.userInfo['Pos']=='Leiter'){
      return true;
    }else{
      return false;
    }
  }
  routetoAddevent(){
    if(istLeiter()){
      Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => EventAddPage()));
    }
  }
  

  @override
  void initState() {
    _getAgenda(widget.userInfo['Stufe']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('tp0');
    return new Container(
        child: new Scaffold(
      appBar: new AppBar(
        title: new Text('Agenda'),
        backgroundColor: Color(0xff7a62ff),
      ),
      body: Agenda(widget.userInfo['Stufe']),
      floatingActionButton: Opacity(
        opacity: istLeiter() ? 1.0 : 0.0 ,
        child: new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.add),
          backgroundColor: Colors.deepPurple,
          onPressed: () => routetoAddevent()),
      ),
    ));
  }

  Widget Agenda(stufe) {
    return StreamBuilder(
        stream: qsagenda,
        builder: (context, AsyncSnapshot<QuerySnapshot> qsagenda) {
          if (!qsagenda.hasData) return Center(child:Text('Laden... einen Moment bitte', style: TextStyle(fontSize: 20),));
          if(qsagenda.data.documents.length==0)return Center(child:Text('Keine Events/Lager eingetragen', style: TextStyle(fontSize: 20),));
          return ListView.builder(
              itemCount: qsagenda.data.documents.length,
              itemBuilder: (context, int index) {
                final DocumentSnapshot _info = qsagenda.data.documents[index];
                altevernichten(_info['Datum'],stufe);
                
                if(_info['Event']){
                    return new ListTile(
                    title: Container(
                        height: 50.0,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        alignment: Alignment.center, //
                        decoration: new BoxDecoration(
                          border: new Border.all(color: Colors.black, width: 2),
                          borderRadius: new BorderRadius.all(
                            Radius.circular(4.0),
                          ),
                        ),
                        child: new Row(
                          children: <Widget>[
                            Expanded(flex: 3, child: new Text(_info['Datum'].toString())),
                            Expanded(
                              flex: 5,
                              child: new Text(_info.data['Eventname'].toString()),
                            ),
                            Expanded(
                              flex: 2,
                              child: SizedBox()
                            )
                          ],
                        )),
                        onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) => new ViewEventPageState(info: _info,))),
                        );
                }else if(_info['Lager']){
                   return new ListTile(
                    title: Container(
                        height: 50.0,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        alignment: Alignment.center, //
                        decoration: new BoxDecoration(
                          border: new Border.all(color: Colors.black, width: 2),
                          borderRadius: new BorderRadius.all(
                            Radius.circular(4.0),
                          ),
                        ),
                        child: new Row(
                          children: <Widget>[
                            Expanded(flex: 3, child: new Text(_info['Datum'].toString())),
                            Expanded(
                              flex: 5,
                              child: new Text(_info.data['Lagername'].toString()),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
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
                        )),
                        onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) => new ViewLagerPageState(info: _info,))),
                        );
                }
               
              });
        });
  }
}
